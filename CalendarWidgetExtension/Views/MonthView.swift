import SwiftUI

struct MonthView: View {
    let month: MonthData
    let isCurrentMonth: Bool
    let todayDay: Int?

    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols
    private let dayColumns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(month.name)
                .font(CalendarTheme.monthNameFont)
                .foregroundStyle(isCurrentMonth ? .primary : .secondary)
                .lineLimit(1)

            LazyVGrid(columns: dayColumns, spacing: 0) {
                ForEach(weekdaySymbols.indices, id: \.self) { index in
                    Text(weekdaySymbols[index])
                        .font(CalendarTheme.weekdayHeaderFont)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: dayColumns, spacing: 0) {
                ForEach(Array(month.weeks.enumerated()), id: \.offset) { _, week in
                    ForEach(0..<7, id: \.self) { dayIndex in
                        DayCellView(
                            day: week[dayIndex],
                            isToday: week[dayIndex]?.isToday ?? false
                        )
                    }
                }
            }
        }
    }
}
