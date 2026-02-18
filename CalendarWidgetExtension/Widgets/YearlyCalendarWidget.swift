import WidgetKit
import SwiftUI

struct YearlyCalendarWidget: Widget {
    let kind: String = "com.sirishkumar.yearly-cal-widget.calendar"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarTimelineProvider()) { entry in
            YearCalendarView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Yearly Calendar")
        .description("A full year calendar showing all 12 months.")
        .supportedFamilies([.systemExtraLarge])
    }
}
