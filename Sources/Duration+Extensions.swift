extension Int {
    /// Converts the integer into an enum representation of seconds.
	var seconds: Duration {
		return .seconds(Double(self))
	}

    /// Converts the integer into an enum representation of days.
	var days: Duration {
		return .days(self)
	}

    /// Converts the integer into an enum representation of weeks.
	var weeks: Duration {
		return .weeks(self)
	}
}

extension Double {
    /// Converts the real into an enum representation of seconds.
	var seconds: Duration {
		return .seconds(self)
	}
}
