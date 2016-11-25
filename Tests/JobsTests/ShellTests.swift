import XCTest
@testable import Jobs

class ShellTests: XCTestCase {
    static var allTests = [
        ("testShellCommand", testShellCommand),
        ("testBashCommand", testBashCommand)
    ]
    
    func testShellCommand() {
        do {
            let output = try shell(path: "/bin/echo", args: ["shell test"])
            XCTAssertEqual(output, "shell test")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testBashCommand() {
        do {
            let output = try bash(command: "echo", arguments: ["hello, world!"])
            XCTAssertEqual(output, "hello, world!")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testJSONParser() {
        do {
            let _ = try parseJSONFile(path: "./Samples/MyJob.json")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
