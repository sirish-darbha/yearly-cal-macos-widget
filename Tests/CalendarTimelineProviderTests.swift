import XCTest
@testable import YearlyCalWidget

final class CalendarTimelineProviderTests: XCTestCase {

    func testMakeEntryHasCorrectDateComponents() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2026
        components.month = 7
        components.day = 4
        components.hour = 14
        let date = calendar.date(from: components)!

        let entry = CalendarTimelineProvider.makeEntry(for: date, using: LocalCalendarService())

        XCTAssertEqual(entry.todayMonth, 7)
        XCTAssertEqual(entry.todayDay, 4)
        XCTAssertEqual(entry.yearData.year, 2026)
        XCTAssertEqual(entry.yearData.months.count, 12)
    }

    func testMakeEntryMarksCorrectDayAsToday() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2026
        components.month = 12
        components.day = 25
        let date = calendar.date(from: components)!

        let entry = CalendarTimelineProvider.makeEntry(for: date, using: LocalCalendarService())

        let december = entry.yearData.months[11]
        let allDays = december.weeks.flatMap { $0 }.compactMap { $0 }
        let todayDays = allDays.filter { $0.isToday }
        XCTAssertEqual(todayDays.count, 1)
        XCTAssertEqual(todayDays.first?.dayNumber, 25)
    }

    func testEntryDateMatchesInput() {
        let date = Date()
        let entry = CalendarTimelineProvider.makeEntry(for: date, using: LocalCalendarService())
        XCTAssertEqual(entry.date, date)
    }
}
