import XCTest
@testable import YearlyCalWidget

final class LocalCalendarServiceTests: XCTestCase {
    private let service = LocalCalendarService()

    // MARK: - Day counts

    func testAllMonthsGenerated() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        XCTAssertEqual(data.months.count, 12)
    }

    func testDayCountsForNonLeapYear() {
        let data = service.yearData(for: 2025, today: DateComponents(year: 2025, month: 1, day: 1))
        let expected = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        for (index, month) in data.months.enumerated() {
            XCTAssertEqual(month.numberOfDays, expected[index], "Month \(index + 1) day count mismatch")
        }
    }

    func testFebruaryLeapYear2024() {
        let data = service.yearData(for: 2024, today: DateComponents(year: 2024, month: 1, day: 1))
        XCTAssertEqual(data.months[1].numberOfDays, 29)
    }

    func testFebruaryNonLeapYear2025() {
        let data = service.yearData(for: 2025, today: DateComponents(year: 2025, month: 1, day: 1))
        XCTAssertEqual(data.months[1].numberOfDays, 28)
    }

    // MARK: - First weekday

    func testJanuary2026StartsOnThursday() {
        // January 1, 2026 is a Thursday → Sunday-start index = 4
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        XCTAssertEqual(data.months[0].firstWeekdayIndex, 4)
    }

    func testFebruary2026StartsOnSunday() {
        // February 1, 2026 is a Sunday → index = 0
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 2, day: 1))
        XCTAssertEqual(data.months[1].firstWeekdayIndex, 0)
    }

    // MARK: - Today marking

    func testTodayMarkedInCorrectMonth() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 3, day: 15))
        let marchWeeks = data.months[2].weeks
        let allDays = marchWeeks.flatMap { $0 }.compactMap { $0 }
        let todayDays = allDays.filter { $0.isToday }
        XCTAssertEqual(todayDays.count, 1)
        XCTAssertEqual(todayDays.first?.dayNumber, 15)
    }

    func testNoTodayInOtherMonths() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 6, day: 10))
        for (index, month) in data.months.enumerated() {
            let allDays = month.weeks.flatMap { $0 }.compactMap { $0 }
            let todayCount = allDays.filter { $0.isToday }.count
            if index == 5 { // June
                XCTAssertEqual(todayCount, 1, "June should have exactly one today")
            } else {
                XCTAssertEqual(todayCount, 0, "Month \(index + 1) should have no today marker")
            }
        }
    }

    func testTodayNotMarkedForDifferentYear() {
        let data = service.yearData(for: 2025, today: DateComponents(year: 2026, month: 3, day: 15))
        for month in data.months {
            let allDays = month.weeks.flatMap { $0 }.compactMap { $0 }
            XCTAssertTrue(allDays.allSatisfy { !$0.isToday }, "No day in 2025 should be marked today when today is in 2026")
        }
    }

    // MARK: - Grid completeness

    func testWeekRowsHaveSevenColumns() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        for month in data.months {
            for week in month.weeks {
                XCTAssertEqual(week.count, 7, "\(month.name) has a week with \(week.count) columns")
            }
        }
    }

    func testWeekCountBetween4And6() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        for month in data.months {
            XCTAssertGreaterThanOrEqual(month.weeks.count, 4, "\(month.name) has fewer than 4 weeks")
            XCTAssertLessThanOrEqual(month.weeks.count, 6, "\(month.name) has more than 6 weeks")
        }
    }

    // MARK: - Month metadata

    func testMonthNames() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        let expected = ["January", "February", "March", "April", "May", "June",
                        "July", "August", "September", "October", "November", "December"]
        for (index, month) in data.months.enumerated() {
            XCTAssertEqual(month.name, expected[index])
            XCTAssertEqual(month.id, index + 1)
            XCTAssertEqual(month.year, 2026)
        }
    }
}
