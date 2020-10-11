import XCTest
@testable import Tradernet

class TradernetTests: XCTestCase {
    
    func testDoublePrint() {
        var price: Double = 1.0
        XCTAssertEqual(price.print(), "+1")
        price = 1.0005
        XCTAssertEqual(price.print(), "+1.0005")
        price = -1.5
        XCTAssertEqual(price.print(), "-1.5")
        price = 0
        XCTAssertEqual(price.print(), "0")
    }

    func testDoubleMinStepFormat() {
        var price: Double = 1.0
        var minStep: Double = 0.001
        XCTAssertEqual(price.minStepFormat(minStep), "1.000")
        price = 1.00099999999999
        minStep = 0.0000010000004
        XCTAssertEqual(price.minStepFormat(minStep), "1.001000")
        price = 1.00100000000002
        minStep = 0.0000009999999
        XCTAssertEqual(price.minStepFormat(minStep), "1.001000")        
    }

}
