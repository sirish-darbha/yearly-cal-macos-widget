import SwiftUI

struct MonthView: View {
    let month: MonthData
    let isCurrentMonth: Bool
    let todayDay: Int?

    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols

    var body: some View {
        // .frame(maxWidth: .infinity) makes the VStack fill the full proposed width W
        // from the quarter column, then proposes that same W to every child HStack.
        // Each HStack divides W equally among its 7 .frame(maxWidth:.infinity) cells,
        // so every cell is exactly W/7 wide — independent of nil vs. non-nil content.
        // Grid must NOT be used here: Grid sizes columns from cell content minimums,
        // so nil-day slots (empty ZStack → ideal size 0) cause Grid to under-allocate
        // width to columns that have many nil cells, producing unequal column widths.
        VStack(alignment: .leading, spacing: 0) {
            Text(String(month.name.prefix(3)))
                .font(CalendarTheme.monthNameFont)
                .foregroundStyle(isCurrentMonth ? .primary : .secondary)
                .textCase(.uppercase)
                .tracking(-0.3)
                .lineLimit(1)
                .padding(.bottom, 1)

            HStack(spacing: 0) {
                ForEach(weekdaySymbols.indices, id: \.self) { index in
                    Text(weekdaySymbols[index])
                        .font(CalendarTheme.weekdayHeaderFont)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            ForEach(Array(month.weeks.enumerated()), id: \.offset) { _, week in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        DayCellView(
                            day: week[dayIndex],
                            isToday: week[dayIndex]?.isToday ?? false
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
