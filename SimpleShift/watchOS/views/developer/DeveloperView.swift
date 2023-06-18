//
//  DeveloperView.swift
//  SimpleShiftWatch Watch App
//
//  Created by Ollie on 16/06/2023.
//

import SwiftUI

struct DeveloperView: View {

    @ObservedObject private var watchConnectivity = WatchConnectivityManager.shared
    @StateObject private var calendarManager = CalendarWatchManager()
    @StateObject private var shiftManager = ShiftManager()

    var body: some View {
        List {
            if let display = calendarManager.displayDate,
               let shift = shiftManager.getShiftOrNil(id: display.templateId)
            {
                Text(display.day)
                Text(shift.shift)
            }
        }
        .navigationTitle("Developer")
    }

}
