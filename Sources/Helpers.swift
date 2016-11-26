import JSON
import Foundation

func parseJSONFile(path: String) throws -> JSON {
    let fileString = try String(contentsOfFile: path)
    let json = try JSON.Parser.parse(
        fileString,
        options: [.allowComments, .omitNulls]
    )
    return json
}