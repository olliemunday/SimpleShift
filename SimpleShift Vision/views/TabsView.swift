//
//  TabsView.swift
//  SimpleShift Vision
//
//  Created by Ollie on 03/07/2023.
//

import SwiftUI
import Foundation

struct TabsView: View {

    // Holds shared application settings and syncs with UserDefaults
    @StateObject var settingsManager = SettingsManager()

    @AppStorage("showWelcome", store: .standard)
    var showWelcome: Bool = true

    @AppStorage("tintOptionSelected", store: .standard)
    var tintOptionSelected: String = "blue"

    @State private var tabSelection = 1
    @State private var showiCloudCard: Bool = false

    @StateObject private var calendarPattern = CalendarPattern()

    var body: some View {
        navigationView
    }

    @State var selectedPage: Page?

    @MainActor
    private var navigationView: some View {
        NavigationSplitView {
            List {
                HCenter { SpinningGradientLogo(size: 72) }
                    .padding(.bottom, 4)
                
                Section {
                    ForEach(Page.allCases) { page in
                        Button { selectedPage = page } label: {
                            Label(page.title, systemImage: page.symbolName)
                                .listRowHoverEffect(.lift)
                        }
                    }
                }

            }
            .navigationTitle("SimpleShift")
            .navigationSplitViewColumnWidth(260)
        } detail: {
            switch selectedPage {
            case .calendar:
            CalendarView(settingsManager: settingsManager,
                         tintOptionSelected: $tintOptionSelected,
                         tabSelection: $tabSelection).tag(1)
            case .shifts:
                ShiftsView().tag(2)
            case .patterns:
                PatternsView(tabSelection: $tabSelection).tag(3)
            case .settings:
                SettingsView(tintOptionSelected: $tintOptionSelected).tag(4)
            case nil:
                EmptyView()
            }
        }
        .environmentObject(settingsManager)
        .environmentObject(calendarPattern)
        .sheet(isPresented: $showWelcome) {
            WelcomeView(tintColor: settingsManager.tintColor).onDisappear { showiCloudCard = true }
        }
        .sheet(isPresented: $showiCloudCard) { WelcomeiCloudView(tintColor: settingsManager.tintColor) }
        .task { selectedPage = .calendar }

    }

    @MainActor
    private var tabView: some View {
        TabView {
            CalendarView(settingsManager: settingsManager,
                         tintOptionSelected: $tintOptionSelected,
                         tabSelection: $tabSelection)
                .tabItem {
                    Label("calendar", systemImage: "calendar")
                }
                .tag(1)

            ShiftsView()
                .tabItem {
                    Label("shifts", systemImage: "square.stack.3d.down.forward.fill")
                }
                .tag(2)

            PatternsView(tabSelection: $tabSelection)
                .tabItem {
                    Label("patterns", systemImage: "clock.arrow.2.circlepath")
                }
                .tag(3)

            SettingsView(tintOptionSelected: $tintOptionSelected)
                .tabItem {
                    Label("settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .environmentObject(settingsManager)
        .environmentObject(calendarPattern)
        .sheet(isPresented: $showWelcome) {
            WelcomeView(tintColor: settingsManager.tintColor).onDisappear { showiCloudCard = true }
        }
        .sheet(isPresented: $showiCloudCard) { WelcomeiCloudView(tintColor: settingsManager.tintColor) }
    }

}


enum Page: String, CaseIterable, Identifiable {

    case calendar
    case shifts
    case patterns
    case settings

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .calendar:
            String(localized: "calendar")
        case .shifts:
            String(localized: "shifts")
        case .patterns:
            String(localized: "patterns")
        case .settings:
            String(localized: "settings")
        }
    }

    var symbolName: String {
        switch self {
        case .calendar:
            "calendar"
        case .shifts:
            "square.stack.3d.down.forward.fill"
        case .patterns:
            "clock.arrow.2.circlepath"
        case .settings:
            "gearshape.fill"
        }
    }

}

//#Preview {
//    TabsView()
//}
