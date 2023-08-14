//
//  CalendarPage.swift
//  SimpleShift
//
//  Created by Ollie on 22/06/2023.
//

import Foundation

struct CalendarPage: Identifiable, Equatable {
    let id: Int
    let display: String

    var weeks: [CalendarWeek] = []
}

