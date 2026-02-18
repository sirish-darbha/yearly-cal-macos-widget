import Foundation

struct LocalCalendarService: CalendarDataProvider {

    func yearData(for year: Int, today: DateComponents) -> YearData {
        let calendar = Calendar.current
        let monthSymbols = calendar.monthSymbols

        let months = (1...12).map { month -> MonthData in
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = 1

            let firstOfMonth = calendar.date(from: components)!
            let weekday = calendar.component(.weekday, from: firstOfMonth)
            let firstWeekdayIndex = weekday - 1 // Sunday = 0
            let range = calendar.range(of: .day, in: .month, for: firstOfMonth)!
            let numberOfDays = range.count

            let isCurrentMonth = today.year == year && today.month == month
            let weeks = buildWeeks(
                numberOfDays: numberOfDays,
                firstWeekdayIndex: firstWeekdayIndex,
                todayDay: isCurrentMonth ? today.day : nil
            )

            return MonthData(
                id: month,
                name: monthSymbols[month - 1],
                year: year,
                numberOfDays: numberOfDays,
                firstWeekdayIndex: firstWeekdayIndex,
                weeks: weeks
            )
        }

        return YearData(year: year, months: months)
    }

    private func buildWeeks(numberOfDays: Int, firstWeekdayIndex: Int, todayDay: Int?) -> [[DayInfo?]] {
        var weeks: [[DayInfo?]] = []
        var currentWeek: [DayInfo?] = Array(repeating: nil, count: 7)
        var dayCounter = 1
        var slotIndex = firstWeekdayIndex

        while dayCounter <= numberOfDays {
            let isToday = dayCounter == todayDay
            currentWeek[slotIndex] = DayInfo(dayNumber: dayCounter, isToday: isToday)
            dayCounter += 1
            slotIndex += 1
            if slotIndex == 7 {
                weeks.append(currentWeek)
                currentWeek = Array(repeating: nil, count: 7)
                slotIndex = 0
            }
        }

        if slotIndex > 0 {
            weeks.append(currentWeek)
        }

        return weeks
    }
}
