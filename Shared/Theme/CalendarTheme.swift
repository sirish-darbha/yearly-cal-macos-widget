import SwiftUI

enum CalendarTheme {
    // Font sizes — one constant per category, shared by all Font variants in that category.
    // Keeping sizes in named constants lets tests verify same-size-within-category.
    static let yearHeaderFontSize: CGFloat = 9
    static let monthNameFontSize: CGFloat = 9
    static let weekdayHeaderFontSize: CGFloat = 8
    static let dayFontSize: CGFloat = 10   // used by both dayFont and dayFontToday

    // Typography
    static let yearHeaderFont: Font = .system(size: yearHeaderFontSize, weight: .bold)
    static let monthNameFont: Font = .system(size: monthNameFontSize, weight: .medium)
    static let weekdayHeaderFont: Font = .system(size: weekdayHeaderFontSize, weight: .regular)
    static let dayFont: Font = .system(size: dayFontSize, weight: .light)
    static let dayFontToday: Font = .system(size: dayFontSize, weight: .semibold)

    // Colors — explicit blue-600 for high contrast over white text
    static let todayBackground: Color = Color(red: 0.235, green: 0.478, blue: 0.929)
    static let todayForeground: Color = .white

    // Spacing
    static let widgetPadding: CGFloat = 10          // p-2.5
    static let yearHeaderSpacing: CGFloat = 6       // mb-1.5
    static let monthSpacing: CGFloat = 10           // gap-y-2.5 between months in a quarter
    static let quarterDividerPadding: CGFloat = 7   // 7 + 0.5 + 7 ≈ gap-x-3.5 (14pt)
}
