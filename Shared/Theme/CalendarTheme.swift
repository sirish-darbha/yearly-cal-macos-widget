import SwiftUI

enum CalendarTheme {
    // Typography
    static let yearHeaderFont: Font = .system(size: 14, weight: .bold, design: .rounded)
    static let monthNameFont: Font = .system(size: 8, weight: .semibold, design: .rounded)
    static let weekdayHeaderFont: Font = .system(size: 5, weight: .medium)
    static let dayFont: Font = .system(size: 6, weight: .regular, design: .monospaced)
    static let dayFontToday: Font = .system(size: 6, weight: .bold, design: .monospaced)

    // Colors
    static let todayBackground: Color = .accentColor
    static let todayForeground: Color = .white

    // Spacing
    static let monthGridSpacing: CGFloat = 6
    static let columnSpacing: CGFloat = 8
    static let widgetPadding: CGFloat = 12
    static let dayRowHeight: CGFloat = 10
}
