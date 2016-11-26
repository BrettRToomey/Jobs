import XCTest
import Foundation
@testable import Jobs

class JobsTests: XCTestCase {
    static var allTests = [
        ("testDurationsUnixTimestamp", testDurationsUnixTimestamp),
        ("testDurationExtensions", testDurationExtensions),
        ("testAddingJob", testAddingJob),
        ("testAddingJobWithErrorCallback", testAddingJobWithErrorCallback),
        ("testRunningJob", testRunningJob),
        ("testRunningTwoJobs", testRunningTwoJobs)
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
    
    func testAddingJobWithErrorCallback() {
        let job = Jobs.add(
            name: "MyJob", interval: 10.seconds, autoStart: false,
            action: {}, onError: { error in }
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
    
    func testRunningJob() {
        var count = 0
        let job = Jobs.add(interval: 1.seconds) { count += 1 }
        
        XCTAssertTrue(job.isRunning, "job should have automatically started.")
        Thread.sleep(forTimeInterval: 5.0)
        XCTAssertEqual(count, 5, "job should have ran 5 times.")
    }
    
    func testRunningTwoJobs() {
        var jobOneCount = 0, jobTwoCount = 0
        Jobs.add(interval: 2.seconds) { jobOneCount += 1 }
        Jobs.add(interval: 1.seconds) { jobTwoCount += 1 }
        
        Thread.sleep(forTimeInterval: 10.0)
        XCTAssertEqual(jobOneCount, 5, "the first job should have ran 5 times.")
        XCTAssertEqual(jobTwoCount, 10, "the second job should have ran 5 times.")
    }
}
