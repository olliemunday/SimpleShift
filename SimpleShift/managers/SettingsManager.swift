//
//  SettingsController.swift
//  SimpleShift
//
//  Created by Ollie on 12/04/2023.
//

import Foundation
import SwiftUI

class SettingsManager: ObservableObject {

    @AppStorage("calendar_weekday", store: .standard)
    public var weekday: Int = Calendar.current.firstWeekday

    @AppStorage("calendar_greyed", store: .standard)
    public var greyed: Bool = true

    @AppStorage("calendar_showOff", store: .standard)
    public var calendarShowOff: Bool = false

    @AppStorage("calendar_showTodayIndicator", store: .standard)
    public var showTodayIndicator: Bool = true

    @AppStorage("calendar_todayIndicatorType", store: .standard)
    public var todayIndicatorType: Int = 1

    @AppStorage("_accentColor", store: .standard)
    public var accentColor: Color = .blue

}
