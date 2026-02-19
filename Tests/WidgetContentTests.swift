import XCTest
@testable import YearlyCalWidget

/// Regression tests verifying that all content required to render a complete
/// yearly calendar widget is present in the data layer — all 12 months,
/// their weekday headers, every date, and the current-date highlight.
final class WidgetContentTests: XCTestCase {
    private let service = LocalCalendarService()

    // MARK: - All months visible

    func testAllTwelveMonthsPresent() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 2, day: 19))
        XCTAssertEqual(data.months.count, 12, "Widget must contain all 12 months")
    }

    func testAllMonthNamesPresent() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 2, day: 19))
        let names = data.months.map { $0.name }
        XCTAssertFalse(names.contains(where: { $0.isEmpty }), "Every month must have a non-empty name")
        XCTAssertEqual(names.count, 12)
    }

    // MARK: - Weekday headers

    func testEveryMonthHasSixWeekRows() {
        // Months are padded to 6 rows so every month renders at the same height in the widget.
        // A month with fewer than 6 rows would cause misalignment or clipping.
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 2, day: 19))
        for month in data.months {
            XCTAssertEqual(month.weeks.count, 6,
                           "\(month.name) must have exactly 6 rows for consistent widget height")
        }
    }

    func testEveryWeekRowHasSevenCells() {
        // Each row must supply exactly 7 cells (one per weekday column).
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 2, day: 19))
        for month in data.months {
            for (rowIndex, week) in month.weeks.enumerated() {
                XCTAssertEqual(week.count, 7,
                               "\(month.name) row \(rowIndex) must have 7 cells")
            }
        }
    }

    // MARK: - All dates present

    func testAllDatesAppearInGrid_2026() {
        // Every day number 1...numberOfDays must appear exactly once per month.
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 2, day: 19))
        for month in data.months {
            let allDays = month.weeks.flatMap { $0 }.compactMap { $0 }.map { $0.dayNumber }
            let expected = Array(1...month.numberOfDays)
            XCTAssertEqual(allDays.sorted(), expected,
                           "\(month.name) 2026: dates in grid don't match expected 1…\(month.numberOfDays)")
        }
    }

    func testAllDatesAppearInGrid_leapYear2024() {
        // Verify leap year (Feb has 29 days) still produces all dates.
        let data = service.yearData(for: 2024, today: DateComponents(year: 2024, month: 1, day: 1))
        for month in data.months {
            let allDays = month.weeks.flatMap { $0 }.compactMap { $0 }.map { $0.dayNumber }
            let expected = Array(1...month.numberOfDays)
            XCTAssertEqual(allDays.sorted(), expected,
                           "\(month.name) 2024: dates in grid don't match expected 1…\(month.numberOfDays)")
        }
    }

    func testNoDatesAreDuplicated() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 2, day: 19))
        for month in data.months {
            let allDays = month.weeks.flatMap { $0 }.compactMap { $0 }.map { $0.dayNumber }
            XCTAssertEqual(allDays.count, Set(allDays).count,
                           "\(month.name) has duplicate day numbers")
        }
    }

    // MARK: - Current date highlight

    func testCurrentDateIsHighlighted() {
        let today = DateComponents(year: 2026, month: 2, day: 19)
        let data = service.yearData(for: 2026, today: today)
        let feb = data.months[1] // February
        let highlighted = feb.weeks.flatMap { $0 }.compactMap { $0 }.filter { $0.isToday }
        XCTAssertEqual(highlighted.count, 1, "Exactly one cell must be highlighted as today")
        XCTAssertEqual(highlighted.first?.dayNumber, 19, "Highlighted cell must be day 19")
    }

    func testHighlightAppearsOnlyInCurrentMonth() {
        let today = DateComponents(year: 2026, month: 2, day: 19)
        let data = service.yearData(for: 2026, today: today)
        for month in data.months {
            let highlighted = month.weeks.flatMap { $0 }.compactMap { $0 }.filter { $0.isToday }
            if month.id == 2 {
                XCTAssertEqual(highlighted.count, 1, "February must have exactly one highlighted day")
            } else {
                XCTAssertEqual(highlighted.count, 0, "\(month.name) must have no highlighted day")
            }
        }
    }

    func testHighlightOnFirstDayOfMonth() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        let jan = data.months[0]
        let highlighted = jan.weeks.flatMap { $0 }.compactMap { $0 }.filter { $0.isToday }
        XCTAssertEqual(highlighted.count, 1)
        XCTAssertEqual(highlighted.first?.dayNumber, 1)
    }

    func testHighlightOnLastDayOfMonth() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 12, day: 31))
        let dec = data.months[11]
        let highlighted = dec.weeks.flatMap { $0 }.compactMap { $0 }.filter { $0.isToday }
        XCTAssertEqual(highlighted.count, 1)
        XCTAssertEqual(highlighted.first?.dayNumber, 31)
    }

    // MARK: - Grid completeness across years

    func testAllDatesAppearInGrid_2025() {
        let data = service.yearData(for: 2025, today: DateComponents(year: 2025, month: 6, day: 15))
        for month in data.months {
            let allDays = month.weeks.flatMap { $0 }.compactMap { $0 }.map { $0.dayNumber }
            let expected = Array(1...month.numberOfDays)
            XCTAssertEqual(allDays.sorted(), expected,
                           "\(month.name) 2025: dates in grid don't match expected 1…\(month.numberOfDays)")
        }
    }
}
