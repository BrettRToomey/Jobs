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

extension Day: Comparable {
    public static func <(lhs: Day, rhs: Day) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension Day: Strideable {
    public func advanced(by n: Int) -> Day {
        return Day(rawValue: rawValue + n) ?? .sunday
    }
    
    public func distance(to other: Day) -> Int {
        return other.rawValue - self.rawValue
    }
}
