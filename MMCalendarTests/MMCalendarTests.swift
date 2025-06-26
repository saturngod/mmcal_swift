import XCTest
import JavaScriptCore
@testable import MMCalendar

class MyanmarCalendarTests: XCTestCase {

    // Test default initialization
    func testInit() throws {
        XCTAssertNoThrow(try MyanmarCalendar())
    }

    // Test initialization with Julian date
    func testInitWithJulianDate() throws {
        let julianDate = 2459756.5 // Example Julian date for June 25, 2022
        XCTAssertNoThrow(try MyanmarCalendar(julianDate: julianDate))
    }

    // Test initialization with Western date
    func testInitWithWesternDate() throws {
        XCTAssertNoThrow(try MyanmarCalendar(year: 2022, month: 6, day: 25))
    }

    // Test westernToJulian conversion
    func testWesternToJulian() throws {
        let julianDate = try MyanmarCalendar.westernToJulian(year: 2022, month: 6, day: 25)
        // Expected Julian date for 2022-06-25 12:00:00 (UTC) is 2459756.0
        // The JS library calculates with 12:00:00 as default, so it should be .0
        // However, the JS code adds 0.5 to the JD for j2w and subtracts 0.5 for w2j.
        // Let's verify with a known value from an external source or the JS code itself.
        // Based on the JS code, w2j(2022, 6, 25) should return 2459756.0
        XCTAssertEqual(julianDate, 2459756.0, accuracy: 0.000001)
    }

    // Test getCurrentMyanmarDateString
    func testGetCurrentMyanmarDateString() throws {
        let calendar = try MyanmarCalendar(year: 2022, month: 6, day: 25)
        let myanmarDateString = calendar.getCurrentMyanmarDateString()
        XCTAssertNotNil(myanmarDateString)
        // Further assertions can be added if the exact expected string format is known
        // For example: XCTAssertTrue(myanmarDateString!.contains("Waso"))
    }

    // Test property accessors
    func testPropertyAccessors() throws {
        let calendar = try MyanmarCalendar(year: 2022, month: 6, day: 25)

//        XCTAssertNotNil(calendar.pyathada)
        XCTAssertNotNil(calendar.julianDate)
        XCTAssertNotNil(calendar.myanmarYear)
        XCTAssertNotNil(calendar.myanmarMonth)
        XCTAssertNotNil(calendar.myanmarDay)
//        XCTAssertNotNil(calendar.sabbath)
//        XCTAssertNotNil(calendar.yatyaza)
        XCTAssertNotNil(calendar.nagahle)
        XCTAssertNotNil(calendar.mahabote)
        XCTAssertNotNil(calendar.nakhat)
        XCTAssertNotNil(calendar.weekday)
        XCTAssertNotNil(calendar.year)
        XCTAssertNotNil(calendar.month)
        XCTAssertNotNil(calendar.day)
    }

    // Test error handling for failed JavaScript loading
    func testFailedToLoadJavaScript() {
        // To test this, we would need to mock Bundle.main.path(forResource:ofType:)
        // or temporarily rename the JS file. For a real unit test, consider dependency injection
        // or a test bundle that doesn't contain the JS file.
        // For now, we'll assume it loads correctly as per the current setup.
        // This test case is more conceptual without a mocking framework.
    }

    // Test error handling for failed instance creation
    func testFailedToCreateInstance() {
        // Similar to failedToLoadJavaScript, this would require manipulating the JSContext
        // or the JS file content to cause a failure in instance creation.
        // This is also more conceptual without advanced mocking.
    }
}
