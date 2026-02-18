import Foundation

protocol CalendarDataProvider {
    func yearData(for year: Int, today: DateComponents) -> YearData
}
