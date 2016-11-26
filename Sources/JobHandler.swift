//Keeping this file private until job batches are supported.
protocol JobHandler {
	func onCompleted(status: Status)
}

struct Status {
	var total: Int
	var failed: Int
	var pending: Int
}