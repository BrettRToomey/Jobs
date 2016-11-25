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

public struct Job {
    public typealias Action = (Void) -> Void
    public typealias JobId = UInt

    public var name: String?
    public let id: JobId
    public var isRunning: Bool

    var lastPerformed: Double
    var interval: Double
    let action: Action
}

extension Job {
    mutating func perform(_ time: Double, queue: DispatchQueue) {
        lastPerformed = time
        if isRunning {
            action()
        }
        queue.asyncAfter(deadline: .now() + interval, execute: action)
    }
}

public final class Jobs {
    public static let shared = Jobs()
    
    var jobs: [Job] = []
    var isRunning: Bool = false
    
    var idCounter: Job.JobId = 0

    let lock = Lock()
    let workerQueue = DispatchQueue(label: "jobs-worker")

    @discardableResult public func add(
        name: String? = nil,
        runOnInit: Bool = true,
        interval: Duration,
        action: @escaping Job.Action
    ) -> Job.JobId {
        var id: Job.JobId = 0
        lock.locked {
            defer {
                idCounter += 1
            }

            jobs.append(
                Job(
                    name: name,
                    id: idCounter,
                    isRunning: true,
                    lastPerformed: runOnInit ? 0 : Date().timeIntervalSince1970,
                    interval: interval.unixTime,
                    action: action
                )
            )

            id = idCounter
        }
        return id
    }

    public func remove(_ id: Job.JobId) {
        lock.locked {
            jobs = jobs.filter { $0.id != id }
        }
    }
    
    public func start() throws {
        guard !isRunning else {
            return
        }
        
        isRunning = true
        workerQueue.async {
            runLoop: while true {
                var shouldBreakout = false
                
                self.lock.locked {
                    shouldBreakout = !self.isRunning
                    let time = Date().timeIntervalSince1970
                    
                    for i in 0..<self.jobs.count {
                        if time - self.jobs[i].lastPerformed > self.jobs[i].interval {
                            self.jobs[i].perform(time, queue: self.workerQueue)
                        }
                    }
                }
                
                if shouldBreakout {
                    break runLoop
                } else {
                    self.sleep(for: 1)
                }
            }
        }
    }
    
    public func stop() throws {
        lock.locked {
            self.isRunning = false
        }
    }
    
    func sleep(for interval: Double) {
        Thread.sleep(forTimeInterval: interval)
    }
}
