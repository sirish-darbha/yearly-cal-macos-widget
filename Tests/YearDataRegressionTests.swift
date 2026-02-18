import XCTest
@testable import YearlyCalWidget

final class YearDataRegressionTests: XCTestCase {
    private let service = LocalCalendarService()

    // MARK: - 2026 Full year regression

    func testYear2026MonthDayCounts() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        let expected = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        for (i, month) in data.months.enumerated() {
            XCTAssertEqual(month.numberOfDays, expected[i], "2026 month \(i + 1) day count")
        }
    }

    func testYear2026FirstWeekdays() {
        // 2026 first weekdays (Sunday=0): Jan=Thu(4), Feb=Sun(0), Mar=Sun(0), Apr=Wed(3),
        // May=Fri(5), Jun=Mon(1), Jul=Wed(3), Aug=Sat(6), Sep=Tue(2), Oct=Thu(4), Nov=Sun(0), Dec=Tue(2)
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        let expected = [4, 0, 0, 3, 5, 1, 3, 6, 2, 4, 0, 2]
        for (i, month) in data.months.enumerated() {
            XCTAssertEqual(month.firstWeekdayIndex, expected[i],
                           "2026 month \(i + 1) (\(month.name)) firstWeekdayIndex")
        }
    }

    // MARK: - 2024 Leap year regression

    func testYear2024LeapFebruary() {
        let data = service.yearData(for: 2024, today: DateComponents(year: 2024, month: 1, day: 1))
        XCTAssertEqual(data.months[1].numberOfDays, 29)
        // February 2024 starts on Thursday (index 4)
        XCTAssertEqual(data.months[1].firstWeekdayIndex, 4)
    }

    func testYear2024March1Weekday() {
        // March 1, 2024 is a Friday (index 5)
        let data = service.yearData(for: 2024, today: DateComponents(year: 2024, month: 1, day: 1))
        XCTAssertEqual(data.months[2].firstWeekdayIndex, 5)
    }

    // MARK: - 6-week month edge case

    func testAugust2025Has6Weeks() {
        // August 2025 starts on Friday (index 5), has 31 days → needs 6 rows
        let data = service.yearData(for: 2025, today: DateComponents(year: 2025, month: 1, day: 1))
        let august = data.months[7]
        XCTAssertEqual(august.firstWeekdayIndex, 5)
        XCTAssertEqual(august.numberOfDays, 31)
        XCTAssertEqual(august.weeks.count, 6, "August 2025 should have 6 week rows")
    }

    func testFebruary2026Has4Weeks() {
        // February 2026 starts on Sunday, has 28 days → exactly 4 rows
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        let feb = data.months[1]
        XCTAssertEqual(feb.firstWeekdayIndex, 0)
        XCTAssertEqual(feb.numberOfDays, 28)
        XCTAssertEqual(feb.weeks.count, 4, "February 2026 should have exactly 4 week rows")
    }

    // MARK: - Boundary dates

    func testJanuary1AsToday() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        let jan = data.months[0]
        let allDays = jan.weeks.flatMap { $0 }.compactMap { $0 }
        let today = allDays.first { $0.isToday }
        XCTAssertNotNil(today)
        XCTAssertEqual(today?.dayNumber, 1)
    }

    func testDecember31AsToday() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 12, day: 31))
        let dec = data.months[11]
        let allDays = dec.weeks.flatMap { $0 }.compactMap { $0 }
        let today = allDays.first { $0.isToday }
        XCTAssertNotNil(today)
        XCTAssertEqual(today?.dayNumber, 31)
    }
}
