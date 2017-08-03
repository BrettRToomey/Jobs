extension Int {
    /// Converts the integer into an enum representation of seconds.
	public var seconds: Duration {
		return .seconds(Double(self))
	}
	
    /// Converts the integer into an enum representation of hours.    
	public var hours: Duration {
		return .hours(self)
	}

    /// Converts the integer into an enum representation of days.
	public var days: Duration {
		return .days(self)
	}

    /// Converts the integer into an enum representation of weeks.
	public var weeks: Duration {
		return .weeks(self)
	}
}

extension Double {
    /// Converts the real into an enum representation of seconds.
	public var seconds: Duration {
		return .seconds(self)
	}
}
