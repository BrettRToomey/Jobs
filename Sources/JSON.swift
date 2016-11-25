import JSON

extension JSON {
    func buildJob() throws -> Job {
        guard case JSON.object(let dict) = self else {
            throw Error.badField("expected root object got: \(self)")
        }
        
        //TODO: implementation
        return Job(
            name: "",
            id: 1,
            isRunning: true,
            lastPerformed: 0,
            interval: 0,
            action: {}
        )
    }
}
