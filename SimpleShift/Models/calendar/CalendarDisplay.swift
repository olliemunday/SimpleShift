//
//  CalendarDisplay.swift
//  SimpleShift
//
//  Created by Ollie on 20/06/2023.
//

import Foundation
import SwiftUI

struct CalendarDisplay: Identifiable, Hashable, Equatable, Codable {
    let id: Int

    let date: CalendarDate
    let shift: Shift?

    let day: String

    #if os(iOS) || os(xrOS)
    let isGreyed: Bool
    #endif

    let showOff: Bool

    let indicatorType: Int

    #if os(watchOS)
    let weekday: Int
    #endif
}
