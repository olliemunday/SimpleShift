//
//  WeekListViewModel.swift
//  SimpleShiftWatch Watch App
//
//  Created by Ollie on 29/06/2023.
//

import Foundation
import Combine

class WeekListViewModel: ObservableObject {

    @Published var weekList: [CalendarWeek] = []

    var todayIndex = 0

    var calendarManager: CalendarWatchManager
    var shiftManager: ShiftManager
    private var dateFormatter = DateFormatter()
    private var cancellables = Set<AnyCancellable>()

    init(calendarManager: CalendarWatchManager, shiftManager: ShiftManager) {
        self.calendarManager = calendarManager
        self.shiftManager = shiftManager
        self.calendarManager.updateWeekday() 

        self.calendarManager.$weekDates
            .sink { [weak self] in self?.updateList($0) }
            .store(in: &cancellables)

        self.shiftManager.$shifts
            .sink { [weak self] _ in self?.updateList() }
            .store(in: &cancellables)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateWeekday),
                                               name: NSNotification.Name("calendar_weekdayUpdate"),
                                               object: nil)
    }

    @objc func updateWeekday() async {
        self.calendarManager.updateWeekday()
        self.populateListWeeks()
    }

    func updateList(_ weekDates: [[CalendarDate]]? = nil) {
            let weekDates = weekDates ?? calendarManager.weekDates
            var calendarWeeks: [CalendarWeek] = []
            dateFormatter.dateFormat = "MMMM dd"

            for week in weekDates {
                guard let index = weekDates.firstIndex(of: week),
                      let weekFirst = week.first else { continue }
                let name = weekNames.element(at: index) ?? ""
                let weekCommence = dateFormatter.string(from: weekFirst.date)

                var calendarWeek = CalendarWeek(id: index,
                                                days: [],
                                                name: name,
                                                weekCommence: weekCommence)
                for day in week {
                    let shift = shiftManager.getShift(id: day.templateId)
                    let dayNumber = calendarManager.userCalendar.component(.day, from: day.date)
                    let weekday = calendarManager.userCalendar.component(.weekday, from: day.date)
                    let isToday = calendarManager.getCalendarDate(Date.now) == day.date
                    let calendarDisplay = CalendarDisplay(id: day.id,
                                                          date: day,
                                                          shift: shift,
                                                          day: String(dayNumber),
                                                          showOff: false,
                                                          indicatorType: isToday ? 1 : 0,
                                                          weekday: weekday)
                    calendarWeek.days.append(calendarDisplay)
                    if isToday { todayIndex = day.id }
                }
                calendarWeeks.append(calendarWeek)
            }
            weekList = calendarWeeks
    }

    func populateListWeeks() {
        calendarManager.populateListWeeks()
    }

}

let weekNames = [
    "Last Week",
    "This Week",
    "Next Week",
    "Next Week +1",
    "Next Week +2"
]
