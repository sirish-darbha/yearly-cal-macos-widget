import Foundation

struct MonthData: Identifiable, Equatable {
    let id: Int
    let name: String
    let year: Int
    let numberOfDays: Int
    let firstWeekdayIndex: Int
    let weeks: [[DayInfo?]]
}
