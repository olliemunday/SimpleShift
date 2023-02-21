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

// CalendarManager creates DateDescriptor instances to be displayed by a view.
class CalendarManager: NSObject, ObservableObject {
    private var viewContext = PersistenceController.shared.container.viewContext
    private var fetchedResultsController: NSFetchedResultsController<CD_Date>
    private var userCalendar = Calendar.autoupdatingCurrent

    // Date/Shift working array.
    var dateStore: [CalendarDate] = []
    private var hasLoadedStore: Bool = false

    // Cache array to store pre-loaded months.
    private var dateCache: [Date:[CalendarDate]] = [:]

    // Array for UI View to display each day of the month.
    @Published var dates: [CalendarDate] = []

    @Published var datesArray: [CalendarPage] = []
    // Date that calendar is set to and array for navigation display text.
    @Published var setDate: Date
    // Array used for display.
    @Published var dateViewArray: [DateDisplay] = []

    @AppStorage("calendar_weekday", store: .standard)
    public var weekday: Int = 1

    @AppStorage("calendar_greyed", store: .standard)
    public var greyed: Bool = true

    @AppStorage("calendar_showOff", store: .standard)
    public var showOff: Bool = true

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

    override init() {
        self.userCalendar.timeZone = .gmt
        self.setDate = Date.now
        let request = CD_Date.fetchRequest()
        request.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        super.init()
        self.setDate = getCalendarDate(date: Date.now) ?? Date.now
        fetchedResultsController.delegate = self
        self.dateViewArray.append(DateDisplay(date: getDisplayDate(date: Date.now)))
        // Load in saved shift data
        DispatchQueue.global().sync { self.fetchShifts() }

        NotificationCenter.default.addObserver(self, selector: #selector(reinitializeCoreData), name: NSNotification.Name("CoreDataRefresh"), object: nil)
    }

    @objc func reinitializeCoreData() {
        viewContext = PersistenceController.shared.container.viewContext
        let request = CD_Date.fetchRequest()
        request.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
        DispatchQueue.global().sync { self.fetchShifts() }
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

    // Update dates array to date given.
    public func setMonth() {
        DispatchQueue.global(qos: .userInitiated).async {
            let dates = self.getMonth(date: self.setDate)
            DispatchQueue.main.async { self.dates = dates; self.setDatesArray(dates: dates) }
        }
    }

    public func setDatesArray(dates: [CalendarDate]) {
        self.datesArray = []
        self.datesArray.append(CalendarPage(id: UUID(), dates: dates))
    }

    public func isToday(date: Date) -> Bool {
        let defaultCalendar = Calendar.current

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
                let date = dates[index]
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

        if !dates.indexExists(index: selectionStart) { return }
        let startDate = dates[selectionStart].date
        guard let endDate = userCalendar.date(byAdding: .day, value: unpacked.count, to: startDate) else { return }

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

    public func setSelectionStart(id: Int) {
        selectionStart = id
        selectionEnd = id
        lastSelectionEnd = id
        dates[selectionStart].selected = true
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
            self.dates[index].selected = true
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

    // Clear view date array so transition can take place.
    private func setViewDate(date: Date) {
        dateViewArray.removeAll()
        dateViewArray.append(DateDisplay(date: getDisplayDate(date: date)))
    }

    // Convert Date to String for date display.
    private func getDisplayDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = userCalendar.timeZone
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM")
        let month = dateFormatter.string(from: date)

        dateFormatter.setLocalizedDateFormatFromTemplate("YYYY")
        let year = dateFormatter.string(from: date)

        return "\(month) \(year)"
    }

    // Set all dates to unselected
    private func deselectAll() {
        for index in 0..<self.dates.count {
            self.dates[index].selected = false
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
        let fetchedResultsController = setupDateFetcher(start: dates[selectionStart].date, end: dates[selectionEnd].date)

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
        hasLoadedStore = true
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

    public func deleteAll() {
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

}

// CoreData extension.
extension CalendarManager: NSFetchedResultsControllerDelegate {
    internal func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Calendar CoreData Update.")
        guard let shifts = fetchedResultsController.fetchedObjects else { return }
        DispatchQueue.global().sync {
            self.dateStore = self.unpackShifts(shifts: shifts)
            DispatchQueue.main.async { self.setMonth() }
        }
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

