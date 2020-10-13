import XCTest
@testable import NetworkCall

final class NetworkCallTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(NetworkCall().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
