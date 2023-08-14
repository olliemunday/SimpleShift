//
//  SimpleShiftWatchApp.swift
//  SimpleShiftWatch Watch App
//
//  Created by Ollie on 11/06/2023.
//

import SwiftUI

@main
struct SimpleShiftWatch_Watch_AppApp: App {

    @ObservedObject private var watchConnectivity = WatchConnectivityManager.shared

    var body: some Scene {
        WindowGroup {
            if watchConnectivity.calendarSynced && watchConnectivity.shiftsSynced {
                WeekListView()
            } else {
                SyncPromptView()
            }
        }
    }
}
