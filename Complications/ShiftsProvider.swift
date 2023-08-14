////
////  ShiftsProvider.swift
////  SimpleShift watchOS Widget
////
////  Created by Ollie on 07/08/2023.
////
//
//import Foundation
//import SwiftUI
//import WidgetKit
//
//
//struct ShiftsProvider: TimelineProvider {
//    private var calendarManager = CalendarManager(noLoad: true)
//
//    let appGroupContainer = UserDefaults(suiteName: AppConstants().appGroupIdentifier)
//
//    let cornerRadius: CGFloat = 10
//
//    func placeholder(in context: Context) -> ShiftsEntry {
//        ShiftsEntry(date: Date(),
//                   display: getDays(Date(), days: 2) )
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (ShiftsEntry) -> ()) {
//        let days = getDays(Date(), days: 2)
//        let entry = ShiftsEntry(date: Date(),
//                               display: days)
//        completion(entry)
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<ShiftsEntry>) -> ()) {
//        var entries: [ShiftsEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let days = getDays(Date(), days: 2)
//            let entry = ShiftsEntry(date: entryDate,
//                                   display: days)
//
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
//
//    func getDays(_ date: Date, days: Int) -> [CalendarDisplay] {
//        let calendarStore = appGroupContainer?.getData(key: "calendar",
//                                                       type: [CalendarDate].self) as? [CalendarDate] ?? []
//
//        let shiftStore = appGroupContainer?.getData(key: "shifts",
//                                                    type: [Shift].self) as? [Shift] ?? []
//
//        var selectedDate = calendarManager.getCalendarDate(date) ?? Date()
//        let addDate = DateComponents(day: 1)
//
//        var daysArray: [CalendarDisplay] = []
//
//        for dateId in 1...days {
//            let calDay = calendarManager.getDayFromDate(selectedDate)
//            // Get date from app group data
//            let stored = calendarStore.first { $0.date == selectedDate }
//            // Get shift if applicable
//            let shift = shiftStore.first { $0.id == stored?.templateId }
//
//            let isToday = calendarManager.isToday(selectedDate)
//            let weekday = calendarManager.getWeekday(selectedDate)
//
//            let calendarDisplay = CalendarDisplay(id: UUID().hashValue,
//                                                  date: CalendarDate(id: dateId, date: selectedDate),
//                                                  shift: shift,
//                                                  day: calDay,
//                                                  showOff: false,
//                                                  indicatorType: isToday ? 1 : 0,
//                                                  weekday: weekday)
//            daysArray.append(calendarDisplay)
//            guard let nextDay = calendarManager.userCalendar.date(byAdding: addDate, to: selectedDate) else { continue }
//            selectedDate = nextDay
//        }
//
//        return daysArray
//    }
//}
//
//struct ShiftsEntry: TimelineEntry {
//    let date: Date
//    let display: [CalendarDisplay]
//}
