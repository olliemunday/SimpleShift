//
//  CalendarWatchManager.swift
//  SimpleShift
//
//  Created by Ollie on 12/06/2023.
//

import Foundation
import CoreData
import SwiftUI
import WidgetKit
import Combine


class CalendarWatchManager: CalendarManager {

    @Published var displayDate: CalendarDate? = nil

    override init(noLoad: Bool = false) {
        super.init()
        setDisplayDate()
        
    }

    func setDisplayDate() {
        Task {
            let today = getCleanDate(date: Date.now)
            guard let calendarDate = dateStore.first(where: {$0.date == today}) else { return }
            DispatchQueue.main.async {
                self.displayDate = calendarDate
            }
        }
    }
}

extension CalendarWatchManager {
    internal func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let shifts = fetchedResultsController.fetchedObjects else { return }
        self.dateStore = self.unpackShifts(shifts: shifts)
        print("Updating display date")
        setDisplayDate()
    }
}
