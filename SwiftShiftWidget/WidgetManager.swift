//
//  WidgetManager.swift
//  SwiftShiftWidgetExtension
//
//  Created by Ollie on 02/11/2022.
//

import Foundation
import CoreData
import SwiftUI

class WidgetManager: NSObject, ObservableObject {
    private let viewContext = PersistenceController.shared.container.viewContext
    private let userCalendar = Calendar.current
    private var dateFetcher: NSFetchedResultsController<CD_Date> = NSFetchedResultsController()

    override init() {
        super.init()
    }

    private func getShifts() -> [Shift] {
        var array = [Shift]()
        let request = CD_Shift.fetchRequest()
        request.sortDescriptors = []
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

        do {
            try fetchedResultsController.performFetch()

            guard let fetched = fetchedResultsController.fetchedObjects else { return array }
            let mapped = fetched.map(ShiftMapped.init)

            for shift in mapped {
                array.append(Shift(id: shift.id, shift: shift.shift, startTime: shift.startTime, endTime: shift.endTime, gradient_1: shift.gradient1, gradient_2: shift.gradient2))
            }
        } catch {
            fatalError()
        }

        return array
    }

    private func getDates(start: Date, end: Date) -> [CalendarDate] {
        var array = [CalendarDate]()
        let request = CD_Date.fetchRequest()
        request.sortDescriptors = []
        request.predicate = NSPredicate(
            format: "date >= %@ AND date <= %@",
            argumentArray: [start, end])

        dateFetcher = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

        do {
            try dateFetcher.performFetch()

            guard let fetched = dateFetcher.fetchedObjects else { return array }
            let mapped = fetched.map(CD_DateMapped.init)
            for index in mapped.indices {
                let date = mapped[index]
                let day = getDayFromDate(date: date.date)
                array.append(CalendarDate(id: index, date: date.date, day: day, templateId: date.templateId, greyed: false))
            }
        } catch {
            fatalError()
        }

        return array
    }

    // Return number of day as string.
    private func getDayFromDate(date: Date) -> String {
        String(userCalendar.dateComponents([.day], from: date).day ?? 0)
    }

    public func getWeek(dateArray: [CalendarDate]? = nil) -> [WidgetDateView] {
        var array = [WidgetDateView]()
        var date = getWeekday(date: getCleanDate(date: Date()), weekday: 2)
        let endDate = userCalendar.date(byAdding: DateComponents(day: 7), to: date) ?? date

        let shifts = getShifts()
        let dates = dateArray ?? getDates(start: date, end: endDate)

        for index in 0...6 {
            guard let day = userCalendar.dateComponents([.day], from: date).day else { continue }

            var widgetDateView = WidgetDateView(id: index, calendarDate: String(day), color: [.gray, .gray], text: "Off")

            if let stored = dates.first(where: {$0.date == date}) {
                if let shiftid = stored.templateId {
                    if let shift = shifts.first(where: {$0.id == shiftid}) {
                        widgetDateView = WidgetDateView(id: index, calendarDate: String(day), color: shift.gradientArray, text: shift.shift)
                    }
                }
            }

            array.append(widgetDateView)

            if let newDate = userCalendar.date(byAdding: DateComponents(day: 1), to: date) {
                date = newDate
            }
        }

        return array
    }

    // Get first day of the week.
    private func getWeekday(date: Date, weekday: Int) -> Date {
        let dateEditing = userCalendar.dateComponents([.weekday], from: date)
        guard let wkday = dateEditing.weekday else {
            return date
        }
        if wkday == weekday { return date } else {
            var subtract = DateComponents()
            let diff = wkday - weekday
            subtract.day = ( diff > 0 ? -diff : -7-diff )
            return Calendar.current.date(byAdding: subtract, to: date) ?? date
        }
    }

    // Strip date back to Day, Month, Year
    private func getCleanDate(date: Date) -> Date {
        return userCalendar.date(from: userCalendar.dateComponents([.year, .month, .day], from: date))!
    }
}
