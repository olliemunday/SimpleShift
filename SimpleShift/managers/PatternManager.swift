//
//  PatternManager.swift
//  SwiftShift
//
//  Created by Ollie on 10/09/2022.
//

import Foundation
import CoreData

class PatternManager: NSObject, ObservableObject {
    private var persistenceController: PersistenceController
    private var viewContext: NSManagedObjectContext { persistenceController.container.viewContext }
    // Core Data Fetch Controller
    private var fetchedResultsController: NSFetchedResultsController<CD_Pattern>
    
    // Array to hold all Pattern objects.
    @Published var patternStore: [Pattern] = []
    // Array to hold id of selected patterns. In practice this only ever holds one id at a time.
    @Published var patternSelected: Set<UUID> = []

    @Published var draggedPattern: UUID = UUID()
    
    private var selectionWeek: UUID = UUID()
    private var selectionStart: Int = 0
    private var selectionEnd: Int = 0
    
    init(_ persistenceController : PersistenceController) {
        self.persistenceController = persistenceController
        let request = CD_Pattern.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: persistenceController.container.viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        super.init()
        fetchedResultsController.delegate = self

        /// Load in Patterns stored to CoreData.
        loadPatterns()

        NotificationCenter.default.addObserver(self, selector: #selector(reinitializeCoreData), name: NSNotification.Name("CoreDataRefresh"), object: nil)
    }

    @objc func reinitializeCoreData() {
        print("Reinit CD")
        let request = CD_Pattern.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
        self.loadPatterns()
    }
    
    private func loadPatterns() {
        do {
            try fetchedResultsController.performFetch()
            guard let patterns = fetchedResultsController.fetchedObjects else { return }
            
            self.patternStore = unpackPatterns(patterns: patterns)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func unpackPatterns(patterns: [CD_Pattern]) -> [Pattern] {
        let mapped = patterns.map(CD_PatternMap.init)
        var array: [Pattern] = []
        
        for pattern in mapped {
            if let unwrapped = pattern.pattern {
                array.append(unwrapped)
            }
        }
        return array
    }
    
    func patternExists(id: UUID) -> Bool {
        patternStore.first(where: {$0.id == id}) != nil
    }
    
    func getPatternIndex(id: UUID) -> Int? {
        guard let entry = patternStore.firstIndex(where: {$0.id == id}) else {
            return nil
        }
        return entry
    }
    
    func getPattern(id: UUID) -> Pattern {
        if patternExists(id: id) {
            guard let index = getPatternIndex(id: id) else { return Pattern(id: id, name: "") }
            return patternStore[index]
        }
        return Pattern(id: id, name: "")
    }
    
    func setPattern(pattern: Pattern) {
        commitPattern(pattern: pattern)
    }
    
    public func commitPatternId(id: UUID) {
        guard let index = getPatternIndex(id: id) else { return }
        commitPattern(pattern: patternStore[index])
    }
    
    // Encode and save pattern to CoreData.
    public func commitPattern(pattern: Pattern) {
        let request = CD_Pattern.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        request.predicate = NSPredicate(format: "id == %@", pattern.id as CVarArg)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            guard let patterns = fetchedResultsController.fetchedObjects else { return }
            
            if patterns.isEmpty {
                let newPattern = CD_Pattern(context: viewContext)
                newPattern.id = pattern.id
                newPattern.index = Int32(patternStore.count)
                newPattern.encoded = pattern.encode()
            } else {
                patterns.last?.encoded = pattern.encode()
                patterns.last?.index = Int32(patternStore.firstIndex(of: pattern) ?? 0)
            }
            try viewContext.save()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    func deletePattern(id: UUID) {
        do {
            try fetchedResultsController.performFetch()
            guard let fetched = fetchedResultsController.fetchedObjects else { return }

            var indexShift = 0
            for index in fetched.indices {
                let converted = fetched[index] as CD_Pattern

                if converted.id == id { viewContext.delete(fetched[index]); indexShift = 1; continue }

                fetched[index].index = Int32(index - indexShift)
            }

            try viewContext.save()
        } catch {
            print("Error : \(error.localizedDescription)")
        }
        
    }
    
    func setPatternName(id: UUID, name: String) {
        guard let index = getPatternIndex(id: id) else { return }
        patternStore[index].name = name
        commitPatternId(id: id)
    }
    
    func getWeekIndex(pattern: Pattern, weekId: UUID) -> Int? {

        guard let index = pattern.weekArray.firstIndex(where: {$0.id == weekId}) else {
            return nil
        }
        
        return index
        
    }

    public func getWeekIndex(patternId: UUID, weekId: UUID) -> Int? {
        guard let pattern = patternStore.first(where: {$0.id == patternId}) else {
            return nil }
        guard let index = pattern.weekArray.firstIndex(where: {$0.id == weekId}) else {
            return nil }
        return index
    }
    
    func getWeekIndex(pattern: Int, weekId: UUID) -> Int? {
        guard let index = patternStore[pattern].weekArray.firstIndex(where: {$0.id == weekId}) else {
            return nil
        }
        
        return index
    }
    
    func addWeekToPattern(id: UUID) {
        guard let index = getPatternIndex(id: id) else { return }
        patternStore[index].weekArray.append(PatternWeek(id: UUID()))
        commitPatternId(id: id)
    }

    // Remove the last item in the patterns array
    func removeLastWeekFromPattern(id: UUID) {
        guard let patternIndex = getPatternIndex(id: id) else { return }
        if patternStore[patternIndex].weekArray.isEmpty { return }
        patternStore[patternIndex].weekArray.removeLast()
        commitPatternId(id: id)
    }

    // Remove Week from Pattern as specified by UUIDs.
    func removeWeekFromPattern(pattern: UUID, week: UUID) {
        guard let patternIndex = getPatternIndex(id: pattern) else { return }
        patternStore[patternIndex].weekArray.removeAll(where: {$0.id == week})
        commitPatternId(id: pattern)
    }
    
    func patternToggle(id: UUID) -> Void {
        if patternSelected.contains(id) {
            patternSelected.removeAll()
        } else {
            patternSelected.removeAll()
            patternSelected.insert(id)
        }
    }
    
    func setSelectionStart(index: Int, week: UUID) {
        selectionStart = index
        selectionWeek = week
        setShiftSelected(start: index, end: index)
    }
    
    /// Is a Pattern currently selected?
    func isPatternSelected() -> Bool {
        !patternSelected.isEmpty
    }
    
    /// Get selected pattern.
    func getPatternSelected() -> UUID? {
        patternSelected.first
    }
    
    func setSelectionEnd(index: Int) {
        selectionEnd = index
        setShiftSelected(start: selectionStart, end: index)
    }
    
    /// Sets shifts to selected
    public func setShiftSelected(start: Int, end: Int) {
        guard let pattern = getPatternSelected() else { return }
        
        guard let patternIndex = getPatternIndex(id: pattern) else { return }
        guard let weekIndex = getWeekIndex(pattern: patternIndex, weekId: selectionWeek) else { return }
        let min = min(start, end)
        let max = max(start, end)
        
        setShiftsUnselected()
        
        for index in min...max {
            patternStore[patternIndex].weekArray[weekIndex].shiftArray[index].selected = true
        }
    }
    
    public func setShiftsUnselected() {
        guard let pattern = getPatternSelected() else { return }
        
        guard let patternIndex = getPatternIndex(id: pattern) else { return }
        guard let weekIndex = getWeekIndex(pattern: patternIndex, weekId: selectionWeek) else { return }
        
        for index in patternStore[patternIndex].weekArray[weekIndex].shiftArray.indices {
            patternStore[patternIndex].weekArray[weekIndex].shiftArray[index].selected = false
        }
    }
    
    public func getSelectionEnd() -> Int {
        selectionEnd
    }
    
    public func setShiftTemplates(id: UUID?) {
        guard let pattern = getPatternSelected() else { return }
        
        guard let patternIndex = getPatternIndex(id: pattern) else { return }
        guard let weekIndex = getWeekIndex(pattern: patternIndex, weekId: selectionWeek) else { return }
        let min = min(selectionStart, selectionEnd)
        let max = max(selectionStart, selectionEnd)
        
        for index in min...max {
            patternStore[patternIndex].weekArray[weekIndex].shiftArray[index].shift = id
            commitPattern(pattern: patternStore[patternIndex])
        }
    }

    public func deleteAll() async {
        let request = CD_Pattern.fetchRequest()
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

    // Update index variables in CoreData after reordering
    func updateIndexes() {
        do {
            try fetchedResultsController.performFetch()
            guard let fetched = fetchedResultsController.fetchedObjects else { return }

            for index in fetched.indices {
                let converted = fetched[index] as CD_Pattern

                guard let newIndex = patternStore.firstIndex(where: {$0.id == converted.id}) else { continue }

                fetched[index].index = Int32(newIndex)
            }
            try viewContext.save()
        } catch {

        }
    }

    public func insertPattern(fromId: UUID, toId: UUID) {
        guard let from = getPatternIndex(id: fromId),
              let to = getPatternIndex(id: toId)
        else { return }

        patternStore.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        updateIndexes()
    }

    public func isFirstWeek(weekId: UUID, patternId: UUID) -> Bool {
        guard let pattern = patternStore.first(where: { $0.id == patternId }) else {return false}
        if pattern.weekArray.first?.id == weekId { return true }
        return false
    }
}

extension PatternManager: NSFetchedResultsControllerDelegate {
    internal func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let fetchedResults = fetchedResultsController.fetchedObjects else { return }

        let patterns = unpackPatterns(patterns: fetchedResults)
        patternStore = patterns
    }
}

// Struct to decode stored Patterns
struct CD_PatternMap: Identifiable {
    var pattern: Pattern?
    var id: NSManagedObjectID
    
  
    init(CD_Pattern: CD_Pattern) {
        self.id = CD_Pattern.objectID
        self.pattern = Pattern.decode(pattern: CD_Pattern.encoded ?? "")
    }
}
