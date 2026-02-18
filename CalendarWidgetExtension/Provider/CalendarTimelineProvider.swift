import WidgetKit

struct CalendarTimelineProvider: TimelineProvider {
    private let dataProvider: CalendarDataProvider = LocalCalendarService()

    func placeholder(in context: Context) -> CalendarEntry {
        Self.makeEntry(for: Date(), using: dataProvider)
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> Void) {
        completion(Self.makeEntry(for: Date(), using: dataProvider))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> Void) {
        let now = Date()
        let entry = Self.makeEntry(for: now, using: dataProvider)

        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(
            for: calendar.date(byAdding: .day, value: 1, to: now)!
        )
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }

    static func makeEntry(for date: Date, using provider: CalendarDataProvider) -> CalendarEntry {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        let today = DateComponents(year: year, month: month, day: day)
        let yearData = provider.yearData(for: year, today: today)

        return CalendarEntry(
            date: date,
            yearData: yearData,
            todayMonth: month,
            todayDay: day
        )
    }
}
