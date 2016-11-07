import Core
import Foundation

public typealias Action = (Void) -> Void
public typealias JobId = UInt

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

struct Performable {
    let id: JobId
    var lastPerformed: Double
    var interval: Double
    let action: Action
}

extension Performable {
    mutating func perform(_ time: Double) {
        lastPerformed = time
        action()
    }
}

public final class Jobs {
    public static let shared = Jobs()
    
    var jobs: [Performable] = []
    let lock = Lock()
    var isRunning: Bool = false
    
    var idCounter: JobId = 0

    @discardableResult public func add(
        runOnInit: Bool = true,
        interval: Duration,
        action: @escaping Action
    ) -> JobId {
        var id: JobId = 0
        lock.locked {
            defer {
                idCounter += 1
            }

            jobs.append(
                Performable(
                    id: idCounter,
                    lastPerformed: runOnInit ? 0 : Date().timeIntervalSince1970,
                    interval: interval.unixTime,
                    action: action
                )
            )

            id = idCounter
        }
        return id
    }

    public func remove(_ id: JobId) {
        lock.locked {
            jobs = jobs.filter { $0.id != id }
        }
    }
    
    public func start() throws {
        guard !isRunning else {
            return
        }
        
        isRunning = true
        try background {
            runLoop: while true {
                var shouldBreakout = false
                
                self.lock.locked {
                    shouldBreakout = !self.isRunning
                    let time = Date().timeIntervalSince1970
                    
                    for i in 0..<self.jobs.count {
                        if time - self.jobs[i].lastPerformed > self.jobs[i].interval {
                            self.jobs[i].perform(time)
                        }
                    }
                }
                
                if shouldBreakout {
                    break runLoop
                } else {
                    self.sleep(for: 1)
                }
            }
            
            print("I've left the scope")
        }
    }
    
    public func stop() throws {
        lock.locked {
            self.isRunning = false
        }
    }
    
    func sleep(for interval: Double) {
        #if os(Linux)
            Thread.sleepForTimeInterval(interval)
        #else
            Thread.sleep(forTimeInterval: interval)
        #endif
    }
}
