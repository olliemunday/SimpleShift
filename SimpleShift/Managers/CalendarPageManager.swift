//
//  CalendarPageManager.swift
//  SimpleShift
//
//  Created by Ollie on 12/06/2023.
//

import Foundation
import CoreData
import SwiftUI
import Combine
import BackgroundTasks
#if canImport(WidgetKit)
import WidgetKit
#endif

class CalendarPageManager: CalendarManager {

    #if canImport(WidgetKit) && canImport(WatchConnectivity)
    var watchConnectivity = WatchConnectivityManager.shared
    #endif

    @Published var calendarDates: [[CalendarDate]] = []

    var display: String = ""

    var calendarDate = Date()

    /// Vars for selecting multiple dates.
    @Published var selectionStart: Int = -1
    @Published var selectionEnd: Int = -1
    var lastSelectionEnd: Int = -1

    override init(noLoad: Bool = false) {
        super.init()
        #if !targetEnvironment(simulator)
        registerBackgroundTask()
        scheduleBackgroundTask()
        #endif
    }

    /// Convert `Date` to `String` for date display.
    private func getDisplayDate(date: Date) -> String {
        dateFormatter.timeZone = userCalendar.timeZone
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM")
        let month = dateFormatter.string(from: date)

        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy")
        let year = dateFormatter.string(from: date)

        return "\(month) \(year)"
    }

}

extension CalendarPageManager {

    /// Function to turn flat array index to 2d week indexes
    private func getWeekIndexes(_ index: Int) -> (Int, Int) {
        let week = Int(floor(Double(index) / 7))
        let day = abs((week * 7) - index)
        return (week+1, day)
    }

    /// Set template for selected dates.
    public func setSelectedDates(templateId: UUID?) {
        let start = min(selectionEnd, selectionStart)
        let end = max(selectionEnd, selectionStart)

        let startIndex = getWeekIndexes(start)
        let endIndex = getWeekIndexes(end)

        let startDate = calendarDates[startIndex.0][startIndex.1].date
        let endDate = calendarDates[endIndex.0][endIndex.1].date

        runDateFetcher(start: startDate,
                       end: endDate) { fetchedResults in
            for index in start...end {
                let (week, day) = getWeekIndexes(index)
                let date = calendarDates[week][day]

                if let existing = fetchedResults.first(where: { $0.date == date.date }) {
                    existing.templateId = templateId
                    continue
                }

                let newDate = CD_Date(context: viewContext)
                newDate.date = date.date
                newDate.templateId = templateId
            }
        }

    }

    /// Start the date selection.
    public func setSelectionStart(id: Int) {
        if id > 41 { return }
        selectionStart = id
        selectionEnd = id
        lastSelectionEnd = id
        let (week, day) = getWeekIndexes(id)
        calendarDates[week][day].selected = true
    }

    /// End the date selection. Used to update dates that are selected.
    public func setSelectionEnd(id: Int) {
        if id > 41 { return }
        selectionEnd = id
        if lastSelectionEnd == selectionEnd { return }
        lastSelectionEnd = selectionEnd
        deselectAll()

        let begin = min(selectionEnd, selectionStart)
        let end = max(selectionEnd, selectionStart)

        let beginIndex = getWeekIndexes(begin)
        let endIndex = getWeekIndexes(end)

        for week in beginIndex.0..<(endIndex.0 + 1) {
            let start = week == beginIndex.0 ? beginIndex.1 : 0
            let end = week == endIndex.0 ? endIndex.1 : 6

            for day in start...end {
                calendarDates[week][day].selected = true
            }
        }
    }

    /// Set all dates to unselected.
    public func deselectAll() {
        for week in 0..<calendarDates.count {
            for day in 0..<calendarDates[week].count {
                calendarDates[week][day].selected = false
            }
        }
    }

    /// Reset selection variables.
    public func resetSelection() {
        selectionEnd = -1
        selectionStart = -1
    }

    /// Delete template(s) from selected dates.
    public func deleteSelectedDates() {
        setSelectedDates(templateId: nil)
    }

    /// Set the pattern starting from the selected date.
    public func setPatternFromDate(pattern: Pattern?, repeatCount: Int = 1) async {
        guard let weekArray = pattern?.weekArray else { return }

        var unpacked = [UUID?]()

        for week in weekArray {
            for shift in week.shiftArray {
                if let shiftId = shift.shift {
                    unpacked.append(shiftId)
                } else {
                    unpacked.append(nil)
                }
            }
        }
        let (week, day) = getWeekIndexes(selectionStart)
        let startDate = calendarDates[week][day].date

        guard let endDate = userCalendar.date(byAdding: .day, value: (unpacked.count * repeatCount), to: startDate) else { return }
        let fetchedResultsController = setupDateFetcher(start: startDate, end: endDate)
        do {
            try fetchedResultsController.performFetch()
            guard let results = fetchedResultsController.fetchedObjects else { return }
            var workingDate = startDate
            for _ in 0..<repeatCount {
                for shiftId in unpacked {
                    if let exist = results.first(where: {$0.date == workingDate}) {
                        exist.templateId = shiftId
                    } else {
                        let newDate = CD_Date(context: viewContext)
                        newDate.templateId = shiftId
                        newDate.date = workingDate
                    }
                    workingDate = userCalendar.date(byAdding: .day, value: 1, to: workingDate) ?? workingDate
                }
            }
            try viewContext.save()
        } catch {
            return
        }

        DispatchQueue.main.async {
            self.setMonth(self.calendarDate)
        }
    }

    /// Update calendarPage with a date
    public func setMonth(_ date: Date) {
        // Get our internal GMT calendar date so we can be independant of timezones.
        if let date = getCalendarDate(date) { calendarDate = date }
        // Update the page
        updateMonth()
    }

    /// Update published variable
    private func updateMonth() {
        calendarDates = getCalendarArrays(calendarDate)
    }

    /// Get arrays representing the weeks of the calendar.
    private func getCalendarArrays(_ date: Date) -> [[CalendarDate]] {
        display = getDisplayDate(date: date)

        var arrays: [[CalendarDate]] = []
        var selectedDate = getStartDate(date)

        var addDate = DateComponents()
        addDate.day = 1

        var currentArray: [CalendarDate] = []
        for dateId in 0..<42 {
            if dateId % 7 == 0 {
                arrays.append(currentArray)
                currentArray.removeAll()
            }

            let stored = dateStore.first(where: {$0.date == selectedDate})
            let calendarDate = CalendarDate(id: dateId,
                                            date: selectedDate,
                                            templateId: stored?.templateId)

            currentArray.append(calendarDate)

            // Iterate the day for the next loop
            guard let nextDay = userCalendar.date(byAdding: addDate, to: selectedDate)
            else { continue }
            selectedDate = nextDay
        }
        arrays.append(currentArray)

        return arrays
    }
    
}

extension CalendarPageManager {
    internal func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Task {
            guard let dates = fetchedResultsController.fetchedObjects else { return }

            DispatchQueue.main.async { self.dateStore = self.unpackDates(dates) }
            try await Task.sleep(for: .milliseconds(100))
            DispatchQueue.main.async { self.updateMonth() }

            #if canImport(WidgetKit)
            if let calendar = packageForWatch() {
                watchConnectivity.transferData(key: "calendar", data: calendar)
            }
            #endif
            updateAppGroup()
        }
    }
}

extension CalendarPageManager {

    /// Register the background task so it can be scheduled.
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "widgetTask", using: nil) { task in
            self.refreshAppContents()
            task.setTaskCompleted(success: true)
            self.scheduleBackgroundTask()
        }
    }

    /// Update the App Groups & Watch with relevent slice of data to reduce amount of data widget will process.
    func refreshAppContents() {
        let container = UserDefaults(suiteName: "group.com.olliemunday.SwiftShift")

        // Update App Group with latest relevent data.
        if let dates = fetchRecentDates() {
            let package = encodeDates(dates: dates)
            container?.setValue(package, forKey: "calendar")
            container?.setValue(Date().description, forKey: "bgTaskTime")
        }

        #if canImport(WidgetKit) && canImport(WatchConnectivity)
        // Update Watch with latest relevent data.
        if let calendar = packageForWatch() {
            watchConnectivity.transferData(key: "calendar", data: calendar)
        }
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    /// Fetch recent `calendarDate` instances from CoreData. Function runs independantly via thread.
    func fetchRecentDates() -> [CalendarDate]? {
        var calendar = Calendar.current
        calendar.timeZone = .gmt
        var savedDates: [CalendarDate] = []

        // Get first day of this week and add 40 days to capture relevent data.
        guard let today = getToday() else { return nil }
        let start = getFirstWeekday(today)
        let addDays = DateComponents(day: 46)
        guard let end = calendar.date(byAdding: addDays, to: start) else { return nil }

        var index = 0

        // Query & collect CoreData store for any saved shifts.
        runDateFetcher(start: start, end: end) { dates in
            for date in dates {
                guard let actualDate = date.date else { continue }
                let newDate = CalendarDate(id: index,
                                           date: actualDate,
                                           templateId: date.templateId)
                savedDates.append(newDate)
                index += 1
            }
        }

        let sorted = savedDates.sorted(by: { $0.date < $1.date })

        return sorted
    }

    /// Schedule background task to run once a week.
    func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: "widgetTask")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * 6)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

}

// Hold the data to share between the Calendar and Patterns tab.

class CalendarPattern: ObservableObject {
    // Variable to hold pattern that is being applied.
    public var applyingPattern: Pattern?
    @Published var isApplyingPattern: Bool = false

    public func deselectPattern() {
        applyingPattern = nil
        isApplyingPattern = false
    }
}
