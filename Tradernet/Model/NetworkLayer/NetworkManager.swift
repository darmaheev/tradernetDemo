import Foundation
import SocketIO
import Alamofire
import PromiseKit

// MARK: - Encodable extensions

extension Encodable {
    var dictionary: Parameters? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? Parameters }
    }
}

class NetworkManager {
    
    func controller() -> String {
        return .empty
    }
    
    private let baseUrl = "https://tradernet.ru/api/"
    private let socketBaseUrl = "https://ws2.tradernet.ru/"
    
    let manager: SocketManager
    let socket: SocketIOClient
    
    init() {
        manager = SocketManager(socketURL: URL(string: socketBaseUrl)!, config: [.compress])
        socket = manager.defaultSocket
    }
    
}

// MARK: - Requests

extension NetworkManager {
    func request<T: CFTypeRef>(
        _ name: String,
        method: HTTPMethod,
        object: Codable? = nil,
        responseType: T.Type
    ) -> Promise<T> where T: Codable {
        let parameters = object?.dictionary ?? [:]

        return Promise<T> { seal in
            firstly {
                request(name, method: method, parameters: parameters)
            }.ensure {
                print("ℹ️ \(method.rawValue): \(name)")
            }.done(on: DispatchQueue.global()) { data in
                if let result = try? JSONDecoder().decode(T.self, from: data) {
                    seal.fulfill(result)
                } else {
                    print("‼️: Decoding failure.")
                    seal.reject(NSError(domain: "LOCAL", code: 550, userInfo: nil))
                }
            }.catch { error in
                print("‼️: \(error.localizedDescription)")
                seal.reject(error)
            }
        }
    }

    func request<T: CFTypeRef>(_ name: String,
                               method: HTTPMethod,
                               object: Codable? = nil,
                               responseType: [T].Type)
        -> Promise<[T]> where T: Codable {

        let parameters = object?.dictionary ?? [:]
        return Promise<[T]> { seal in
            firstly {
                request(name, method: method, parameters: parameters)
            }.ensure {
                print("ℹ️ \(method.rawValue): \(name)")
            }.done(on: DispatchQueue.global()) { data in
                if let result = try? JSONDecoder().decode([T].self, from: data) {
                    seal.fulfill(result)
                } else {
                    print("‼️: Decoding failure.")
                    seal.reject(NSError(domain: "LOCAL", code: 550, userInfo: nil))
                }
            }.catch { error in
                print("‼️: \(error.localizedDescription)")
                seal.reject(error)
            }
        }

    }

    private func request(_ name: String, method: HTTPMethod, parameters: Parameters?) -> Promise<Data> {
        Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = 6.0

        let responseSignature: String = "\(method.rawValue): \(controller())/\(name)"
        print("ℹ️ \(responseSignature)")

        return Promise<Data> { resolver in
            Alamofire
                .request(baseUrl + controller() + "/" + name,
                         method: method,
                         parameters: parameters)
                .validate()
                .responseData { response in
                    print("✅ \(response.response?.statusCode ?? -1) \n\(responseSignature)")

                    switch response.result {
                    case .success(let result):
                        resolver.fulfill(result)
                    case .failure(let error):
                        // use response data to map error: description from response
                        print("‼️ Fail: \n\(responseSignature)")
                        if let code = (error as? AFError)?.responseCode {
                            print("‼️ Fail: \(code)")
                        }
                        resolver.reject(error)
                    }
            }
        }

    }
}
