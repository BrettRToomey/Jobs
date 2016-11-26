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

//TODO(Brett): polymorphism to make configuration-built jobs easier to handle.
protocol Performable {
    var interval: Double { get set }
    func perform()
}

public class Job: Performable {
    public typealias Action = (Void) throws -> Void
    public typealias ErrorCallback = (Error) -> Void

    public var name: String?
    public var isRunning: Bool

    //TODO(Brett): currently not being used, will add with job batches.
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

    @discardableResult
    public static func add(
        name: String? = nil,
        interval: Duration,
        autoStart: Bool = true,
        action: @escaping Job.Action,
        onError errorCallback: Job.ErrorCallback? = nil
    ) -> Job {
        let job = Job(
            name: name,
            interval: interval.unixTime,
            action: action,
            errorCallback: errorCallback
        )

        if autoStart {
            job.isRunning = true
            shared.queue(job, performNow: true)
        }

        return job
    }

    //enables shorthand for the closure when an error callback isn't required.
    @discardableResult
    public static func add(
        name: String? = nil,
        interval: Duration,
        autoStart: Bool = true,
        action: @escaping Job.Action
    ) -> Job {
        return add(name: name, interval: interval, autoStart: autoStart, action: action, onError: nil)
    }

    func queue(_ job: Performable, performNow: Bool = false) {
        lock.locked {
            workerQueue.asyncAfter(
                deadline: performNow ? .now() : .now() + job.interval,
                execute: job.perform
            )
        }
    }
}
