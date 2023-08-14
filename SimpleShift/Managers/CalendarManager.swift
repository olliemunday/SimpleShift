//
//  CalendarManager.swift
//  SwiftShift
//
//  Created by Ollie on 10/09/2022.
//

import Foundation
import CoreData
import SwiftUI
import Combine

#if canImport(WidgetKit)
import WidgetKit
#endif

class CalendarManager: NSObject, ObservableObject, @unchecked Sendable {
    // Persistence Controller with computed variable in case the container
    // is reloaded such as toggling iCloud functionality.
    var persistenceController = PersistenceController.shared
    var viewContext: NSManagedObjectContext { persistenceController.container.viewContext }

    var fetchedResultsController : NSFetchedResultsController<CD_Date>
    var userCalendar = Calendar.current
    var dateFormatter = DateFormatter()
    let appConstants = AppConstants()

    // App Groups setup
    var appGroupContainer: UserDefaults?

    // Store saved dates.
    var dateStore: [CalendarDate] = []

    public var weekday: Int = Calendar.current.firstWeekday

    init(noLoad: Bool = false) {
        // Use GMT timezone for the local calendar so change of timezones do not affect the underlying Date.
        // We only ever need to compare against the day of the month with can be obtained from the current calendar.
        userCalendar.timeZone = .gmt
        let request = CD_Date.fetchRequest()
        request.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: persistenceController.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        super.init()
        appGroupContainer = UserDefaults(suiteName: appConstants.appGroupIdentifier)
        weekday = appGroupContainer?.integer(forKey: "calendar_weekday") as? Int ?? Calendar.current.firstWeekday
        if noLoad { return }
        fetchedResultsController.delegate = self
        // Load in saved shift data
        self.fetchShifts()
        NotificationCenter.default.addObserver(self, selector: #selector(reinitializeCoreData), name: NSNotification.Name("CoreDataRefresh"), object: nil)
        updateAppGroup()
    }

    /// Fetch shift data from CoreData and unpack to dateStore.
    private func fetchShifts() {
        do {
            try self.fetchedResultsController.performFetch()
            guard let dates = fetchedResultsController.fetchedObjects else { return }
            self.dateStore = unpackDates(dates)
        } catch {
            print(error.localizedDescription)
        }
    }

    /// Reload Core Data ViewContext when Container is reloaded.
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

    /// Create a fetch controller
    func setupDateFetcher() -> NSFetchedResultsController<CD_Date> {
        let request = CD_Date.fetchRequest()
        let ascendingDate = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [ascendingDate]
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
    }

    /// Create a fetch controller for specific date.
    func setupDateFetcher(start: Date, end: Date) -> NSFetchedResultsController<CD_Date> {
        let request = CD_Date.fetchRequest()
        let ascendingDate = NSSortDescriptor(key: "date", ascending: true)
        let old = min(start, end)
        let new = max(start, end)
        request.sortDescriptors = [ascendingDate]
        request.predicate = NSPredicate(
            format: "date >= %@ AND date <= %@",
            argumentArray: [old, new])
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
    }

    /// Run date fetcher with specified dates.
    func runDateFetcher(start: Date, end: Date, action: ([CD_Date]) -> ()) {
        let fetchedResultsController = setupDateFetcher(start: start, end: end)

        do {
            try fetchedResultsController.performFetch()
            guard let fetchedResults = fetchedResultsController.fetchedObjects else { return }
            action(fetchedResults)
            try viewContext.save()
        } catch {
            fatalError()
        }
    }

    func updateWeekday() {
        weekday = appGroupContainer?.integer(forKey: "calendar_weekday") as? Int ?? Calendar.current.firstWeekday
    }
}

// Useful shared calendar functions
extension CalendarManager {
    /// Return number of day as string.
    func getDayFromDate(_ date: Date) -> String {
        String(userCalendar.dateComponents([.day], from: date).day ?? 0)
    }

    /// Returns 1st day of the month.
    func getFirstOfMonth(_ date: Date) -> Date {
        var dateComponents = userCalendar.dateComponents([.year, .month, .day, .weekday], from: date)
        dateComponents.day = 1
        return userCalendar.date(from: dateComponents)!
    }

    /// Strip date back to Day, Month, Year
    func getCleanDate(_ date: Date) -> Date {
        return userCalendar.date(from: userCalendar.dateComponents([.year, .month, .day], from: date))!
    }

    /// Get first day of the week.
    func getFirstWeekday(_ date: Date) -> Date {
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

    /// Get weekday number from date.
    func getWeekday(_ date: Date) -> Int {
        userCalendar.component(.weekday, from: date)
    }

    /// Get first monday of the first week of the month in date.
    func getStartDate(_ date: Date) -> Date {
        let clean = getCleanDate(date)
        let first = getFirstOfMonth(clean)
        return getFirstWeekday(first)
    }

    /// Compare two dates and return true if they are the same.
    func isToday(_ date: Date) -> Bool {
        var defaultCalendar = Calendar.autoupdatingCurrent
        defaultCalendar.timeZone = TimeZone.autoupdatingCurrent

        let nowComps = defaultCalendar.dateComponents([.year, .month, .day], from: Date.now)
        let dateComps = userCalendar.dateComponents([.year, .month, .day], from: date)

        return dateComps == nowComps
    }

    /// Convert to GMT time to match calendar
    func getCalendarDate(_ date: Date) -> Date? {
        let defaultCalendar = Calendar.autoupdatingCurrent
        let dateComp = defaultCalendar.dateComponents([.month, .year, .day], from: date)

        return userCalendar.date(from: dateComp)
    }

    /// Add amount of days to date
    func addDays(days: Int, to date: Date) -> Date? {
        let days = DateComponents(day: days)
        let date = userCalendar.date(byAdding: days, to: date)
        return date
    }

    /// Get `Date` in calendar GMT
    func getToday() -> Date? { getCalendarDate(Date.now) }


    /// Update App Group container for widget
    func updateAppGroup() {
        let widgetData = packageForWidget()
        if widgetData != appGroupContainer?.value(forKey: "calendar") as? Data {
            appGroupContainer?.setValue(widgetData, forKey: "calendar")
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        }
    }

}

extension CalendarManager {

    /// Convert CoreData objects to `CalendarDate` array
    func unpackDates(_ dates: [CD_Date]) -> [CalendarDate] {
        var array: [CalendarDate] = []
        let mapped = dates.map(CD_DateMapped.init)

        for index in mapped.indices {
            let shift = mapped[index]
            array.append(CalendarDate(id: index,
                                      date: shift.date,
                                      templateId: shift.templateId))
        }
        return array
    }

    /// Package stored dates for Watch. Collects around 100 dates.
    func packageForWatch() -> Data? {
        createDatePackage(dates: dateStore,amount: 100)
    }

    /// Package saved dates as Data.
    func packageForWidget(_ dates: [CalendarDate]? = nil) -> Data? {
        if let dates = dates { return createDatePackage(dates: dates, amount: 46) }
        else { return createDatePackage(dates: dateStore, amount: 46) }
    }

    /// Create a `Data` package of a range of dates. `startDelta` to select start of range.
    func createDatePackage(dates: [CalendarDate], amount: Int, startDelta: Int = -10) -> Data? {
        /// Returns Data containing specified date amounts.
        let sorted = dates.sorted { $0.date < $1.date }
        let now = getCleanDate(Date.now)
        guard let start = addDays(days: startDelta, to: now) else { return nil }

        var collection: [CalendarDate] = []
        var collectamt = 0

        for date in sorted {
            if date.date < start { continue }
            if collectamt > amount { break }
            collection.append(date)
            collectamt += 1
        }

        let data = encodeDates(dates: collection)
        return data
    }

    /// Encode array of `CalendarDate` using JSON as `Data`
    func encodeDates(dates: [CalendarDate]) -> Data {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(dates)
            return data
        } catch {
            fatalError("Failed to encode.")
        }
    }

    /// Import dates saved as `Data`.
    func importDateStore(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            let store = try decoder.decode([CalendarDate].self, from: data)
            dateStore = store
        } catch {
            print(error.localizedDescription)
        }
        saveAllDates(dateStore)
    }

    /// Save array of `CalendarDate` to CoreData.
    func saveAllDates(_ dates: [CalendarDate]) {
        let fetchedResultsController = setupDateFetcher()

        do {
            try fetchedResultsController.performFetch()
            guard let fetchedResults = fetchedResultsController.fetchedObjects else { return }
            for date in dates {
                if let existing = fetchedResults.first(where: { $0.date == date.date }) {
                    existing.templateId = date.templateId
                    continue
                }
                let newDate = CD_Date(context: viewContext)
                newDate.date = date.date
                newDate.templateId = date.templateId
            }

            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }

    }

    /// Delete all CoreData objects stored.
    func deleteAll() {
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
}

// CoreData delegate extension.
extension CalendarManager: NSFetchedResultsControllerDelegate {

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

