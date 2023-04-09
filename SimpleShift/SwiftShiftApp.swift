//
//  SwiftShiftApp.swift
//  SwiftShift
//
//  Created by Ollie on 24/03/2022.
//

import SwiftUI

@main
struct SwiftShiftApp: App {

    let persistenceController: PersistenceController
    @StateObject var calendarManager: CalendarManager
    @StateObject var shiftManager: ShiftManager
    @StateObject var patternManager: PatternManager
    @StateObject var hapticManager: HapticManager = HapticManager()

    init() {
        let persistence = PersistenceController()
        _calendarManager = StateObject(wrappedValue: CalendarManager(persistence))
        _shiftManager = StateObject(wrappedValue: ShiftManager(persistence))
        _patternManager = StateObject(wrappedValue: PatternManager(persistence))
        persistenceController = persistence
    }

    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage("tintOptionSelected") var tintOptionSelected: String = "blue"
    @AppStorage("showWelcome") var showWelcome: Bool = true

    @State private var tabSelection = 1
    @State private var showiCloudCard: Bool = false

    var body: some Scene { WindowGroup { navigation } }
    
    private var navigation: some View {
        TabView(selection: $tabSelection) {
            CalendarView(tintOptionSelected: $tintOptionSelected,tabSelection: $tabSelection).tag(1)
                .tabItem { TabViewItem(systemName: "calendar", text: String(localized: "calendar")) }
            ShiftsView().tag(2)
                .tabItem { TabViewItem(systemName: "square.stack.3d.down.forward", text: String(localized: "shifts")) }
            PatternsView(tabSelection: $tabSelection).tag(3)
                .tabItem { TabViewItem(systemName: "clock.arrow.2.circlepath", text: String(localized: "patterns")) }
            SettingsView(persistenceController: persistenceController, tintOptionSelected: $tintOptionSelected).tag(4)
                .tabItem { TabViewItem(systemName: "gearshape.fill", text: String(localized: "settings")) }
        }
            .environmentObject(calendarManager)
            .environmentObject(shiftManager)
            .environmentObject(patternManager)
            .environmentObject(hapticManager)
            .accentColor(calendarManager.accentColor)
            .popover(isPresented: $showWelcome) {
                WelcomeView().onDisappear { showiCloudCard = true }
            }
            .popover(isPresented: $showiCloudCard) { WelcomeiCloudView(persistenceController: persistenceController) }
            .onAppear() {
                UITabBar.appearance().backgroundColor = UIColor(Color("Background"))
            }
    }
}

