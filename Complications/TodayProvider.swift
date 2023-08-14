//
//  TodayProvider.swift
//  SimpleShift watchOS Widget
//
//  Created by Ollie on 04/08/2023.
//

import Foundation
import WidgetKit
import SwiftUI

struct TodayProvider: TimelineProvider {
    private var calendarManager = CalendarManager(noLoad: true)

    let appGroupContainer = UserDefaults(suiteName: AppConstants().appGroupIdentifier)

    let cornerRadius: CGFloat = 10

    func placeholder(in context: Context) -> TodayEntry {
        let display = CalendarDisplay(id: 1,
                                      date: CalendarDate(id: 1, date: Date()),
                                      shift: nil,
                                      day: "1",
                                      showOff: true,
                                      indicatorType: 1,
                                      weekday: 1)

        return TodayEntry(date: Date(), display: display)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> ()) {
        let today = getToday(Date())
        let entry = TodayEntry(date: Date(),
                               display: today)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> ()) {
        var entries: [TodayEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let today = getToday(entryDate)
            let entry = TodayEntry(date: entryDate,
                                   display: today)

            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    /// Get `CalendarDisplay` for today.
    func getToday(_ date: Date) -> CalendarDisplay {
        let calendarStore = appGroupContainer?.getData(key: "calendar",
                                                       type: [CalendarDate].self) as? [CalendarDate] ?? []

        let shiftStore = appGroupContainer?.getData(key: "shifts",
                                                    type: [Shift].self) as? [Shift] ?? []

        let today = calendarManager.getCalendarDate(date) ?? Date()

        let calDay = calendarManager.getDayFromDate(today)
        let stored = calendarStore.first { $0.date == today }
        let shift = shiftStore.first { $0.id == stored?.templateId }

        let weekday = calendarManager.getWeekday(today)

        let calendarDisplay = CalendarDisplay(id: UUID().hashValue,
                                              date: CalendarDate(id: 1, date: today),
                                              shift: shift,
                                              day: calDay,
                                              showOff: false,
                                              indicatorType: 1,
                                              weekday: weekday)

        return calendarDisplay
    }

    func getDays(_ date: Date, days: Int) -> [CalendarDisplay] {
        let calendarStore = appGroupContainer?.getData(key: "calendar",
                                                       type: [CalendarDate].self) as? [CalendarDate] ?? []

        let shiftStore = appGroupContainer?.getData(key: "shifts",
                                                    type: [Shift].self) as? [Shift] ?? []

        var selectedDate = calendarManager.getCalendarDate(date) ?? Date()
        let addDate = DateComponents(day: 1)

        var daysArray: [CalendarDisplay] = []

        for dateId in 1...days {
            let calDay = calendarManager.getDayFromDate(selectedDate)
            // Get date from app group data
            let stored = calendarStore.first { $0.date == selectedDate }
            // Get shift if applicable
            let shift = shiftStore.first { $0.id == stored?.templateId }

            let isToday = calendarManager.isToday(selectedDate)
            let weekday = calendarManager.getWeekday(selectedDate)

            let calendarDisplay = CalendarDisplay(id: UUID().hashValue,
                                                  date: CalendarDate(id: dateId, date: selectedDate),
                                                  shift: shift,
                                                  day: calDay,
                                                  showOff: false,
                                                  indicatorType: 1,
                                                  weekday: weekday)
            daysArray.append(calendarDisplay)
            guard let nextDay = calendarManager.userCalendar.date(byAdding: addDate, to: selectedDate) else { continue }
            selectedDate = nextDay
        }

        return daysArray
    }
}

struct TodayEntry: TimelineEntry {
    let date: Date
    let display: CalendarDisplay
}
