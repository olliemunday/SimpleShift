//
//  TabsView.swift
//  SimpleShift
//
//  Created by Ollie on 15/04/2023.
//

import SwiftUI

struct TabsView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) private var colorScheme

    // Holds shared application settings and syncs with UserDefaults
    @StateObject var settingsManager = SettingsManager()

    @AppStorage("tintOptionSelected", store: .standard)
    var tintOptionSelected: String = "blue"

    @AppStorage("showWelcome", store: .standard)
    var showWelcome: Bool = true

    @State private var tabSelection = 1
    @State private var showiCloudCard: Bool = false

    @StateObject private var calendarPattern = CalendarPattern()
    var body: some View { navigation }

    private var navigation: some View {
        TabView(selection: $tabSelection) {
            calendar
            shifts
            patterns
            settings
        }
        .environmentObject(settingsManager)
        .environmentObject(calendarPattern)
        .tint(settingsManager.tintColor.colorAdjusted(colorScheme))
        .popover(isPresented: $showWelcome) {
            WelcomeView(tintColor: settingsManager.tintColor).onDisappear { showiCloudCard = true }
        }
        .popover(isPresented: $showiCloudCard) { WelcomeiCloudView(tintColor: settingsManager.tintColor) }
        .onAppear() {  UITabBar.appearance().backgroundColor = UIColor(Color("Background")) }
        .onOpenURL(perform: { url in
            if url.absoluteString.contains("now") { tabSelection = 1 }
        })
    }

    private var calendar: some View {
        CalendarView(settingsManager: settingsManager,
                     tintOptionSelected: $tintOptionSelected,
                     tabSelection: $tabSelection)
            .background(Color("Background"))
            .tag(1)
            .tabItem { TabViewItem(systemName: "calendar",
                                   text: String(localized: "calendar")) }
    }

    private var shifts: some View {
        ShiftsView()
            .background(Color("Background"))
            .tag(2)
            .tabItem { TabViewItem(systemName: "square.stack.3d.down.forward",
                                   text: String(localized: "shifts")) }
    }

    private var patterns: some View {
        PatternsView(tabSelection: $tabSelection)
            .background(Color("Background"))
            .tag(3)
            .tabItem { TabViewItem(systemName: "clock.arrow.2.circlepath",
                                   text: String(localized: "patterns")) }
    }

    private var settings: some View {
        SettingsView(tintOptionSelected: $tintOptionSelected)
            .background(Color("Background"))
            .tag(4)
            .tabItem { TabViewItem(systemName: "gearshape.fill",
                                   text: String(localized: "settings")) }
    }
}

struct TabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabsView()
    }
}
