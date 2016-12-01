import Core
import Dispatch
import Foundation

/// Represents an amount of time.
public enum Duration {
    case seconds(Double)
    case days(Int)
    case weeks(Int)
}

extension Duration {
    /// Converts the enumeration representation of time into a `Double`.
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

public enum RecoverStrategy {
    case `none`
    case `default`
    case retry(after: Duration)
}

extension RecoverStrategy: Equatable {
    public static func ==(lhs: RecoverStrategy, rhs: RecoverStrategy) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none): 
            return true
        case (.default, .default):
            return true
        //we don't care about the times being equivalent.
        case (.retry, .retry):
            return true

        default:
            return false
        }
    }
}

//TODO(Brett): polymorphism to make configuration-built jobs easier to handle.
protocol Performable {
    var interval: Double { get set }
    func perform()
}

/// A scheduled, performable task.
public class Job: Performable {
    public typealias Action = (Void) throws -> Void
    public typealias ErrorCallback = (Error) -> RecoverStrategy

    /// The job's name.
    public var name: String?
    
    /// The current state of the job.
    public var isRunning: Bool
    
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

        isRunning = false
    }

    /// Starts a pending job.
    public func start() {
        guard !isRunning else {
            return
        }

        isRunning = true
        perform()
    }

    /// Stops a job.
    public func stop() {
        lock.locked {
            isRunning = false
        }
    }

    func perform() {
        lock.locked {
            guard isRunning else {
                return
            }

            do {
                try action()
                Jobs.shared.queue(self)
            } catch {
                guard
                    let recoveryStrategy = errorCallback?(error),
                    recoveryStrategy != .default
                else {
                    //default recovery strategy
                    Jobs.shared.queue(self, in: 5.seconds)
                    return
                }
                
                switch recoveryStrategy {
                case .retry(let deadline):
                    Jobs.shared.queue(self, in: deadline)    

                default:
                    break
                }
            }
        }
    }
}

public final class Jobs {
    //consider making `lock` and `workerQueue` static to remove singleton.
    static let shared = Jobs()

    let lock = Lock()
    let workerQueue = DispatchQueue(label: "jobs-worker")

    /**
        Registers a new `Job` with the provided properties.
     
        - Parameters:
            - name: The name of the job.
            - interval: How often the job is performed.
            - autoStart: Whether or not to start the job automatically.
            - action: The action to perform.
            - onError: An `Optional` error handler closure.
     
        - Returns: The instantiated `Job`.
     */
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

    /**
     Registers a new `Job` with the provided properties.
     
     - Parameters:
     - name: The name of the job.
     - interval: How often the job is performed.
     - autoStart: Whether or not to start the job automatically.
     - action: The action to perform.

     - Returns: The instantiated `Job`.
     */
    @discardableResult
    public static func add(
        name: String? = nil,
        interval: Duration,
        autoStart: Bool = true,
        action: @escaping Job.Action
    ) -> Job {
        return add(
            name: name,
            interval: interval,
            autoStart: autoStart,
            action: action,
            onError: nil
        )
    }

    func queue(_ job: Performable, in deadline: Duration) {
        let deadline: DispatchTime = .now() + deadline.unixTime
        lock.locked {
            workerQueue.asyncAfter(deadline: deadline, execute: job.perform)
        }
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
