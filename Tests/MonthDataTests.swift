import XCTest
@testable import YearlyCalWidget

final class MonthDataTests: XCTestCase {
    private let service = LocalCalendarService()

    func testDayNumbersAreSequential() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        for month in data.months {
            let allDays = month.weeks.flatMap { $0 }.compactMap { $0 }
            let dayNumbers = allDays.map { $0.dayNumber }
            let expected = Array(1...month.numberOfDays)
            XCTAssertEqual(dayNumbers, expected, "\(month.name) days are not sequential")
        }
    }

    func testFirstNonNilCellIsDay1() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        for month in data.months {
            let firstDay = month.weeks.first!.compactMap { $0 }.first
            XCTAssertNotNil(firstDay, "\(month.name) first week has no days")
            XCTAssertEqual(firstDay?.dayNumber, 1, "\(month.name) first day should be 1")
        }
    }

    func testLastNonNilCellIsLastDay() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        for month in data.months {
            // Months are padded to 6 rows; find the last row that contains any day
            let lastNonEmptyWeek = month.weeks.last(where: { $0.contains(where: { $0 != nil }) })
            let lastDay = lastNonEmptyWeek?.compactMap { $0 }.last
            XCTAssertNotNil(lastDay, "\(month.name) has no non-nil days")
            XCTAssertEqual(lastDay?.dayNumber, month.numberOfDays, "\(month.name) last day mismatch")
        }
    }

    func testLeadingNilsMatchFirstWeekdayOffset() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        for month in data.months {
            let firstWeek = month.weeks[0]
            let leadingNilCount = firstWeek.prefix(while: { $0 == nil }).count
            XCTAssertEqual(leadingNilCount, month.firstWeekdayIndex,
                           "\(month.name) leading nils (\(leadingNilCount)) != firstWeekdayIndex (\(month.firstWeekdayIndex))")
        }
    }

    func testTrailingNilsFillLastWeek() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        for month in data.months {
            let lastWeek = month.weeks.last!
            // After the last day, remaining slots should be nil
            if let lastDayIndex = lastWeek.lastIndex(where: { $0 != nil }) {
                for i in (lastDayIndex + 1)..<7 {
                    XCTAssertNil(lastWeek[i], "\(month.name) has non-nil after last day in final week")
                }
            }
        }
    }

    func testNoDuplicateDayNumbers() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        for month in data.months {
            let allDays = month.weeks.flatMap { $0 }.compactMap { $0 }
            let dayNumbers = allDays.map { $0.dayNumber }
            let uniqueDays = Set(dayNumbers)
            XCTAssertEqual(dayNumbers.count, uniqueDays.count, "\(month.name) has duplicate day numbers")
        }
    }

    func testMonthStartingOnSundayHasNoLeadingNils() {
        // February 2026 starts on Sunday (index 0)
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        let feb = data.months[1]
        XCTAssertEqual(feb.firstWeekdayIndex, 0)
        XCTAssertNotNil(feb.weeks[0][0], "February 2026 starts on Sunday, first cell should be day 1")
    }
}
