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

    // List of dates for the Calendar List view.
    @Published var weekDates: [[CalendarDate]] = []

    override init(noLoad: Bool = false) {
        super.init()
    }

    // Create date array for 5 weeks starting from first day of last week.
    func populateListWeeks() {
        guard let convertedNow = getCalendarDate(Date.now) else { return }
        let now = getCleanDate(convertedNow)
        let firstday = getFirstWeekday(now)

        let subtract = DateComponents(day: -7)
        guard let lastWeek = userCalendar.date(byAdding: subtract,
                                         to: firstday)
        else { return }

        var selectedDate = lastWeek
        let addDate = DateComponents(day: 1)
        var weekCollection: [CalendarDate] = []
        var calendarWeeks: [[CalendarDate]] = []

        for dayIndex in 0 ... 34 {
            if (dayIndex % 7 == 0) && dayIndex != 0 {
                calendarWeeks.append(weekCollection)
                weekCollection = []
            }

            let stored = dateStore.first(where: { $0.date == selectedDate })
            let descriptor = CalendarDate(id: dayIndex,
                                          date: selectedDate,
                                          templateId: stored?.templateId)
            weekCollection.append(descriptor)

            guard let nextDay = userCalendar.date(byAdding: addDate, to: selectedDate) else { break }
            selectedDate = nextDay
        }
        calendarWeeks.append(weekCollection)
        let safeWeeks = calendarWeeks
        Task { await setWeekDates(safeWeeks) }
    }

    @MainActor
    func setWeekDates(_ dates: [[CalendarDate]]) { weekDates = dates }

    @objc private func updateList() {
        populateListWeeks()
    }
}

extension CalendarWatchManager {
    internal func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let dates = fetchedResultsController.fetchedObjects else { return }
        self.dateStore = self.unpackDates(dates)
        populateListWeeks()
        updateAppGroup()
    }
}
