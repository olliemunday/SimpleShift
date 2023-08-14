//
//  Global.swift
//  SimpleShift
//
//  Created by Ollie on 19/07/2023.
//

import Foundation

struct WeekdayUtil {

    let weekdays = [
        String(localized: "sun"),
        String(localized: "mon"),
        String(localized: "tue"),
        String(localized: "wed"),
        String(localized: "thu"),
        String(localized: "fri"),
        String(localized: "sat")
    ]

    let weekdays_long = [
        String(localized: "sunday"),
        String(localized: "monday"),
        String(localized: "tuesday"),
        String(localized: "wednesday"),
        String(localized: "thursday"),
        String(localized: "friday"),
        String(localized: "saturday")
    ]

    func getWeekdays(start: Int) -> [String] {
        let safe = max(start, 0)
        return Array(weekdays[safe..<weekdays.count]+weekdays[0..<safe])
    }

}
