import XCTest
@testable import Workflow

final class WorkflowTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let w1 = try Workflow {
            "Workflow"
        }.then {
            $0 + " yes!"
        }.value
        
        XCTAssertEqual(w1, "Workflow yes!")
        
        try Workflow {
            "Workflow"
        }.then {
            $0 + " yes!"
        }.end {
            XCTAssertEqual($0, "Workflow yes!")
        }
    }
    
    @available(macOS 12.0, *)
    func testConcurrency() async throws {
        
        try await Workflow {
            try await URLSession.shared.data(for: URLRequest(url: URL(string: "https://www.google.com/ncr")!))
        }.then({ pair in
            pair.0.isEmpty
        }).end({ value in
            XCTAssertEqual(value, false)
        })
    }
}
