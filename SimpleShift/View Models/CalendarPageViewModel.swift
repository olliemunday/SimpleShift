//
//  CalendarPageViewModel.swift
//  SimpleShift
//
//  Created by Ollie on 20/06/2023.
//

import Foundation
import Combine
import SwiftUI


/// This View Model uses CalendarPageManager and ShiftManager to create data structure for the view.
/// The view model subscribes to CalendarPageManager and uses the data it returns to create the data for the view.
/// The view model is able to obtain data from both objects and combine the data to reduce effort for the view.
class CalendarPageViewModel: ObservableObject {
    var calendarManager: CalendarPageManager
    var shiftManager: ShiftManager
    var settingsManager: SettingsManager

    // Calendar Page for view.
    @Published var calendarPage = CalendarPage(id: 0, display: "")

    // Date that calendar is set to and array for navigation display text.
    @Published var setDate: Date = Date()

    // Variable to determine if page is being rendered.
    @Published var isRendering = false

    // Page rendered as an image.
    @Published var snapshotImage: UIImage?

    private var cancellables = Set<AnyCancellable>()

    init(calendarManager: CalendarPageManager, shiftManager: ShiftManager, settingsManager: SettingsManager) {
        self.calendarManager = calendarManager
        self.shiftManager = shiftManager
        self.settingsManager = settingsManager
        self.calendarManager.weekday = settingsManager.weekday

        // Subscribe to dates array so we can update the view model when it changes.
        // It is done this way as calendarManager uses CoreData to store data and can update when context changes.
        self.calendarManager.$calendarDates
            .sink { [weak self] in
                let display = self?.calendarManager.display ?? ""
                self?.updatePage($0, display: display)
            }
            .store(in: &cancellables)

        // Subscribe to changes in Shifts and refresh the view model
        self.shiftManager.$shifts
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                self?.setMonth()
            }
            .store(in: &cancellables)

        // Subscribe to changes made in settings to refresh the view model.
        self.settingsManager.calendarPublisher
            .sink { [weak self] _ in
                if let weekday = self?.settingsManager.weekday {
                    self?.calendarManager.weekday = weekday
                }
                self?.setMonth()
            }
            .store(in: &cancellables)
    }

    /// Function to create the data structure for displaying the page.
    /// Takes data from CalendarManager, ShiftManager & SettingsManager.
    public func updatePage(_ dates: [[CalendarDate]], display: String) {
        var page = CalendarPage(id: display.hashValue,
                                        display: display)
        var currentWeek: [CalendarDisplay] = []
        var isFirst: Bool = false
        let greyed = settingsManager.greyed
        let showOff = settingsManager.calendarShowOff
        let todayIndicatorType = settingsManager.todayIndicatorType
        var isGreyed: Bool = greyed
        var weekIndex = 0

        for week in dates {
            for day in week {
                let dayNumber = calendarManager.userCalendar.component(.day, from: day.date)
                if dayNumber == 1 {
                    if isFirst { isGreyed = greyed }
                    else { isFirst = true; isGreyed = false }
                }

                let shift = shiftManager.getShift(id: day.templateId)
                let isToday = calendarManager.getCalendarDate(Date.now) == day.date

                let display = CalendarDisplay(id: day.id,
                                              date: day,
                                              shift: shift,
                                              day: String(dayNumber),
                                              isGreyed: isGreyed,
                                              showOff: showOff,
                                              indicatorType: isToday ? todayIndicatorType : 0)

                currentWeek.append(display)
            }
            let pageWeek = CalendarWeek(id: weekIndex,
                                        days: currentWeek)
            page.weeks.append(pageWeek)
            currentWeek.removeAll()
            weekIndex += 1
        }

        calendarPage = page
    }

    public func setMonth() {
        calendarManager.setMonth(setDate)
    }

    public func setCalendarDateToday() {
        setDate = Date.now
        setMonth()
    }

    public func isSameMonth(_ date: Date) -> Bool {
        let localCalendar = Calendar.autoupdatingCurrent
        let month1 = localCalendar.component(.month, from: date)
        let month2 = localCalendar.component(.month, from: setDate)

        return month1 == month2
    }

    public func deselectAll() {
        calendarManager.deselectAll()
    }

    public func finishSelect() {
        calendarManager.deselectAll()
        calendarManager.resetSelection()
    }

    public func setSelectionStart(_ id: Int) {
        calendarManager.setSelectionStart(id: id)
    }

    public func setSelectionEnd(_ id: Int) {
        calendarManager.setSelectionEnd(id: id)
    }

    public func getSelectionEnd() -> Int {
        calendarManager.selectionEnd
    }

    public func isAlreadySelected() -> Bool {
        calendarManager.selectionEnd == calendarManager.lastSelectionEnd
    }

    public func setSelectedDates(_ templateId: UUID) {
        calendarManager.setSelectedDates(templateId: templateId)
    }

    public func deleteSelectedDates() {
        calendarManager.deleteSelectedDates()
    }

    public func iterateMonth(_ value: Int) {
        let localCalendar = Calendar.autoupdatingCurrent
        var addDate = DateComponents()
        addDate.month = value
        guard let resultMonth = localCalendar.date(byAdding: addDate, to: setDate) else { return }
        setDate = resultMonth
        setMonth()
    }

    public func setPatternFromDate(_ pattern: Pattern?, repeatCount: Int) async {
        await calendarManager.setPatternFromDate(pattern: pattern, repeatCount: repeatCount)
    }

}
