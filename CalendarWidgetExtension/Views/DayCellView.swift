import SwiftUI

struct DayCellView: View {
    let day: DayInfo?
    let isToday: Bool

    var body: some View {
        if let day {
            Text("\(day.dayNumber)")
                .font(isToday ? CalendarTheme.dayFontToday : CalendarTheme.dayFont)
                .foregroundStyle(isToday ? CalendarTheme.todayForeground : .primary)
                .frame(maxWidth: .infinity, minHeight: CalendarTheme.dayRowHeight)
                .background {
                    if isToday {
                        Circle()
                            .fill(CalendarTheme.todayBackground)
                    }
                }
        } else {
            Color.clear
                .frame(maxWidth: .infinity, minHeight: CalendarTheme.dayRowHeight)
        }
    }
}
