import XCTest
@testable import YearlyCalWidget

/// Tests the entry-creation logic that the timeline provider delegates to.
/// The actual CalendarTimelineProvider lives in the extension target,
/// but its core logic is: create DateComponents from a Date, then call
/// CalendarDataProvider.yearData(for:today:). We test that pipeline here.
final class CalendarTimelineProviderTests: XCTestCase {
    private let service = LocalCalendarService()

    func testEntryForJuly4HasCorrectFields() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2026
        components.month = 7
        components.day = 4
        components.hour = 14
        let date = calendar.date(from: components)!

        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let today = DateComponents(year: year, month: month, day: day)
        let yearData = service.yearData(for: year, today: today)

        XCTAssertEqual(yearData.year, 2026)
        XCTAssertEqual(yearData.months.count, 12)
        XCTAssertEqual(month, 7)
        XCTAssertEqual(day, 4)
    }

    func testEntryForDecember25MarksCorrectDay() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2026
        components.month = 12
        components.day = 25
        let date = calendar.date(from: components)!

        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let today = DateComponents(year: year, month: month, day: day)
        let yearData = service.yearData(for: year, today: today)

        let december = yearData.months[11]
        let allDays = december.weeks.flatMap { $0 }.compactMap { $0 }
        let todayDays = allDays.filter { $0.isToday }
        XCTAssertEqual(todayDays.count, 1)
        XCTAssertEqual(todayDays.first?.dayNumber, 25)
    }

    func testMidnightRefreshDateIsNextDay() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 15
        components.hour = 22
        components.minute = 45
        let date = calendar.date(from: components)!

        let tomorrow = calendar.startOfDay(
            for: calendar.date(byAdding: .day, value: 1, to: date)!
        )

        let tomorrowComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: tomorrow)
        XCTAssertEqual(tomorrowComponents.year, 2026)
        XCTAssertEqual(tomorrowComponents.month, 3)
        XCTAssertEqual(tomorrowComponents.day, 16)
        XCTAssertEqual(tomorrowComponents.hour, 0)
        XCTAssertEqual(tomorrowComponents.minute, 0)
    }
}
