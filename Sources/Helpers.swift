/*import JSON
import Foundation

//TODO(Brett): change implementation to C since foundation is broken on Linux
func parseJSONFile(path: String) throws -> JSON {
    let fileString = try String(contentsOfFile: path)
    let json = try JSON.Parser.parse(
        fileString,
        options: [.allowComments, .omitNulls]
    )
    return json
}*/