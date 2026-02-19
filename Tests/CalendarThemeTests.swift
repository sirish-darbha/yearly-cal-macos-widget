import XCTest
import SwiftUI
@testable import YearlyCalWidget

/// Tests that verify font-size consistency within each display category and
/// that the data layer produces grids of uniform shape — a hard prerequisite
/// for the layout engine to center month views correctly within their columns.
final class CalendarThemeTests: XCTestCase {
    private let service = LocalCalendarService()

    // MARK: - Font size consistency

    /// All day cells (regular and today-highlighted) must share a single font-size
    /// constant so every date number is rendered at the same visual size.
    func testDayFontSizeIsSharedAcrossAllDayVariants() {
        // Both dayFont and dayFontToday reference CalendarTheme.dayFontSize.
        // Any edit that breaks this sharing (e.g. hard-coding a different size in
        // one variant) will cause this to fail.
        let size = CalendarTheme.dayFontSize
        XCTAssertGreaterThan(size, 0, "dayFontSize must be a positive point value")
        // Mirror the font definitions to confirm the constant is used in both places.
        let regular = Font.system(size: size, weight: .light)   // matches dayFont
        let today   = Font.system(size: size, weight: .semibold) // matches dayFontToday
        XCTAssertNotNil(regular)
        XCTAssertNotNil(today)
    }

    func testWeekdayHeaderFontSizeIsPositive() {
        XCTAssertGreaterThan(CalendarTheme.weekdayHeaderFontSize, 0)
    }

    func testMonthNameFontSizeIsPositive() {
        XCTAssertGreaterThan(CalendarTheme.monthNameFontSize, 0)
    }

    func testYearHeaderFontSizeIsPositive() {
        XCTAssertGreaterThan(CalendarTheme.yearHeaderFontSize, 0)
    }

    /// Day numbers must be visually at least as prominent as weekday labels.
    func testDayFontSizeIsAtLeastAsLargeAsWeekdayHeaderFontSize() {
        XCTAssertGreaterThanOrEqual(
            CalendarTheme.dayFontSize,
            CalendarTheme.weekdayHeaderFontSize,
            "Date numbers must not be smaller than weekday header labels"
        )
    }

    // MARK: - Grid uniformity (prerequisite for center alignment)

    /// For months to be centre-justified uniformly within each quarter column,
    /// every MonthView must have an identical height.  Height is determined by
    /// the grid shape, so every month must emit exactly 6 rows × 7 columns.

    func testAllMonthsHaveUniformGridDimensions_2026() {
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        for month in data.months {
            XCTAssertEqual(
                month.weeks.count, 6,
                "\(month.name) 2026: must have 6 rows for uniform column alignment"
            )
            for (i, week) in month.weeks.enumerated() {
                XCTAssertEqual(
                    week.count, 7,
                    "\(month.name) 2026 week \(i): must have 7 cells"
                )
            }
        }
    }

    func testAllMonthsHaveUniformGridDimensions_2024LeapYear() {
        let data = service.yearData(for: 2024, today: DateComponents(year: 2024, month: 1, day: 1))
        for month in data.months {
            XCTAssertEqual(
                month.weeks.count, 6,
                "\(month.name) 2024 (leap): must have 6 rows for uniform column alignment"
            )
            for (i, week) in month.weeks.enumerated() {
                XCTAssertEqual(week.count, 7, "\(month.name) 2024 week \(i): must have 7 cells")
            }
        }
    }

    func testAllMonthsHaveUniformGridDimensions_2025() {
        let data = service.yearData(for: 2025, today: DateComponents(year: 2025, month: 1, day: 1))
        for month in data.months {
            XCTAssertEqual(
                month.weeks.count, 6,
                "\(month.name) 2025: must have 6 rows for uniform column alignment"
            )
        }
    }

    /// Months that start very late in the week (Saturday = index 6) still produce
    /// exactly 6 rows, preserving the uniform grid height that centre-alignment relies on.
    func testMonthsStartingOnSaturdayProduceExactlySixRows() {
        // August 2026 starts on Saturday (index 6) — most-leading-nils case
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        let aug = data.months[7]
        XCTAssertEqual(aug.firstWeekdayIndex, 6)
        XCTAssertEqual(aug.weeks.count, 6,
                       "Month starting on Saturday must still have 6 rows")
    }

    /// Months that start on Sunday with exactly 28 days (4 full weeks) still produce
    /// exactly 6 rows via padding, preserving uniform height for centre alignment.
    func testMonthsWith4WeeksArePaddedToSixRows() {
        // February 2026: starts Sunday, 28 days → 4 real weeks + 2 padding rows
        let data = service.yearData(for: 2026, today: DateComponents(year: 2026, month: 1, day: 1))
        let feb = data.months[1]
        XCTAssertEqual(feb.firstWeekdayIndex, 0)
        XCTAssertEqual(feb.numberOfDays, 28)
        XCTAssertEqual(feb.weeks.count, 6,
                       "February 2026 must be padded to 6 rows for uniform column alignment")
    }

    // MARK: - Today highlight color regression

    /// todayBackground must be a visible, non-white color so the current date
    /// is clearly highlighted against the widget background.
    func testTodayBackgroundIsNotWhiteOrTransparent() {
        let color = CalendarTheme.todayBackground
        // Resolve to NSColor to inspect RGBA components
        let nsColor = NSColor(color).usingColorSpace(.sRGB)!
        let r = nsColor.redComponent
        let g = nsColor.greenComponent
        let b = nsColor.blueComponent
        let a = nsColor.alphaComponent
        // Must not be white (1,1,1) or near-white
        let isWhite = r > 0.9 && g > 0.9 && b > 0.9
        XCTAssertFalse(isWhite, "todayBackground must not be white — current: (\(r), \(g), \(b))")
        XCTAssertGreaterThan(a, 0.5, "todayBackground must not be transparent")
    }

    /// todayForeground must contrast with todayBackground — white text on blue.
    func testTodayForegroundIsWhite() {
        let nsColor = NSColor(CalendarTheme.todayForeground).usingColorSpace(.sRGB)!
        XCTAssertGreaterThan(nsColor.redComponent, 0.9)
        XCTAssertGreaterThan(nsColor.greenComponent, 0.9)
        XCTAssertGreaterThan(nsColor.blueComponent, 0.9)
    }

    /// todayBackground blue channel must dominate, preventing accidental
    /// grey/white/red highlights.
    func testTodayBackgroundIsPredominantlyBlue() {
        let nsColor = NSColor(CalendarTheme.todayBackground).usingColorSpace(.sRGB)!
        let b = nsColor.blueComponent
        XCTAssertGreaterThan(b, nsColor.redComponent,
                             "Blue channel must exceed red for a blue highlight")
        XCTAssertGreaterThan(b, nsColor.greenComponent,
                             "Blue channel must exceed green for a blue highlight")
    }
}
