/**
    A slight modification of `Pellet's` implementation
    http://stackoverflow.com/a/31510860/1982760
*/
import Foundation

#if !swift(>=3.1) && os(Linux)
	typealias Process = Task
#endif


enum ShellError: Error {
    /// Thrown when the command didn't error but data failed to unwrap.
    case failedToUnwrapOutput
}

/**
    Launch any process and log its output.
 
    - Parameters:
        - path: The path of the process to launch.
        - args: The arguments to pass to the launched process.
 
    - Returns: `STDOUT`
 */
@discardableResult
public func shell(path launchPath: String, args arguments: [String]) throws -> String {
    let process = Process()
    process.launchPath = launchPath
    process.arguments = arguments
    
    let pipe = Pipe()
    process.standardOutput = pipe
    process.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let result = String(data: data, encoding: .utf8) else {
        throw ShellError.failedToUnwrapOutput
    }
    
    if result.characters.count > 0 {
        let lastIndex = result.index(before: result.endIndex)
        return result[result.startIndex ..< lastIndex]
    }
    
    return result
}

/**
    Execute any `bash` command and log its output.
 
    - Parameters:
        - command: The command to be executed.
        - args: The argumentes to pass to the interpreter.
 
    - Returns: `STDOUT`
 
 */
@discardableResult
public func bash(command: String, args: [String]) throws -> String {
    let whichPathForCommand = try shell(
        path: "/bin/bash",
        args: [ "-l", "-c", "which \(command)" ]
    )
    return try shell(path: whichPathForCommand, args: args)
}
