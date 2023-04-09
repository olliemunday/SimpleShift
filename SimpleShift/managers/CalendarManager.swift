//
//  CalendarManager.swift
//  SwiftShift
//
//  Created by Ollie on 10/09/2022.
//

import Foundation
import CoreData
import SwiftUI
import WidgetKit
import Combine


// CalendarManager creates DateDescriptor instances to be displayed by a view.
class CalendarManager: NSObject, ObservableObject, @unchecked Sendable {

    private var persistenceController: PersistenceController
    private var viewContext: NSManagedObjectContext { persistenceController.container.viewContext }

    private var fetchedResultsController: NSFetchedResultsController<CD_Date>
    private var userCalendar = Calendar.current

    // Date/Shift working array.
    var dateStore: [CalendarDate] = []

    // Array for UI View to display each day of the month.
    @Published var datesPage: CalendarPage = CalendarPage(id: 0, dates: [])

    // Date that calendar is set to and array for navigation display text.
    @Published var setDate: Date
    
    // Array used for display.
    @Published var dateDisplay: String = ""

    @AppStorage("calendar_weekday", store: .standard)
    public var weekday: Int = Calendar.current.firstWeekday

    @AppStorage("calendar_greyed", store: .standard)
    public var greyed: Bool = true

    @AppStorage("calendar_showOff", store: .standard)
    public var showOff: Bool = false

    @AppStorage("calendar_showTodayIndicator", store: .standard)
    public var showTodayIndicator: Bool = true

    @AppStorage("calendar_todayIndicatorType", store: .standard)
    public var todayIndicatorType: Int = 1

    @AppStorage("calendar_accentColor", store: .standard)
    public var accentColor: Color = .blue

    // Vars for selecting multiple dates.
    @Published var selectionStart: Int = -1
    @Published var selectionEnd: Int = -1
    private var lastSelectionEnd: Int = -1

    // Variable to hold pattern that is being applied.
    public var applyingPattern: Pattern?
    @Published var isApplyingPattern: Bool = false

    init(_ persistenceController: PersistenceController) {
        // Use GMT timezone for the local calendar so change of timezones do not affect the underlying Date.
        // We only ever need to compare against the day of the month with can be obtained from the current calendar.
        self.userCalendar.timeZone = .gmt
        self.setDate = Date.now
        self.persistenceController = persistenceController
        let request = CD_Date.fetchRequest()
        request.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: persistenceController.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        super.init()
        self.setDate = getCalendarDate(date: Date.now) ?? Date.now
        fetchedResultsController.delegate = self
        self.dateDisplay = getDisplayDate(date: Date.now)
        // Load in saved shift data
        self.fetchShifts()


        NotificationCenter.default.addObserver(self, selector: #selector(reinitializeCoreData), name: NSNotification.Name("CoreDataRefresh"), object: nil)

    }

    /// Reload Core Data ViewContext when Container is reloaded
    @objc func reinitializeCoreData() {
        let request = CD_Date.fetchRequest()
        request.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
        self.fetchShifts()
    }

    public func getCalendarDate(date: Date) -> Date? {
        let defaultCalendar = Calendar.current
        let dateComp = defaultCalendar.dateComponents([.month, .year], from: date)

        return userCalendar.date(from: dateComp)
    }

    // Sets Calendar date and view date before month can be refreshed
    public func setCalendarDate(date: Date) {
        setDate = date
        setViewDate(date: date)
    }

    public func setCalendarDateToday() {
        let now = Date.now
        setDate = now
        setViewDate(date: now)
    }

    public func isToday(date: Date) -> Bool {
        let defaultCalendar = Calendar.autoupdatingCurrent

        let nowComps = defaultCalendar.dateComponents([.year, .month, .day], from: Date.now)
        let dateComps = userCalendar.dateComponents([.year, .month, .day], from: date)

        return dateComps == nowComps
    }

    // Set template for selected dates.
    public func setSelectedDates(templateId: UUID) {
        let begin = min(selectionEnd, selectionStart)
        let end = max(selectionEnd, selectionStart)


        runDateFetcher { fetchedResults in
            for index in begin...end {
                let date = datesPage.dates[index]

                if let existing = fetchedResults.first(where: { $0.date == date.date }) {
                    existing.templateId = templateId
                    continue
                }

                let newDate = CD_Date(context: viewContext)
                newDate.date = date.date
                newDate.templateId = templateId
            }
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    public func setPatternFromDate(repeatCount: Int = 1) {
        guard let weekArray = applyingPattern?.weekArray else { return }

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
        if !datesPage.dates.indexExists(index: selectionStart) { return }
        let startDate = datesPage.dates[selectionStart].date
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

    }

    // Delete template(s) from selected dates.
    public func deleteSelectedDates() {
        runDateFetcher { fetchedResults in
            for result in fetchedResults { viewContext.delete(result) }
        }
    }

    // Iterate the current date by amount of months
    public func iterateMonth(value: Int) {
        var addDate = DateComponents()
        addDate.month = value
        guard let resultMonth = userCalendar.date(byAdding: addDate, to: setDate) else { return }
        setCalendarDate(date: resultMonth)
    }

    // Iterate Month but do not update the display text.
    public func iterateMonthNoDisplay(value: Int) {
        var addDate = DateComponents()
        addDate.month = value
        guard let resultMonth = userCalendar.date(byAdding: addDate, to: setDate) else { return }
        setDate = resultMonth
    }

    public func setSelectionStart(id: Int) {
        selectionStart = id
        selectionEnd = id
        lastSelectionEnd = id
        datesPage.dates[selectionStart].selected = true
    }

    public func setSelectionEnd(id: Int) {
        selectionEnd = id
        if lastSelectionEnd == selectionEnd { return }
        lastSelectionEnd = selectionEnd
        self.deselectAll()
        let begin = min(selectionEnd, selectionStart)
        let end = max(selectionEnd, selectionStart)
        for index in begin...end {
            if index < 0 { continue }
            self.datesPage.dates[index].selected = true
        }
    }

    // Reset selection variables
    public func finishSelect() {
        deselectAll()
    }

    // Return number of day as string.
    private func getDayFromDate(date: Date) -> String {
        String(userCalendar.dateComponents([.day], from: date).day ?? 0)
    }

    // Returns 1st day of the month.
    private func getFirstOfMonth(date: Date) -> Date {
        var dateComponents = userCalendar.dateComponents([.year, .month, .day, .weekday], from: date)
        dateComponents.day = 1
        return userCalendar.date(from: dateComponents)!
    }

    // Strip date back to Day, Month, Year
    private func getCleanDate(date: Date) -> Date {
        return userCalendar.date(from: userCalendar.dateComponents([.year, .month, .day], from: date))!
    }

    // Get first day of the week.
    private func getWeekday(date: Date) -> Date {
        let dateEditing = userCalendar.dateComponents([.weekday], from: date)
        guard let wkday = dateEditing.weekday else {
            return date
        }
        if wkday == weekday { return date } else {
            var subtract = DateComponents()
            let diff = wkday - weekday
            subtract.day = ( diff > 0 ? -diff : -7-diff )
            return userCalendar.date(byAdding: subtract, to: date) ?? date
        }
    }

    // Get first monday of the first week of the month in date.
    private func getStartDate(date: Date) -> Date {
        let clean = getCleanDate(date: date)
        let first = getFirstOfMonth(date: clean)
        return getWeekday(date: first)
    }

    // Return array of dates from the first weekday before/on the 1st of the month.
    private func getMonth(date: Date) -> [CalendarDate] {
        var selectedDate = getStartDate(date: date)
        var dates: [CalendarDate] = []
        // Create date component to iterate one day.
        var addDate = DateComponents()
        addDate.day = 1
        var firstBool: Bool = false
        var greyed: Bool = true
        
        for dateId in 0...41 {
            // Get the day number for each day.
            let calDateComponents = userCalendar.dateComponents([.day], from: selectedDate)
            guard let calDay = calDateComponents.day else { continue }
            
            if (calDay == 1) {
                if (firstBool) { greyed = true }
                else { firstBool = true; greyed = false }
            }

            let stored = dateStore.first(where: {$0.date == selectedDate})
            let descriptor = CalendarDate(id: dateId, date: selectedDate, day: String(calDay), templateId: stored?.templateId, greyed: greyed)
        
            // Add to the collection to be returned.
            dates.append(descriptor)
            
            // Iterate the day for the next loop
            guard let nextDay = userCalendar.date(byAdding: addDate, to: selectedDate) else { continue }
            selectedDate = nextDay
        }
        
        return dates
    }

    // Push the current date to the display var
    public func updateViewDate() {
        dateDisplay = getDisplayDate(date: setDate)
    }

    private func setViewDate(date: Date) {
        dateDisplay = getDisplayDate(date: date)
    }

    // Convert Date to String for date display.
    private func getDisplayDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = userCalendar.timeZone
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM")
        let month = dateFormatter.string(from: date)

        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy")
        let year = dateFormatter.string(from: date)

        return "\(month) \(year)"
    }

    // Set all dates to unselected
    private func deselectAll() {
        for index in 0..<self.datesPage.dates.count {
            self.datesPage.dates[index].selected = false
        }
    }

    // Create a fetch controller for specific date.
    private func setupDateFetcher(start: Date, end: Date) -> NSFetchedResultsController<CD_Date> {
        let request = CD_Date.fetchRequest()
        request.sortDescriptors = []
        request.predicate = NSPredicate(
            format: "date >= %@ AND date <= %@",
            argumentArray: [start, end])
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
    }

    // Run date fetcher on dates selected.
    private func runDateFetcher(action: ([CD_Date]) -> ()) {
        let fetchedResultsController = setupDateFetcher(start: datesPage.dates[selectionStart].date, end: datesPage.dates[selectionEnd].date)

        do {
            try fetchedResultsController.performFetch()
            guard let fetchedResults = fetchedResultsController.fetchedObjects else { return }
            action(fetchedResults)
            try viewContext.save()
        } catch {

        }
    }

    // Fetch shift data from CoreData and unpack to dateStore
    private func fetchShifts() {
        do {
            try self.fetchedResultsController.performFetch()
            guard let shifts = fetchedResultsController.fetchedObjects else { return }
            self.dateStore = unpackShifts(shifts: shifts)
        } catch {
            print(error.localizedDescription)
        }
//        hasLoadedStore = true
    }

    // Unpack shift data from CoreData wrapper
    private func unpackShifts(shifts: [CD_Date]) -> [CalendarDate] {
        var array: [CalendarDate] = []
        let mapped = shifts.map(CD_DateMapped.init)

        for index in mapped.indices {
            let shift = mapped[index]
            let day = getDayFromDate(date: shift.date)
            array.append(CalendarDate(id: index, date: shift.date, day: day, templateId: shift.templateId, greyed: false))
        }
        return array
    }

    public func deselectPattern() {
        applyingPattern = nil
        isApplyingPattern = false
    }

    public func deleteAll() async {
        let request = CD_Date.fetchRequest()
        request.sortDescriptors = []

        let fetcher = NSFetchedResultsController(fetchRequest: request,
                                                 managedObjectContext: viewContext,
                                                 sectionNameKeyPath: nil,
                                                 cacheName: nil
        )

        do {
            try fetcher.performFetch()
            guard let fetched = fetcher.fetchedObjects else { return }

            for item in fetched {
                viewContext.delete(item)
            }

            try viewContext.save()
        } catch {
            
        }
    }

    // Is Date the same month as setDate
    public func isSameMonth(date: Date) -> Bool {
        let dateComp = userCalendar.dateComponents([.month, .year], from: date)
        let setDateComp = userCalendar.dateComponents([.month, .year], from: setDate)

        if dateComp == setDateComp { return true } else { return false }
    }

    // Update dates array to date given.
    public func setMonth() async {
        let dates = await self.getMonthAsync(date: self.setDate)
        let dateDisplay = await self.getDisplayDate(date: self.setDate)
        let page = CalendarPage(id: dateDisplay.hashValue, dates: dates)
        DispatchQueue.main.async { self.datesPage = page }
    }

    // Iterate the current date by amount of months
    public func iterateMonth(value: Int) async {
        var addDate = DateComponents()
        addDate.month = value
        guard let resultMonth = userCalendar.date(byAdding: addDate, to: setDate) else { return }
        DispatchQueue.main.async { self.setCalendarDate(date: resultMonth) }
    }

    // Iterate Month but do not update the display text.
    public func iterateMonthNoDisplay(value: Int) async {
        var addDate = DateComponents()
        addDate.month = value
        guard let resultMonth = userCalendar.date(byAdding: addDate, to: setDate) else { return }
        DispatchQueue.main.async { self.setDate = resultMonth }
    }
    // Convert Date to String for date display.
    private func getDisplayDate(date: Date) async -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = userCalendar.timeZone
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM")
        let month = dateFormatter.string(from: date)

        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy")
        let year = dateFormatter.string(from: date)

        return "\(month) \(year)"
    }

    // Return array of dates from the first weekday before/on the 1st of the month.
    private func getMonthAsync(date: Date) async -> [CalendarDate] {
        var selectedDate = getStartDate(date: date)
        var dates: [CalendarDate] = []
        // Create date component to iterate one day.
        var addDate = DateComponents()
        addDate.day = 1
        var firstBool: Bool = false
        var greyed: Bool = true

        for dateId in 0...41 {
            // Get the day number for each day.
            let calDateComponents = userCalendar.dateComponents([.day], from: selectedDate)
            guard let calDay = calDateComponents.day else { continue }

            if (calDay == 1) {
                if (firstBool) { greyed = true }
                else { firstBool = true; greyed = false }
            }

            let stored = dateStore.first(where: {$0.date == selectedDate})
            let descriptor = CalendarDate(id: dateId, date: selectedDate, day: String(calDay), templateId: stored?.templateId, greyed: greyed)

            // Add to the collection to be returned.
            dates.append(descriptor)

            // Iterate the day for the next loop
            guard let nextDay = userCalendar.date(byAdding: addDate, to: selectedDate) else { continue }
            selectedDate = nextDay
        }

        return dates
    }

}

// CoreData extension.
extension CalendarManager: NSFetchedResultsControllerDelegate {
    internal func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let shifts = fetchedResultsController.fetchedObjects else { return }
        self.dateStore = self.unpackShifts(shifts: shifts)
        Task.detached { await self.setMonth() }

    }
}

// Struct to map out CoreData object to native type.
struct CD_DateMapped: Identifiable {
    private var CD_Date: CD_Date
    
    init(CD_Date: CD_Date) {
        self.CD_Date = CD_Date
    }
    
    var id: NSManagedObjectID {
        CD_Date.objectID
    }
    
    var date: Date {
        CD_Date.date!
    }
    
    var templateId: UUID? {
        CD_Date.templateId
    }
}
