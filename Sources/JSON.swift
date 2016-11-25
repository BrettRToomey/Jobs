import JSON

extension JSON {
    func buildJob() throws -> Job? {
        guard case JSON.object(let dict) = self else {
            throw Error.badField("expected root object got: \(self)")
        }
        
        //TODO: implementation
        return nil
    }
}