//
//  DateDescriptor.swift
//  SwiftShift
//
//  Created by Ollie on 30/03/2022.
//

import Foundation
import SwiftUI

struct CalendarDate: Identifiable, Hashable, Equatable, Codable {
    // ID or Index of Date
    let id: Int
    
    // Date object
    let date: Date

    // ID of shift template
    var templateId: UUID? = nil

    // Is the date selected
    var selected: Bool = false
}
