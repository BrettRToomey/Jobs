import Core
import Dispatch
import Foundation

public enum Duration {
    case seconds(Double)
    case days(Int)
    case weeks(Int)
}

extension Duration {
    public var unixTime: Double {
        switch self {
        case .seconds(let count):
            return count
        
        case .days(let count):
            let secondsInDay = 86_400
            return Double(count * secondsInDay)
            
        case .weeks(let count):
            let secondsInWeek = 604_800
            return Double(count * secondsInWeek)
        }
    }
}

protocol Performable {
    func perform()
}

public class Job: Performable {
    public typealias Action = (Void) throws -> Void
    public typealias ErrorCallback = (Error) -> Void

    public var name: String?
    public var isRunning: Bool

    var lastPerformed: Double
    var interval: Double
    let action: Action
    let errorCallback: ErrorCallback?

    let lock = Lock()

    init(
        name: String?,
        interval: Double,
        action: @escaping Action,
        errorCallback: ErrorCallback?
    ) {
        self.name = name
        self.interval = interval
        self.action = action
        self.errorCallback = errorCallback

        lastPerformed = 0
        isRunning = false
    }

    public func start() {
        guard !isRunning else {
            return
        }

        isRunning = true
        perform()
    }

    public func stop() {
        lock.locked {
            isRunning = false
        }
    }

    func perform() {
        lock.locked {
            if isRunning {
                do {
                    try action()
                } catch {
                    if let errorCallback = errorCallback {
                        errorCallback(error)
                    }
                }

                Jobs.shared.queue(self)
            }
        }
    }
}

public final class Jobs {
    static let shared = Jobs()
    
    var isRunning: Bool = false

    let lock = Lock()
    let workerQueue = DispatchQueue(label: "jobs-worker")

    public static func add(
        name: String? = nil,
        interval: Duration,
        autoStart: Bool = true,
        action: @escaping Job.Action,
        onError: Job.ErrorCallback? = nil
    ) -> Job? {
        return nil
    }

    func queue(_ job: Job) {
        lock.locked {
            workerQueue.asyncAfter(deadline: .now() + job.interval, execute: job.perform)
        }
    }
}