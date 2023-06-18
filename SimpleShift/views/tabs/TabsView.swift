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

    @AppStorage("tintOptionSelected")
    var tintOptionSelected: String = "blue"

    @AppStorage("showWelcome")
    var showWelcome: Bool = true

    @AppStorage("_tintColor", store: .standard)
    public var tintColor: TintColor = .blue

    @State private var tabSelection = 1
    @State private var showiCloudCard: Bool = false

//    var watchConnectivity = WatchConnectivityManager.shared


    @StateObject private var calendarPattern = CalendarPattern()
    var body: some View { navigation }

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
            .tint(tintColor.colorAdjusted(colorScheme))
            .popover(isPresented: $showWelcome) {
                WelcomeView().onDisappear { showiCloudCard = true }
            }
            .popover(isPresented: $showiCloudCard) { WelcomeiCloudView() }
            .onAppear() {
                UITabBar.appearance().backgroundColor = UIColor(Color("Background"))
            }
//            .onChange(of: scenePhase) { scene in
//                if scene == .active {
//                    Task { watchConnectivity.sendAllWatchData() }
//                }
//            }
    }
}

struct TabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabsView()
    }
}
