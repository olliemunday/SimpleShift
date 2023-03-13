//
//  TemplatesManager.swift
//  SwiftShift
//
//  Created by Ollie on 03/04/2022.
//

import Foundation
import SwiftUI
import CoreData

class ShiftManager: NSObject, ObservableObject {
    @Published var shifts: [Shift] = []
    @Published var editingShift: Shift = Shift()
    private var viewContext = PersistenceController.shared.container.viewContext
    private var fetchedResultsController: NSFetchedResultsController<CD_Shift>

    override init() {
        let request = CD_Shift.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

        super.init()
        fetchedResultsController.delegate = self

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
    }

    @objc func reinitializeCoreData() {
        viewContext = PersistenceController.shared.container.viewContext
        let request = CD_Shift.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
        DispatchQueue.global().sync { self.fetchShifts() }
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

    func getShiftCount() -> Int {
        return shifts.count
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
    
    func getShift(id: UUID) -> Shift {
        if shiftExists(id: id) {
            let entry = getShiftIndex(id: id)
            return shifts[entry]
        }
        return Shift(id: id, shift: "")
    }
    
    func getShiftOrNil(id: UUID?) -> Shift? {
        if let templateid = id {
            if shiftExists(id: templateid) {
                let entry = getShiftIndex(id: templateid)
                return shifts[entry]
            }
        }
        return nil
    }
    
    func getShiftSafe(id: UUID) -> Shift? {
        if shiftExists(id: id) {
            let entry = getShiftIndex(id: id)
            return shifts[entry]
        }
        return nil
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

    public func deleteAll() {
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

    public func hideShift(shift: Shift, hide: Bool = true) {
        let index = getShiftIndex(id: shift.id)
        shifts[index].hide = hide
    }


    // Editing Shift Functions
    public func newEditingShift() { editingShift = Shift() }


}

extension ShiftManager: NSFetchedResultsControllerDelegate {
    // Reflect changes made to CoreData in object array.
    internal func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let fetchedObjects = controller.fetchedObjects else { return }
        guard let shifts: [CD_Shift] = fetchedObjects as? [CD_Shift] else { return }
        DispatchQueue.global(qos: .default).async {
            let mapped = shifts.map(ShiftMapped.init)
            var updated = [Shift]()

            for shift in mapped {
                updated.append(Shift(id: shift.id, shift: shift.shift, isCustom: shift.isCustom, startTime: shift.startTime, endTime: shift.endTime, gradient_1: shift.gradient1, gradient_2: shift.gradient2))
            }
            DispatchQueue.main.async { self.shifts = updated }
        }
    }
}

struct ShiftMapped: Identifiable {
    private var template: CD_Shift
    init(template: CD_Shift) {
        self.template = template
    }
    
    var id: UUID {
        template.id!
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
        return Color(rawValue: raw) ?? .white
    }

    var gradient2: Color {
        let raw = template.color2!
        return Color(rawValue: raw) ?? .black
    }

    var isCustom: Int {
        return Int(template.isCustom)
    }
    
}
