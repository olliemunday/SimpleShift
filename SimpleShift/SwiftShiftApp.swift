//
//  SwiftShiftApp.swift
//  SwiftShift
//
//  Created by Ollie on 24/03/2022.
//

import SwiftUI

@main
struct SwiftShiftApp: App {

    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage("tintOptionSelected")
    var tintOptionSelected: String = "blue"

    @AppStorage("showWelcome")
    var showWelcome: Bool = true

    @AppStorage("_accentColor", store: .standard)
    public var accentColor: Color = .blue

    @State private var tabSelection = 1
    @State private var showiCloudCard: Bool = false

    @StateObject private var calendarPattern = CalendarPattern()

    var body: some Scene { WindowGroup { navigation } }

    private var navigation: some View {
        TabView(selection: $tabSelection) {
            CalendarView(tintOptionSelected: $tintOptionSelected,tabSelection: $tabSelection).tag(1)
                .tabItem { TabViewItem(systemName: "calendar", text: String(localized: "calendar")) }
                .environmentObject(calendarPattern)
            ShiftsView().tag(2)
                .tabItem { TabViewItem(systemName: "square.stack.3d.down.forward", text: String(localized: "shifts")) }
            PatternsView(tabSelection: $tabSelection).tag(3)
                .tabItem { TabViewItem(systemName: "clock.arrow.2.circlepath", text: String(localized: "patterns")) }
                .environmentObject(calendarPattern)
            SettingsView(tintOptionSelected: $tintOptionSelected).tag(4)
                .tabItem { TabViewItem(systemName: "gearshape.fill", text: String(localized: "settings")) }
        }
            .background(Color.red)
            .accentColor(accentColor)
            .popover(isPresented: $showWelcome) {
                WelcomeView().onDisappear { showiCloudCard = true }
            }
            .popover(isPresented: $showiCloudCard) { WelcomeiCloudView() }
            .onAppear() {
                UITabBar.appearance().backgroundColor = UIColor(Color("Background"))
            }
    }
}

