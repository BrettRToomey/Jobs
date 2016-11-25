public protocol JobHandler {
	func perform()
	func onCompleted(status: Status)
}