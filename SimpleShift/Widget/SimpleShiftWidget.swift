//
//  SimpleShiftWidget.swift
//  SimpleShiftWidget
//
//  Created by Ollie on 14/05/2023.
//

import WidgetKit
import SwiftUI
import CoreData


struct Provider: TimelineProvider {
    private var calendarManager = CalendarManager(noLoad: true)

    @Environment(\.colorScheme) private var colorScheme

    let appGroupContainer = UserDefaults(suiteName: AppConstants().appGroupIdentifier)

    func placeholder(in context: Context) -> WidgetEntry {
        createWidgetEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        let entry = createWidgetEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [WidgetEntry] = []
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let nextDay = Calendar.autoupdatingCurrent.startOfDay(for: currentDate).addingTimeInterval(24 * 60 * 60)
        let weekday = getWeekday() ?? Calendar.current.firstWeekday
        calendarManager.weekday = weekday

        for hourOffset in 0 ..< 6 {
            let dateRounded = hourOffset == 0 ? currentDate : currentDate.roundToNearestHour()
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset * 2, to: dateRounded)!
            guard let weeks = getWeeks(currentDate) else { return }
            let entry = WidgetEntry(date: entryDate,
                                    weeks: weeks,
                                    weekday: weekday)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .after(nextDay))
        completion(timeline)
    }

    func createWidgetEntry(date: Date) -> WidgetEntry {
        let entry = WidgetEntry(date: Date(),
                                weeks: getWeeks(date) ?? [],
                                weekday: calendarManager.weekday)
        return entry
    }

    /// Function to check if a date is Weekday.
    func isWeekday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: date) == calendarManager.weekday
    }

    func getWeekday() -> Int? {
        appGroupContainer?.integer(forKey: "calendar_weekday")
    }

    func getWeeks(_ date: Date) -> [CalendarWeek]? {
        let calendarStore = appGroupContainer?.getData(key: "calendar",
                                                       type: [CalendarDate].self) as? [CalendarDate] ?? []

        let shiftStore = appGroupContainer?.getData(key: "shifts",
                                                    type: [Shift].self) as? [Shift] ?? []
        
        let today = calendarManager.getCalendarDate(date) ?? Date()
        let showOff = appGroupContainer?.bool(forKey: "calendar_showOff") ?? false
        let weekday = appGroupContainer?.integer(forKey: "calendar_weekday") ?? 1
        calendarManager.weekday = weekday

        // Start with the first day of the week.
        var selectedDate = calendarManager.getFirstWeekday(today)
        let addDate = DateComponents(day: 1)

        var weekArray: [CalendarWeek] = []
        var daysCollected: [CalendarDisplay] = []

        for dateId in 1...(28) {
            let calDay = calendarManager.getDayFromDate(selectedDate)
            // Get date from app group data
            let stored = calendarStore.first(where: {$0.date == selectedDate})
            // Get shift if applicable
            let shift = shiftStore.first { $0.id == stored?.templateId }

            let isToday = calendarManager.isToday(selectedDate)

            let calendarDisplay = CalendarDisplay(id: UUID().hashValue,
                                                  date: CalendarDate(id: dateId, date: selectedDate),
                                                  shift: shift,
                                                  day: calDay,
                                                  isGreyed: false,
                                                  showOff: showOff,
                                                  indicatorType: isToday ? 1 : 0)
            daysCollected.append(calendarDisplay)

            if dateId % 7 == 0 {
                let week = CalendarWeek(id: UUID().hashValue,
                                        days: daysCollected)
                weekArray.append(week)
                daysCollected.removeAll()
            }

            // Iterate the day for the next loop
            guard let nextDay = calendarManager.userCalendar.date(byAdding: addDate, to: selectedDate) else { continue }
            selectedDate = nextDay
        }

        return weekArray
    }

}


struct SimpleShiftWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily

    var entry: Provider.Entry

    let title: String
    let spacing: Double
    let padding: Double

    @AppStorage("_tintColor", store: .init(suiteName: AppConstants().appGroupIdentifier))
    public var tintColor: TintColor = .blue

    let weekdayUtil = WeekdayUtil()

    var body: some View {
        VStack(alignment: .leading ,spacing: 0) {
            topSection
                .padding(.vertical, padding / 2)
            weekdayBar
                .frame(height: 24)
            displaySection
                .padding(.bottom, padding)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .widgetBackground(color: Color("WidgetBackground"))
        .widgetURL(URL(string: "simpleshift://now/"))
    }

    private var topSection: some View {
        HStack(alignment: .top, spacing: 0) {
            Text(title)
                .font(.title3)
                .dynamicTypeSize(.small ... .xLarge)
                .bold()
            Spacer()
        }
    }

    private var weekdayBar: some View {
        return HStack(spacing: spacing) {
            ForEach(weekdayUtil.getWeekdays(start: entry.weekday - 1), id: \.self) { wkday in
                Rectangle()
                    .foregroundStyle(.clear)
                    .overlay(
                        Text(wkday)
                            .font(.system(.body, design: .rounded))
                            .dynamicTypeSize(.medium ... .xLarge)
                            .bold()
                    )
            }
        }
    }

    private var displaySection: some View {
        Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
            ForEach(weeks) { week in
                GridRow {
                    ForEach(week.days) { day in
                        DateView(id: day.id,
                                 calendarDisplay: day,
                                 tintColor: tintColor,
                                 customText: .caption,
                                 cornerRadius: 12,
                                 dayFontSize: 12)
                    }
                }
            }
        }
    }

    private var weeks: ArraySlice<CalendarWeek> {
        entry.weeks.prefix(widgetFamily == .systemMedium ? 1 : 4)
    }

}

struct ThisWeekWidget: Widget {
    let kind: String = "SimpleShiftWidgetThisWeek"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SimpleShiftWidgetEntryView(entry: entry, title: "This Week", spacing: 2.0, padding: 6.0)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("This Week")
        .description("Shows the current week from the Shift Calendar.")
        .contentMarginsDisabledIfAvailable()
    }
}

struct UpcomingWidget: Widget {
    let kind: String = "SimpleShiftWidgetUpcoming"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SimpleShiftWidgetEntryView(entry: entry, title: "Upcoming Shifts", spacing: 2.0, padding: 0)
        }
        .supportedFamilies([.systemLarge])
        .configurationDisplayName("Upcoming Shifts")
        .description("Shows four weeks of upcoming shifts.")
        .contentMarginsDisabledIfAvailable()
    }
}

struct WidgetEntry: TimelineEntry {
    let date: Date
    let weeks: [CalendarWeek]
    let weekday: Int
}

let exampleEntry = WidgetEntry(date: Date(),
                               weeks: [emptyWeek, emptyWeek, emptyWeek],
                               weekday: 1)

let emptyWeek = CalendarWeek(id: 0, days: [
    CalendarDisplay(id: 0, date: CalendarDate(id: 0, date: Date()), shift: nil, day: "1", isGreyed: false, showOff: false, indicatorType: 0),
    CalendarDisplay(id: 1, date: CalendarDate(id: 1, date: Date()), shift: nil, day: "2", isGreyed: false, showOff: false, indicatorType: 0),
    CalendarDisplay(id: 2, date: CalendarDate(id: 2, date: Date()), shift: nil, day: "3", isGreyed: false, showOff: false, indicatorType: 0),
    CalendarDisplay(id: 3, date: CalendarDate(id: 3, date: Date()), shift: nil, day: "4", isGreyed: false, showOff: false, indicatorType: 0),
    CalendarDisplay(id: 4, date: CalendarDate(id: 4, date: Date()), shift: nil, day: "5", isGreyed: false, showOff: false, indicatorType: 0),
    CalendarDisplay(id: 5, date: CalendarDate(id: 5, date: Date()), shift: nil, day: "6", isGreyed: false, showOff: false, indicatorType: 0),
    CalendarDisplay(id: 6, date: CalendarDate(id: 6, date: Date()), shift: nil, day: "7", isGreyed: false, showOff: false, indicatorType: 0)
])

struct SimpleShiftWidget_Previews: PreviewProvider {
    static var previews: some View {
        SimpleShiftWidgetEntryView(entry: exampleEntry, title: "This Week", spacing: 2.0, padding: 6.0)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            
    }
}
