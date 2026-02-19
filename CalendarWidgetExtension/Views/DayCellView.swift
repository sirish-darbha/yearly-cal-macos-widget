import SwiftUI

struct DayCellView: View {
    let day: DayInfo?
    let isToday: Bool

    var body: some View {
        ZStack {
            // Hidden reference text ensures uniform cell height for ALL cells,
            // including all-nil padding rows (e.g. Feb 2026 weeks 4-5).
            // Without this, empty rows collapse to 0 height, causing months
            // with fewer real weeks to render at a different height.
            Text(verbatim: "0")
                .font(CalendarTheme.dayFont)
                .hidden()

            if isToday {
                Circle()
                    .fill(CalendarTheme.todayBackground)
                    .aspectRatio(1, contentMode: .fit)
            }

            if let day {
                Text(verbatim: String(day.dayNumber))
                    .font(isToday ? CalendarTheme.dayFontToday : CalendarTheme.dayFont)
                    .foregroundStyle(isToday ? CalendarTheme.todayForeground : .primary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
