//
//  ShiftManager.swift
//  SwiftShift
//
//  Created by Ollie on 03/04/2022.
//

import Foundation
import SwiftUI
import CoreData
#if canImport(WidgetKit)
import WidgetKit
#endif

class ShiftManager: NSObject, ObservableObject {

    // Persistence Controller with computed variable in case the container
    // is reloaded such as toggling iCloud functionality.
    private var persistenceController = PersistenceController.shared
    private var viewContext:NSManagedObjectContext { persistenceController.container.viewContext }
    private var fetchedResultsController: NSFetchedResultsController<CD_Shift>

    var watchConnectivity = WatchConnectivityManager.shared

    private let appConstants = AppConstants()
    private var dateFormatter = DateFormatter()

    var appGroupContainer: UserDefaults?

    @Published var shifts: [Shift] = []

    init (noLoad: Bool = false) {
        let request = CD_Shift.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: persistenceController.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

        super.init()
        if noLoad { return }
        fetchedResultsController.delegate = self
        appGroupContainer = UserDefaults(suiteName: appConstants.appGroupIdentifier)

        do {
            try fetchedResultsController.performFetch()
            guard let fetched = fetchedResultsController.fetchedObjects else {
                return
            }
            let mapped = fetched.map(ShiftMapped.init)
            for shift in mapped {
                shifts.append(Shift(id: shift.id, shift: shift.shift, isCustom: shift.isCustom, startTime: shift.startTime, endTime: shift.endTime, gradient_1: shift.gradient1, gradient_2: shift.gradient2))
            }
        } catch {

        }
        NotificationCenter.default.addObserver(self, selector: #selector(reinitializeCoreData), name: NSNotification.Name("CoreDataRefresh"), object: nil)

        updateAppGroup()
    }

    @objc func reinitializeCoreData() {
        let request = CD_Shift.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
        self.fetchShifts()
    }

    func fetchShifts() {
        var array = [Shift]()
        do {
            try fetchedResultsController.performFetch()
            guard let fetched = fetchedResultsController.fetchedObjects else { return }
            let mapped = fetched.map(ShiftMapped.init)
            for shift in mapped {
                array.append(Shift(id: shift.id, shift: shift.shift, isCustom: shift.isCustom, startTime: shift.startTime, endTime: shift.endTime, gradient_1: shift.gradient1, gradient_2: shift.gradient2))
            }
        } catch {

        }
        shifts = array
    }

    func getShiftIndex(id: UUID) -> Int {
        guard let entry = shifts.firstIndex(where: {$0.id == id}) else {
            return shifts.count
        }
        return entry
    }
    
    func shiftExists(id: UUID) -> Bool {
        if (shifts.first(where: {$0.id == id}) != nil) {
            return true
        }
        return false
    }
    
    func setShift(template: Shift) {
        // Commit changes to CoreData/iCloud
        let request = CD_Shift.fetchRequest()
        request.sortDescriptors = []
        request.predicate = NSPredicate(format: "id == %@", argumentArray: [template.id])
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        do {
            try fetchedResultsController.performFetch()
            guard let shifts = fetchedResultsController.fetchedObjects else { return }
            let index = getShiftIndex(id: template.id)
            if shifts.isEmpty {
                let newTemplate = CD_Shift(context: viewContext)
                newTemplate.id = template.id
                newTemplate.shift = template.shift
                newTemplate.color1 = template.gradient_1.rawValue
                newTemplate.color2 = template.gradient_2.rawValue
                newTemplate.startTime = template.startTime
                newTemplate.endTime = template.endTime
                newTemplate.isCustom = Int32(template.isCustom)
                newTemplate.index = Int32(index)
            } else {
                shifts.last?.shift = template.shift
                shifts.last?.color1 = template.gradient_1.rawValue
                shifts.last?.color2 = template.gradient_2.rawValue
                shifts.last?.startTime = template.startTime
                shifts.last?.endTime = template.endTime
                shifts.last?.isCustom = Int32(template.isCustom)
                shifts.last?.index = Int32(index)
            }
            try viewContext.save()
        } catch {

        }
    }

    func getShift(id: UUID?) -> Shift? {
        shifts.first { $0.id == id }
    }

    // Update index variables in CoreData after reordering
    func updateIndexes() {
        do {
            try fetchedResultsController.performFetch()
            guard let fetched = fetchedResultsController.fetchedObjects else { return }

            for index in fetched.indices {
                let converted = fetched[index] as CD_Shift

                guard let newIndex = shifts.firstIndex(where: {$0.id == converted.id}) else { continue }

                fetched[index].index = Int32(newIndex)
            }
            try viewContext.save()
        } catch {

        }
    }
    
    func deleteShift(shift: Shift) {
        if !shifts.contains(where: { $0.id == shift.id }) { return }

        // Remove shift from CoreData and update ordering.
        do {
            try fetchedResultsController.performFetch()
            guard let fetched = fetchedResultsController.fetchedObjects else { return }

            var indexShift = 0
            for index in fetched.indices {
                let converted = fetched[index] as CD_Shift

                if converted.id == shift.id { viewContext.delete(fetched[index]); indexShift = 1; continue }

                fetched[index].index = Int32(index - indexShift)
            }
            try viewContext.save()
        } catch {

        }

        // Remove set dates in calendar that use the deleted template.
        let dateRequest = CD_Date.fetchRequest()
        dateRequest.sortDescriptors = []
        dateRequest.predicate = NSPredicate(format: "templateId == %@", argumentArray: [shift.id])
        let dateFetcher = NSFetchedResultsController(
            fetchRequest: dateRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        do {
            try dateFetcher.performFetch()
            guard let dates = dateFetcher.fetchedObjects else { return }
            for date in dates {
                viewContext.delete(date)
            }
            try viewContext.save()
        } catch {

        }

        let patternRequest = CD_Pattern.fetchRequest()
        patternRequest.sortDescriptors = []

        let patternFetcher = NSFetchedResultsController(
            fetchRequest: patternRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        do {
            try patternFetcher.performFetch()
            guard let results = patternFetcher.fetchedObjects else { return }

            for result in results {
                guard let encoded = result.encoded else { continue }
                guard var pattern = Pattern.decode(pattern: encoded) else { continue }
                for weekIndex in pattern.weekArray.indices {
                    let week = pattern.weekArray[weekIndex]
                    for shiftIndex in week.shiftArray.indices {
                        let weekShift = week.shiftArray[shiftIndex]
                        if weekShift.shift == shift.id {
                            pattern.weekArray[weekIndex].shiftArray[shiftIndex].shift = nil
                        }
                    }

                }

                result.encoded = pattern.encode()
                try viewContext.save()
            }
        } catch {

        }
    }

    public func deleteAll() async {
        let request = CD_Shift.fetchRequest()
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

    public func moveShift(from: UUID, to: UUID ) {
        let from = getShiftIndex(id: from)
        let to = getShiftIndex(id: to)

        shifts.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        updateIndexes()
    }

    public func getShiftTimeString(_ shift: Shift) -> String? {
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.timeZone = .gmt
        dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
        let start = dateFormatter.string(from: shift.startTime)
        let end = dateFormatter.string(from: shift.endTime)
        return "\(start) \(end)"
    }

}

extension ShiftManager {

    /// Encode Shifts as JSON so data can be translated to other contexts.
    public func packageShifts() -> Data? {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(shifts)
            return data
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    public func importShifts(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            let importShifts = try decoder.decode([Shift].self, from: data)
            shifts = importShifts

            try fetchedResultsController.performFetch()
            guard let fetchedResults = fetchedResultsController.fetchedObjects else { return }
            for shift in self.shifts {
                if let existing = fetchedResults.first(where: { $0.id == shift.id }) {
                    existing.color1 = shift.gradient_1.rawValue
                    existing.color2 = shift.gradient_2.rawValue
                    existing.startTime = shift.startTime
                    existing.endTime = shift.endTime
                    existing.isCustom = Int32(shift.isCustom)
                    existing.shift = shift.shift
                    continue
                }
                let newShift = CD_Shift(context: viewContext)
                newShift.id = shift.id
                newShift.color1 = shift.gradient_1.rawValue
                newShift.color2 = shift.gradient_2.rawValue
                newShift.startTime = shift.startTime
                newShift.endTime = shift.endTime
                newShift.isCustom = Int32(shift.isCustom)
                newShift.shift = shift.shift
            }
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    /// Update App Group Container with latest Shift array. Only updates if there is a change.
    func updateAppGroup() {
        let appGroupData = appGroupContainer?.getData(key: "shifts",
                                                      type: [Shift].self) as? [Shift] ?? []

        if appGroupData != shifts {
            let package = packageShifts()
            appGroupContainer?.setValue(package, forKey: "shifts")
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        }
    }

}

extension ShiftManager: NSFetchedResultsControllerDelegate {
    // Reflect changes made to CoreData in object array.
    internal func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let fetchedObjects = controller.fetchedObjects else { return }
        guard let shifts: [CD_Shift] = fetchedObjects as? [CD_Shift] else { return }

        let mapped = shifts.map(ShiftMapped.init)
        var updated = [Shift]()

        for shift in mapped {
            updated.append(Shift(id: shift.id, shift: shift.shift, isCustom: shift.isCustom, startTime: shift.startTime, endTime: shift.endTime, gradient_1: shift.gradient1, gradient_2: shift.gradient2))
        }

        self.shifts = updated

        if let package = packageShifts() {
            watchConnectivity.transferData(key: "shifts", data: package)
        }
        updateAppGroup()
    }
}

struct ShiftMapped: Identifiable {
    private var template: CD_Shift
    init(template: CD_Shift) {
        self.template = template
    }
    
    var id: UUID {
        template.id ?? UUID()
    }

    var shift: String {
        template.shift ?? ""
    }

    var startTime: Date {
        template.startTime!
    }

    var endTime: Date {
        template.endTime!
    }

    var gradient1: Color {
        let raw = template.color1!
        return Color(rawValue: raw)
    }

    var gradient2: Color {
        let raw = template.color2!
        return Color(rawValue: raw)
    }

    var isCustom: Int {
        return Int(template.isCustom)
    }
    
}
