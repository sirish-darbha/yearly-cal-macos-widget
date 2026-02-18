import Foundation

struct DayInfo: Identifiable, Equatable {
    let id: Int
    let dayNumber: Int
    let isToday: Bool
    let hasEvents: Bool
    let eventCount: Int

    init(dayNumber: Int, isToday: Bool = false, hasEvents: Bool = false, eventCount: Int = 0) {
        self.id = dayNumber
        self.dayNumber = dayNumber
        self.isToday = isToday
        self.hasEvents = hasEvents
        self.eventCount = eventCount
    }
}
