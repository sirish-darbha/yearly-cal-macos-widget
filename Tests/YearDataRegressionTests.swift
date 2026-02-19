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
        // February 2026 starts on Sunday, has 28 days → 4 non-empty rows (padded to 6 total)
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        let feb = data.months[1]
        XCTAssertEqual(feb.firstWeekdayIndex, 0)
        XCTAssertEqual(feb.numberOfDays, 28)
        XCTAssertEqual(feb.weeks.count, 6, "All months are padded to 6 total rows")
        let nonEmptyWeeks = feb.weeks.filter { $0.contains(where: { $0 != nil }) }
        XCTAssertEqual(nonEmptyWeeks.count, 4, "February 2026 should have exactly 4 non-empty week rows")
    }

    // MARK: - Issue regressions

    /// May 2026 starts on Friday (index 5), leaving 5 leading nil cells in week 1.
    /// Regression: dates were missing / showing truncation dots in the widget.
    func testMay2026StartsOnFridayAndContainsAllDays() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        let may = data.months[4]
        XCTAssertEqual(may.firstWeekdayIndex, 5, "May 2026 must start on Friday (index 5)")
        XCTAssertEqual(may.numberOfDays, 31)
        // Columns 0-4 (Sun–Thu) must be nil in week 0
        for col in 0..<5 {
            XCTAssertNil(may.weeks[0][col], "May 2026 week 0 col \(col) must be nil")
        }
        // Day 1 must land in column 5 (Friday), day 2 in column 6 (Saturday)
        XCTAssertEqual(may.weeks[0][5]?.dayNumber, 1, "May 2026 day 1 must be in col 5 (Friday)")
        XCTAssertEqual(may.weeks[0][6]?.dayNumber, 2, "May 2026 day 2 must be in col 6 (Saturday)")
        // All 31 days must be present exactly once
        let allDays = may.weeks.flatMap { $0 }.compactMap { $0 }.map { $0.dayNumber }
        XCTAssertEqual(allDays.sorted(), Array(1...31), "May 2026 must contain all days 1-31")
    }

    /// August 2026 starts on Saturday (index 6), the most extreme leading-nil case (6 nils).
    /// Regression: only day 1 in week 1 caused incomplete-looking rows.
    func testAugust2026StartsOnSaturdayAndContainsAllDays() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        let aug = data.months[7]
        XCTAssertEqual(aug.firstWeekdayIndex, 6, "August 2026 must start on Saturday (index 6)")
        XCTAssertEqual(aug.numberOfDays, 31)
        // Columns 0-5 (Sun–Fri) must be nil in week 0
        for col in 0..<6 {
            XCTAssertNil(aug.weeks[0][col], "August 2026 week 0 col \(col) must be nil")
        }
        // Only day 1 appears in week 0, at column 6 (Saturday)
        XCTAssertEqual(aug.weeks[0][6]?.dayNumber, 1, "August 2026 day 1 must be in col 6 (Saturday)")
        // All 31 days must be present exactly once
        let allDays = aug.weeks.flatMap { $0 }.compactMap { $0 }.map { $0.dayNumber }
        XCTAssertEqual(allDays.sorted(), Array(1...31), "August 2026 must contain all days 1-31")
    }

    /// February 2026 starts on Sunday (index 0): no leading nils, 4 fully-packed weeks,
    /// then 2 empty padding rows. Regression: dates appeared spaced out in the widget.
    func testFebruary2026NoLeadingNilsAndCorrectPadding() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        let feb = data.months[1]
        XCTAssertEqual(feb.firstWeekdayIndex, 0, "Feb 2026 must start on Sunday (index 0)")
        XCTAssertEqual(feb.numberOfDays, 28)
        // Week 0 must have no leading nils — days 1-7 fill all 7 columns
        for col in 0..<7 {
            XCTAssertEqual(feb.weeks[0][col]?.dayNumber, col + 1,
                           "Feb 2026 week 0 col \(col) must be day \(col + 1)")
        }
        // Weeks 0-3 are non-empty, weeks 4-5 are empty padding
        for weekIdx in 0..<4 {
            XCTAssertTrue(feb.weeks[weekIdx].contains(where: { $0 != nil }),
                          "Feb 2026 week \(weekIdx) must be non-empty")
        }
        for weekIdx in 4..<6 {
            XCTAssertTrue(feb.weeks[weekIdx].allSatisfy({ $0 == nil }),
                          "Feb 2026 week \(weekIdx) must be all-nil padding")
        }
    }

    /// Today flag must land on exactly the right cell.
    /// Regression: today was rendered with wrong highlight (white-on-white).
    func testTodayFlagIsPlacedInCorrectRowAndColumn() {
        // Feb 19, 2026 is a Thursday (index 4), in the third week row (0-indexed week 2).
        let today = DateComponents(year: 2026, month: 2, day: 19)
        let data = service.yearData(for: 2026, today: today)
        let feb = data.months[1]
        var foundRow = -1
        var foundCol = -1
        for (weekIdx, week) in feb.weeks.enumerated() {
            for (colIdx, cell) in week.enumerated() {
                if let cell, cell.isToday {
                    foundRow = weekIdx
                    foundCol = colIdx
                }
            }
        }
        XCTAssertEqual(foundRow, 2, "Feb 19 must be in week row 2 (third row)")
        XCTAssertEqual(foundCol, 4, "Feb 19 (Thursday) must be in column 4")
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
