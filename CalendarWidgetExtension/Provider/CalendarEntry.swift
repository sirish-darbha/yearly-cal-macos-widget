import WidgetKit

struct CalendarEntry: TimelineEntry {
    let date: Date
    let yearData: YearData
    let todayMonth: Int
    let todayDay: Int
}
