import Foundation
/*import JSON

//TODO(Brett): change implementation to C since foundation is broken on Linux
func parseJSONFile(path: String) throws -> JSON {
    let fileString = try String(contentsOfFile: path)
    let json = try JSON.Parser.parse(
        fileString,
        options: [.allowComments, .omitNulls]
    )
    return json
}*/

public enum Day: Int {
	case today
	case sunday
	case monday
	case tuesday
	case wednesday
	case thursday
	case friday
	case saturday
}

typealias Time = (hour: Int, minute: Int)

extension Int {
    var am: Time {
        return (hour: self, minute: 0)
    }
    
    var pm: Time {
        guard self <= 12 && self != 0 else {
            return (hour: self, minute: 0)
        }
        
        return (hour: self + 12, minute: 0)
    }
}

extension Date {
    static func today() -> (Day?, Int?, Int?) {
        let components = Calendar(identifier: .gregorian).dateComponents([.weekday, .hour, .minute], from: Date())
        
        guard
            let weekday = components.weekday,
            let hour = components.hour,
            let minute = components.minute
        else {
            return (nil, nil, nil)
        }
        
        return (Day(rawValue: weekday), hour, minute)
    }
}
