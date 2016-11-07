import XCTest
import Foundation
@testable import Jobs

class JobsTests: XCTestCase {
    static var allTests : [(String, (JobsTests) -> () throws -> Void)] {
        return [
            ("testDurationsUnixTimestamp", testDurationsUnixTimestamp),
            ("testAddingJob", testAddingJob),
            ("testRemovingJob", testRemovingJob),
            ("testRunningJob", testRunningJob),
            ("testRunningTwoJobs", testRunningTwoJobs),
            ("testStoppingJobs", testStoppingJobs)
        ]
    }
    
    override func setUp() {
        Jobs.shared.jobs.removeAll()
    }
    
    func testDurationsUnixTimestamp() {
        let fiveSeconds = Duration.seconds(5).unixTime
        XCTAssertEqual(fiveSeconds, 5.0)
        
        let nineDays = Duration.days(9).unixTime
        XCTAssertEqual(nineDays, 777600.0)
        
        let fourWeeks = Duration.weeks(4).unixTime
        XCTAssertEqual(fourWeeks, 2419200.0)
    }
    
    func testAddingJob() {
        let id = Jobs.shared.add(interval: .seconds(1)) {
        }
        
        XCTAssertEqual(Jobs.shared.jobs.count, 1, "should only be one job")
        XCTAssertEqual(id, 0, "id should be 0")
    }
    
    func testRemovingJob() {
        let firstJob = Jobs.shared.add(interval: .seconds(1)) {
        }
        
        let _ = Jobs.shared.add(interval: .seconds(1)) {
        }
        
        Jobs.shared.remove(firstJob)
        XCTAssertEqual(Jobs.shared.jobs.count, 1, "there should be one job")
    }
    
    func testDoNotRunOnInit() {
        Jobs.shared.add(runOnInit: false, interval: .seconds(1)) {
        }
        XCTAssertNotEqual(Jobs.shared.jobs[0].lastPerformed, 0)
    }
    
    func testRunningJob() {
        var count = 0
        Jobs.shared.add(interval: .seconds(1)) {
            count += 1
        }
        
        try! Jobs.shared.start()
        XCTAssertTrue(Jobs.shared.isRunning)
        Thread.sleep(forTimeInterval: 5)
        XCTAssertEqual(count, 5, "job should have ran 5 times")
    }
    
    func testRunningTwoJobs() {
        var singleCount = 0
        var doubleCount = 0
        
        Jobs.shared.add(interval: .seconds(1)) {
            singleCount += 1
        }
        
        Jobs.shared.add(interval: .seconds(2)) {
            doubleCount += 1
        }
        
        try! Jobs.shared.start()
        Thread.sleep(forTimeInterval: 10)
        XCTAssertEqual(singleCount, 10, "the first job should have ran 10 times")
        XCTAssertEqual(doubleCount, 5, "the seconds job should have ran 5 times")
    }
    
    func testStoppingJobs() {
        try! Jobs.shared.stop()
        XCTAssertFalse(Jobs.shared.isRunning)
    }
}
