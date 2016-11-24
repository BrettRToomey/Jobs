public protocol JobStatusDelegate {
	func failedToInvokeAction(for job: Job)
}
