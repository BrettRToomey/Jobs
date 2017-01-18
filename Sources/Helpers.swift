import Foundation

public typealias Time = (hour: Int, minute: Int)

extension Int {
    public var am: Time {
        return (hour: self, minute: 0)
    }
    
    public var pm: Time {
        guard self <= 12 && self != 0 else {
            return (hour: self, minute: 0)
        }
        
        return (hour: self + 12, minute: 0)
    }
}

extension Date {
    static func now() -> (Day?, Int?, Int?) {
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
