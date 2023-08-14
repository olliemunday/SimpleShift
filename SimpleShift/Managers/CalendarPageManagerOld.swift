////
////  CalendarPageManager.swift
////  SimpleShift
////
////  Created by Ollie on 12/06/2023.
////
//
//import Foundation
//import CoreData
//import SwiftUI
//import WidgetKit
//import Combine
//
//class CalendarPageManager: CalendarManager {
//
//    var watchConnectivity = WatchConnectivityManager.shared
//
//    override init(noLoad: Bool = false) {
//        setDate = Date.now
//        super.init()
//        self.setDate = getCalendarDate(date: Date.now) ?? Date.now
//        appGroupContainer = UserDefaults(suiteName: appGroupIdentifier)
//    }
//
//    // Calendar Page for view
//    @Published var calendarPage = CalendarPage(id: 0, display: "")
//
//    private var pageCache: [CalendarPage] = []
//
//    // Date that calendar is set to and array for navigation display text.
//    @Published var setDate: Date
//
//    @AppStorage("calendar_greyed", store: .standard)
//    public var greyed: Bool = true
//
//    @AppStorage("calendar_showOff", store: .standard)
//    public var showOff: Bool = false
//
//    @AppStorage("calendar_showTodayIndicator", store: .standard)
//    public var showTodayIndicator: Bool = true
//
//    @AppStorage("calendar_todayIndicatorType", store: .standard)
//    public var todayIndicatorType: Int = 1
//
//    @AppStorage("_tintColor", store: .standard)
//    public var tintColor: TintColor = .blue
//
//    let appGroupIdentifier = "group.com.olliemunday.SwiftShift"
//    var appGroupContainer: NSObject?
//
//    // Vars for selecting multiple dates.
//    @Published var selectionStart: Int = -1
//    @Published var selectionEnd: Int = -1
//    private var lastSelectionEnd: Int = -1
//
//    // Sets Calendar date and view date before month can be refreshed
//    public func setCalendarDate(date: Date) {
//        setDate = date
//    }
//
//    public func setCalendarDateToday() {
//        setDate = Date.now
//    }
//
//    // Convert Date to String for date display.
//    private func getDisplayDate(date: Date) -> String {
//        dateFormatter.timeZone = userCalendar.timeZone
//        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
//        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM")
//        let month = dateFormatter.string(from: date)
//
//        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy")
//        let year = dateFormatter.string(from: date)
//
//        return "\(month) \(year)"
//    }
//
//    // Run date fetcher on dates selected.
//    private func runDateFetcher(action: ([CD_Date]) -> ()) {
//        let beginIndex = getWeekIndexes(selectionStart)
//        let endIndex = getWeekIndexes(selectionEnd)
//
//        let start = calendarPage.weeks[beginIndex.0].days[beginIndex.1]
//        let end = calendarPage.weeks[endIndex.0].days[endIndex.1]
//
//        let fetchedResultsController = setupDateFetcher(start: start.date, end: end.date)
//
//        do {
//            try fetchedResultsController.performFetch()
//            guard let fetchedResults = fetchedResultsController.fetchedObjects else { return }
//            action(fetchedResults)
//            try viewContext.save()
//        } catch {
//
//        }
//    }
//
//}
//
//extension CalendarPageManager {
//
//    // Function to turn flat array index to 2d week indexes
//    private func getWeekIndexes(_ index: Int) -> (Int, Int) {
//        let week = Int(floor(Double(index) / 7))
//        let day = abs((week * 7) - index)
//        return (week, day)
//    }
//
//    // Set template for selected dates.
//    public func setSelectedDates(templateId: UUID) {
//        let begin = min(selectionEnd, selectionStart)
//        let end = max(selectionEnd, selectionStart)
//
//        runDateFetcher { fetchedResults in
//            for index in begin...end {
//                let (week, day) = getWeekIndexes(index)
//                let date = calendarPage.weeks[week].days[day]
//
//                if let existing = fetchedResults.first(where: { $0.date == date.date }) {
//                    existing.templateId = templateId
//                    continue
//                }
//
//                let newDate = CD_Date(context: viewContext)
//                newDate.date = date.date
//                newDate.templateId = templateId
//            }
//        }
//        cacheCalendarPages()
//    }
//
//    // Start the date selection.
//    public func setSelectionStart(id: Int) {
//        if id > 41 { return }
//        selectionStart = id
//        selectionEnd = id
//        lastSelectionEnd = id
//        let (week, day) = getWeekIndexes(id)
//        calendarPage.weeks[week].days[day].selected = true
//    }
//
//    // End the date selection. Used to update what dates are selected.
//    public func setSelectionEnd(id: Int) {
//        if id > 41 { return }
//        selectionEnd = id
//        if lastSelectionEnd == selectionEnd { return }
//        lastSelectionEnd = selectionEnd
//        deselectAll()
//
//        let begin = min(selectionEnd, selectionStart)
//        let end = max(selectionEnd, selectionStart)
//
//        let beginIndex = getWeekIndexes(begin)
//        let endIndex = getWeekIndexes(end)
//
//        for week in beginIndex.0..<(endIndex.0 + 1) {
//            let start = week == beginIndex.0 ? beginIndex.1 : 0
//            let end = week == endIndex.0 ? endIndex.1 : 6
//
//            for day in start...end {
//                calendarPage.weeks[week].days[day].selected = true
//            }
//        }
//    }
//
//    // Set all dates to unselected
//    public func deselectAll() {
//        for week in 0..<calendarPage.weeks.count {
//            for day in 0..<calendarPage.weeks[week].days.count {
//                calendarPage.weeks[week].days[day].selected = false
//            }
//        }
//    }
//
//    // Delete template(s) from selected dates.
//    public func deleteSelectedDates() {
//        runDateFetcher { fetchedResults in
//            for result in fetchedResults { viewContext.delete(result) }
//        }
//        cacheCalendarPages()
//    }
//
//    public func setPatternFromDate(pattern: Pattern?, repeatCount: Int = 1) async {
//        guard let weekArray = pattern?.weekArray else { return }
//
//        var unpacked = [UUID?]()
//
//        for week in weekArray {
//            for shift in week.shiftArray {
//                if let shiftId = shift.shift {
//                    unpacked.append(shiftId)
//                } else {
//                    unpacked.append(nil)
//                }
//            }
//        }
//        let startIndex = getWeekIndexes(selectionStart)
//        let startDate = calendarPage.weeks[startIndex.0].days[startIndex.1].date
//
//        guard let endDate = userCalendar.date(byAdding: .day, value: (unpacked.count * repeatCount), to: startDate) else { return }
//        let fetchedResultsController = setupDateFetcher(start: startDate, end: endDate)
//        do {
//            try fetchedResultsController.performFetch()
//            guard let results = fetchedResultsController.fetchedObjects else { return }
//            var workingDate = startDate
//            for _ in 0..<repeatCount {
//                for shiftId in unpacked {
//                    if let exist = results.first(where: {$0.date == workingDate}) {
//                        exist.templateId = shiftId
//                    } else {
//                        let newDate = CD_Date(context: viewContext)
//                        newDate.templateId = shiftId
//                        newDate.date = workingDate
//                    }
//                    workingDate = userCalendar.date(byAdding: .day, value: 1, to: workingDate) ?? workingDate
//                }
//            }
//            try viewContext.save()
//        } catch {
//            return
//        }
//        
//        cacheCalendarPages()
//        DispatchQueue.main.async {
//            self.setMonth()
//        }
//    }
//}
//
//extension CalendarPageManager {
//
//    // Split dates into weeks.
//    private func splitDatesArray(_ dates: [CalendarDate]) -> [[CalendarDate]] {
//        let stride = stride(from: 0, to: dates.count, by: 7).map {
//            Array(dates[$0..<min($0 + 7, dates.count)])
//        }
//
//        return stride
//    }
//
//    // Load CalendarPage from setDate.
//    public func setMonth() {
//        guard let page = getCachedCalendarPage(date: setDate) else {
//            calendarPage = getCalendarPage(date: setDate)
//            return
//        }
//        calendarPage = page
//        cacheCalendarPages()
//    }
//
//    // Iterate the current date by amount of months
//    public func iterateMonth(value: Int) {
//        var addDate = DateComponents()
//        addDate.month = value
//        guard let resultMonth = userCalendar.date(byAdding: addDate, to: setDate) else { return }
//        setCalendarDate(date: resultMonth)
//    }
//
//    // Is Date the same month as setDate.
//    public func isSameMonth(date: Date) -> Bool {
//        let dateComp = userCalendar.dateComponents([.month, .year], from: date)
//        let setDateComp = userCalendar.dateComponents([.month, .year], from: setDate)
//
//        if dateComp == setDateComp { return true } else { return false }
//    }
//
//    // Return array of dates from the first weekday before/on the 1st of the month.
//    private func getMonth(date: Date) -> [CalendarDate] {
//        var selectedDate = getStartDate(date: date)
//        var dates: [CalendarDate] = []
//        // Create date component to iterate one day.
//        var addDate = DateComponents()
//        addDate.day = 1
//        var firstBool: Bool = false
//        var greyed: Bool = true
//
//        for dateId in 0...41 {
//            // Get the day number for each day.
//            let calDateComponents = userCalendar.dateComponents([.day], from: selectedDate)
//            guard let calDay = calDateComponents.day else { continue }
//
//            if (calDay == 1) {
//                if (firstBool) { greyed = true }
//                else { firstBool = true; greyed = false }
//            }
//
//            let stored = dateStore.first(where: {$0.date == selectedDate})
//            let descriptor = CalendarDate(id: dateId, date: selectedDate, day: String(calDay), templateId: stored?.templateId, greyed: greyed)
//
//            // Add to the collection to be returned.
//            dates.append(descriptor)
//
//            // Iterate the day for the next loop
//            guard let nextDay = userCalendar.date(byAdding: addDate, to: selectedDate) else { continue }
//            selectedDate = nextDay
//        }
//
//        return dates
//    }
//
//    private func getCalendarPage(date: Date) -> CalendarPage {
//        let display = getDisplayDate(date: date)
//        var calendarPage = CalendarPage(id: display.hashValue,
//                                        display: display)
//        var selectedDate = getStartDate(date: date)
//
//        var addDate = DateComponents()
//        addDate.day = 1
//        var isFirst: Bool = false
//        var isGreyed: Bool = true
//
//        for dateId in 0..<42 {
//            if dateId % 7 == 0 { calendarPage.weeks.append(CalendarWeek(id: (dateId/7),
//                                                                        days: [])) }
//
//            // Get the day number for each day.
//            let dateComponents = userCalendar.dateComponents([.day], from: selectedDate)
//            guard let calendarDay = dateComponents.day else { continue }
//
//            if (calendarDay == 1) {
//                if (isFirst) { isGreyed = true }
//                else { isFirst = true; isGreyed = false }
//            }
//
//            let stored = dateStore.first(where: {$0.date == selectedDate})
//            let calendarDate = CalendarDate(id: dateId,
//                                          date: selectedDate,
//                                          day: String(calendarDay),
//                                          templateId: stored?.templateId,
//                                          greyed: isGreyed)
//
//            if calendarPage.weeks.count > 0 {
//                calendarPage.weeks[calendarPage.weeks.count - 1].days.append(calendarDate)
//            }
//
//            // Iterate the day for the next loop
//            guard let nextDay = userCalendar.date(byAdding: addDate, to: selectedDate)
//            else { continue }
//            selectedDate = nextDay
//        }
//
//        return calendarPage
//    }
//
//    private func cacheCalendarPages() {
//        Task {
//            pageCache.removeAll()
//            for iter in -2...2 {
//                if iter == 0 { continue }
//                let dateComp = DateComponents(month: iter)
//                guard let iterDate = userCalendar.date(byAdding: dateComp, to: setDate) else { continue }
//
//                let page = getCalendarPage(date: iterDate)
//                pageCache.append(page)
//            }
//        }
//    }
//
//    private func getCachedCalendarPage(date: Date) -> CalendarPage? {
//        let display = getDisplayDate(date: date)
//        return pageCache.first(where: { $0.id == display.hashValue })
//    }
//}
//
//extension CalendarPageManager {
//    internal func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        Task {
//            guard let shifts = fetchedResultsController.fetchedObjects else { return }
//            DispatchQueue.main.async { self.dateStore = self.unpackShifts(shifts: shifts) }
//
//            try await Task.sleep(for: .milliseconds(100))
//            let page = getCalendarPage(date: setDate)
//
//            DispatchQueue.main.async { self.calendarPage = page }
//            try await Task.sleep(for: .seconds(1))
//
//            let calendar = self.packageForWatch()
//            watchConnectivity.transferData(["calendar" : calendar as Any])
//
//            let widgetData = self.packageForWidget()
//            appGroupContainer?.setValue(widgetData, forKey: "calendar")
//        }
//    }
//}
//
//// Hold the data to share between the Calendar and Patterns tab.
//
//class CalendarPattern: ObservableObject {
//    // Variable to hold pattern that is being applied.
//    public var applyingPattern: Pattern?
//    @Published var isApplyingPattern: Bool = false
//
//    public func deselectPattern() {
//        applyingPattern = nil
//        isApplyingPattern = false
//    }
//}
