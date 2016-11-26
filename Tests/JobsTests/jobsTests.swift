import XCTest
import Foundation
@testable import Jobs

class JobsTests: XCTestCase {
    static var allTests = [
        ("testDurationsUnixTimestamp", testDurationsUnixTimestamp),
        ("testDurationExtensions", testDurationExtensions),
        ("testAddingJob", testAddingJob)
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
        var count = 0
        
        let job = Jobs.add(interval: .seconds(1)){
            count += 1
        }
        
        XCTAssertTrue(job.isRunning, "job should have started automatically.")
        XCTAssertNil(job.name)
        XCTAssertEqual(job.interval, 1.0)
        XCTAssertNil(job.errorCallback)
        
        Thread.sleep(forTimeInterval: 5)
        XCTAssertEqual(count, 5)
    }
}
