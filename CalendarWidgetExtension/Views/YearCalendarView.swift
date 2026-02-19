import SwiftUI
import WidgetKit

struct YearCalendarView: View {
    let entry: CalendarEntry

    var body: some View {
        VStack(alignment: .leading, spacing: CalendarTheme.yearHeaderSpacing) {
            Text(String(entry.yearData.year))
                .font(CalendarTheme.yearHeaderFont)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(-0.3)

            HStack(alignment: .top, spacing: 0) {
                quarterColumn(months: Array(entry.yearData.months[0..<3]))
                quarterDivider
                quarterColumn(months: Array(entry.yearData.months[3..<6]))
                quarterDivider
                quarterColumn(months: Array(entry.yearData.months[6..<9]))
                quarterDivider
                quarterColumn(months: Array(entry.yearData.months[9..<12]))
            }
        }
        .padding(CalendarTheme.widgetPadding)
    }

    private func quarterColumn(months: [MonthData]) -> some View {
        VStack(alignment: .center, spacing: CalendarTheme.monthSpacing) {
            ForEach(months) { month in
                MonthView(
                    month: month,
                    isCurrentMonth: month.id == entry.todayMonth,
                    todayDay: month.id == entry.todayMonth ? entry.todayDay : nil
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var quarterDivider: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.08))
            .frame(width: 0.5)
            .padding(.horizontal, CalendarTheme.quarterDividerPadding)
    }
}
