//
//  DateDescriptor.swift
//  SwiftShift
//
//  Created by Ollie on 30/03/2022.
//

import Foundation
import SwiftUI

struct CalendarDate: Identifiable, Hashable {
    // ID or Index of Date
    let id: Int
    
    // Date
    let date: Date
    let day: String
    var templateId: UUID? = nil

    // Is Date greyed. (For days of other months and selection)
    let greyed: Bool
    // Is the date selected?
    var selected: Bool = false
}

struct CalendarPage: Identifiable {
    let id: UUID

    let dates: [CalendarDate]
}
