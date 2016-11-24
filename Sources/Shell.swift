/**
    A slight modification of `Pellet's` implementation
    http://stackoverflow.com/a/31510860/1982760
*/
import Foundation

#if os(Linux)
    typealias Process = Task
#endif

enum ShellError: Error {
    case failedToUnwrapOutput
}

@discardableResult
func shell(path launchPath: String, args arguments: [String]) throws -> String {
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

@discardableResult
func bash(command: String, arguments: [String]) throws -> String {
    let whichPathForCommand = try shell(
        path: "/bin/bash",
        args: [ "-l", "-c", "which \(command)" ]
    )
    return try shell(path: whichPathForCommand, args: arguments)
}
