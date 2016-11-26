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
    
    //commented out until file loader is moved to C and path system is working
    //for xcode tests.
    /*
    func testJSONParser() {
        do {
            //will fail in XCode because of paths
            let _ = try parseJSONFile(path: "./Samples/MyJob.json")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    */
}
