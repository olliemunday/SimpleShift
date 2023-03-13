//
//  SwiftShiftApp.swift
//  SwiftShift
//
//  Created by Ollie on 24/03/2022.
//

import SwiftUI

@main
struct SwiftShiftApp: App {

    @StateObject var calendarManager = CalendarManager()
    @StateObject var shiftManager = ShiftManager()
    @StateObject var patternManager = PatternManager()

    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) private var colorScheme

    @State private var tabSelection = 1
    @AppStorage("tintOptionSelected") var tintOptionSelected: String = "blue"

    @AppStorage("showWelcome") var showWelcome: Bool = true
    @State private var showiCloudCard: Bool = false


    @State private var showNewWelcome = true

    var body: some Scene { WindowGroup { navigation } }
    
    private var navigation: some View {
        TabView(selection: $tabSelection) {
            CalendarView(tintOptionSelected: $tintOptionSelected,tabSelection: $tabSelection).tag(1)
                .tabItem { TabViewItem(systemName: "calendar", text: String(localized: "calendar")) }
            ShiftsView().tag(2)
                .tabItem { TabViewItem(systemName: "square.stack.3d.down.forward", text: String(localized: "shifts")) }
            PatternsView(tabSelection: $tabSelection).tag(3)
                .tabItem { TabViewItem(systemName: "clock.arrow.2.circlepath", text: String(localized: "patterns")) }
            SettingsView(tintOptionSelected: $tintOptionSelected).tag(4)
                .tabItem { TabViewItem(systemName: "gearshape.fill", text: String(localized: "settings")) }
        }
            .environmentObject(calendarManager)
            .environmentObject(shiftManager)
            .environmentObject(patternManager)
            .accentColor(calendarManager.accentColor)
            .popover(isPresented: $showWelcome) {
                WelcomeView().onDisappear { showiCloudCard = true }
            }
//            .popover(isPresented: $showNewWelcome) {
//                NewWelcomeView()
//                    .environmentObject(calendarManager)
//            }
            .popover(isPresented: $showiCloudCard) { WelcomeiCloudView() }
            .onAppear() {
                UITabBar.appearance().backgroundColor = UIColor(Color("Background"))
            }

    }
}

