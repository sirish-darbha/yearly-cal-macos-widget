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
                Rectangle()
                    .stroke(Color.red, lineWidth: 1)
                    .frame(
                        width: CalendarTheme.dayFontSize * 1.936,
                        height: CalendarTheme.dayFontSize * 1.2
                    )
            }

            if let day {
                Text(verbatim: String(day.dayNumber))
                    .font(isToday ? .system(size: CalendarTheme.dayFontSize, weight: .bold) : CalendarTheme.dayFont)
                    .foregroundStyle(.primary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
