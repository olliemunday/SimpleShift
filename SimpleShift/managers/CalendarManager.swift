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

class CalendarManager: NSObject, ObservableObject, @unchecked Sendable {
    // Persistence Controller with computed variable in case the container
    // is reloaded such as toggling iCloud functionality.
    var persistenceController = PersistenceController.shared
    var viewContext: NSManagedObjectContext { persistenceController.container.viewContext }

    var fetchedResultsController : NSFetchedResultsController<CD_Date>
    var userCalendar = Calendar.current
    var dateFormatter = DateFormatter()

//    var watchConnectivity = WatchConnectivityManager.shared

    // Store saved dates.
    var dateStore: [CalendarDate] = []

    @AppStorage("calendar_weekday", store: .standard)
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
        if noLoad { return }
        fetchedResultsController.delegate = self
        // Load in saved shift data
        self.fetchShifts()

        NotificationCenter.default.addObserver(self, selector: #selector(reinitializeCoreData), name: NSNotification.Name("CoreDataRefresh"), object: nil)
    }

    // Fetch shift data from CoreData and unpack to dateStore.
    private func fetchShifts() {
        do {
            try self.fetchedResultsController.performFetch()
            guard let shifts = fetchedResultsController.fetchedObjects else { return }
            self.dateStore = unpackShifts(shifts: shifts)
        } catch {
            print(error.localizedDescription)
        }
    }

    // Reload Core Data ViewContext when Container is reloaded.
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

    // Create a fetch controller
    func setupDateFetcher() -> NSFetchedResultsController<CD_Date> {
        let request = CD_Date.fetchRequest()
        request.sortDescriptors = []
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
    }

    // Create a fetch controller for specific date.
    func setupDateFetcher(start: Date, end: Date) -> NSFetchedResultsController<CD_Date> {
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
}

// Useful shared calendar functions
extension CalendarManager {
    // Return number of day as string.
    func getDayFromDate(date: Date) -> String {
        String(userCalendar.dateComponents([.day], from: date).day ?? 0)
    }

    // Returns 1st day of the month.
    func getFirstOfMonth(date: Date) -> Date {
        var dateComponents = userCalendar.dateComponents([.year, .month, .day, .weekday], from: date)
        dateComponents.day = 1
        return userCalendar.date(from: dateComponents)!
    }

    // Strip date back to Day, Month, Year
    func getCleanDate(date: Date) -> Date {
        return userCalendar.date(from: userCalendar.dateComponents([.year, .month, .day], from: date))!
    }

    // Get first day of the week.
    func getWeekday(date: Date) -> Date {
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
    func getStartDate(date: Date) -> Date {
        let clean = getCleanDate(date: date)
        let first = getFirstOfMonth(date: clean)
        return getWeekday(date: first)
    }

    // Compare two dates and return true if they are the same.
    public func isToday(date: Date) -> Bool {
        let defaultCalendar = Calendar.autoupdatingCurrent

        let nowComps = defaultCalendar.dateComponents([.year, .month, .day], from: Date.now)
        let dateComps = userCalendar.dateComponents([.year, .month, .day], from: date)

        return dateComps == nowComps
    }

    public func getCalendarDate(date: Date) -> Date? {
        let defaultCalendar = Calendar.current
        let dateComp = defaultCalendar.dateComponents([.month, .year], from: date)

        return userCalendar.date(from: dateComp)
    }
}

extension CalendarManager {
    // Unpack shift data from CoreData wrapper.
    func unpackShifts(shifts: [CD_Date]) -> [CalendarDate] {
        var array: [CalendarDate] = []
        let mapped = shifts.map(CD_DateMapped.init)

        for index in mapped.indices {
            let shift = mapped[index]
            let day = getDayFromDate(date: shift.date)
            array.append(CalendarDate(id: index, date: shift.date, day: day, templateId: shift.templateId, greyed: false))
        }
        return array
    }

    // Package saved dates as Data.
    func packageDateStore() -> Data? {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(dateStore)
            return data
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func packageForWatch() -> Data? {
        let sorted = dateStore.sorted { $0.date < $1.date }
        let now = getCleanDate(date: Date.now)

        var collection: [CalendarDate] = []
        var collectamt = 0

        for date in sorted {
            if collectamt > 30 { break }
            if date.date < now { continue }
            collection.append(date)
            collectamt += 1
        }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(collection)
            return data
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    // Import dates saved as Data.
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

    // Save all dates to CoreData. !!! This will not delete. !!!
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

    // Delete all CoreData stored.
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

