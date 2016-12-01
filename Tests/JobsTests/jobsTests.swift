import XCTest
import Foundation
@testable import Jobs

class JobsTests: XCTestCase {
    static var allTests = [
        ("testDurationsUnixTimestamp", testDurationsUnixTimestamp),
        ("testDurationExtensions", testDurationExtensions),
        ("testAddingJob", testAddingJob),
        ("testAddingJobErrorCallback", testAddingJobErrorCallback),
        ("testJob", testJob),
        ("testJobFailing", testJobFailing),
        ("testJobTwoInstances", testJobTwoInstances),
        ("testJobDelayed", testJobDelayed),
        ("testJobStopped", testJobStopped),
        ("testJobRerun", testJobRerun)
    ]
    
    func testDurationsUnixTimestamp() {
        let fiveSeconds = Duration.seconds(5).unixTime
        XCTAssertEqual(fiveSeconds, 5.0)
        
        let nineDays = Duration.days(9).unixTime
        XCTAssertEqual(nineDays, 777600.0)
        
        let fourWeeks = Duration.weeks(4).unixTime
        XCTAssertEqual(fourWeeks, 2419200.0)
    }

    func testDurationExtensions() {
        let seconds = 2.seconds
        XCTAssertEqual(seconds.unixTime, 2.0)

        let days = 9.days
        XCTAssertEqual(days.unixTime, 777600.0)

        let weeks = 4.weeks
        XCTAssertEqual(weeks.unixTime, 2419200.0)
    }
    
    func testAddingJob() {
        let job = Jobs.add(interval: .seconds(1), autoStart: false){}
        
        XCTAssertNil(job.name)
        XCTAssertFalse(job.isRunning, "job should not have started.")
        XCTAssertEqual(job.interval, 1.0)
        XCTAssertNil(job.errorCallback)
    }
    
    func testAddingJobErrorCallback() {
        let job = Jobs.add(
            name: "MyJob", interval: 10.seconds, autoStart: false,
            action: {}, onError: { _ in return .none }
        )
        
        guard let name = job.name else {
            XCTFail("name shouldn't be nil")
            return
        }
        
        XCTAssertEqual(name, "MyJob")
        XCTAssertFalse(job.isRunning, "job should not have started.")
        XCTAssertEqual(job.interval, 10.0)
        XCTAssertNotNil(job.errorCallback)
    }
    
    func testJob() {
        var count = 0
        let job = Jobs.add(interval: 1.seconds) { count += 1 }
        
        XCTAssertTrue(job.isRunning, "job should have automatically started.")
        Thread.sleep(forTimeInterval: 5.0)
        XCTAssertEqual(count, 5, "job should have ran 5 times.")
    }
    
    func testJobFailing() {
        enum Error: Swift.Error {
            case testError
        }
        
        var count = 0
        
        let job = Jobs.add(
            interval: 1.seconds,
            action: {
                throw Error.testError
            },
            onError: { error in
                guard case Error.testError = error else {
                    XCTFail("Got the wrong error")
                    return .none
                }
                
                count += 1
                return .none
            }
        )
        
        Thread.sleep(forTimeInterval: 2.0)
        job.stop()
        
        XCTAssertGreaterThanOrEqual(count, 1, "job should have failed one or more times.")
    }
    
    func testJobTwoInstances() {
        var jobOneCount = 0, jobTwoCount = 0
        Jobs.add(interval: 2.seconds) { jobOneCount += 1 }
        Jobs.add(interval: 1.seconds) { jobTwoCount += 1 }
        
        Thread.sleep(forTimeInterval: 10.0)
        XCTAssertEqual(jobOneCount, 5, "the first job should have ran 5 times.")
        XCTAssertEqual(jobTwoCount, 10, "the second job should have ran 5 times.")
    }
    
    func testJobDelayed() {
        var count = 0
        let job = Jobs.add(interval: 1.seconds, autoStart: false){ count += 1 }
        
        XCTAssertFalse(job.isRunning, "job should not have started.")
        
        job.start()
        XCTAssertTrue(job.isRunning, "job should have started.")
        
        Thread.sleep(forTimeInterval: 3.0)
        XCTAssertEqual(count, 3, "job should have ran 3 times.")
    }
    
    func testJobStopped() {
        let job = Jobs.add(interval: 1.seconds) {}
        
        XCTAssertTrue(job.isRunning, "job should have started.")
        
        job.stop()
        
        Thread.sleep(forTimeInterval: 2.0)
        XCTAssertFalse(job.isRunning, "job should have been stopped.")
    }
    
    func testJobRerun() {
        let job = Jobs.add(interval: 1.seconds) {}
        XCTAssertTrue(job.isRunning, "job should have started.")
        
        job.start()
        XCTAssertTrue(job.isRunning, "job should still be running.")
    }
}
