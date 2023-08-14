//
//  CalendarWeek.swift
//  SimpleShift
//
//  Created by Ollie on 22/06/2023.
//

import Foundation

struct CalendarWeek: Identifiable, Equatable {
    let id: Int

    var days: [CalendarDisplay] = []
    var name: String? = nil
    var weekCommence: String? = nil
}
