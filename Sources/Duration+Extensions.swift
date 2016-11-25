extension Int {
	var seconds: Duration {
		return .seconds(Double(self))
	}

	var days: Duration {
		return .days(self)
	}

	var weeks: Duration {
		return .weeks(self)
	}
}

extension Double {
	var seconds: Duration {
		return .seconds(self)
	}
}