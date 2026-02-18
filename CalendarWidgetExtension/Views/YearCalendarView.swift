import SwiftUI
import WidgetKit

struct YearCalendarView: View {
    let entry: CalendarEntry

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(String(entry.yearData.year))
                .font(CalendarTheme.yearHeaderFont)
                .foregroundStyle(.primary)

            LazyVGrid(columns: columns, spacing: CalendarTheme.monthGridSpacing) {
                ForEach(entry.yearData.months) { month in
                    MonthView(
                        month: month,
                        isCurrentMonth: month.id == entry.todayMonth,
                        todayDay: month.id == entry.todayMonth ? entry.todayDay : nil
                    )
                }
            }
        }
        .padding(CalendarTheme.widgetPadding)
    }
}
