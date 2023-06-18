//
//  SettingsView.swift
//  ShiftCal
//
//  Created by Ollie on 22/03/2022.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsManager = SettingsManager()

    @Environment(\.colorScheme) private var colorScheme

    var persistenceController = PersistenceController.shared

    @Binding var tintOptionSelected: String

    private enum Navigation: String, Hashable {
        case weekday = "Weekday"
        case tint = "Color Theme"
        case today = "Today Indicator"
        case privacy = "privacy"
        case help = "help"
    }

    private let weekdays = [
        String(localized: "sunday"),
        String(localized: "monday"),
        String(localized: "tuesday"),
        String(localized: "wednesday"),
        String(localized: "thursday"),
        String(localized: "friday"),
        String(localized: "saturday")
    ]

    @State private var navigationStack = [Navigation]()
    var body: some View {
        NavigationStack(path: $navigationStack) {
            List{
                Section {
                    iCloudToggle
                } header: { Text("sync") }
                footer: { Text("syncfooter") }

                Section("calendar") {
                    NavigationLink(value: Navigation.weekday, label: {ImageLabel(title: String(localized: "firstweekday"), systemName: "repeat.1.circle.fill", color: Color.hex("ff3c33"))})
                    NavigationLink(value: Navigation.today, label: {ImageLabel(title: String(localized: "todayindicator"), systemName: "filemenu.and.selection", color: Color.hex("ff3c33"))})
                    greyDaysToggle
                    offDaysToggle
                }

                Section {
                    NavigationLink(value: Navigation.tint,
                                   label: {
                        ImageLabel(title: String(localized: "accentcolor"),
                                   systemName: "paintpalette.fill",
                                   color: settingsManager.tintColor.colorAdjusted(colorScheme),
                                   symbolColor: settingsManager.tintColor.textColor(colorScheme))
                    })
                } header: { Text("theme") }

                Section {
                    NavigationLink(value: Navigation.privacy, label: {ImageLabel(title: String(localized: "privacy"), systemName: "hand.raised.fill", color: .blue)})
                    NavigationLink(value: Navigation.help, label: {ImageLabel(title: String(localized: "help"), systemName: "questionmark", color: .blue)})
                    Button(action: {openWebsite()}, label: {ImageLabel(title: String(localized: "website"), systemName: "safari.fill", color: .blue)})
                } header: {
                    Text("information")
                }

                Section { deleteAllData } header: { Text("data") }
                footer: {
                    ZStack {
                        HStack {
                            Text("SimpleShift v1.1.1\n© 2023 Ollie Munday")
                                .padding(.vertical, 10)
                            Spacer()
                        }
                        Rectangle()
                            .hidden()
                            .overlay { SpinningGradientLogo(size: 80).offset(y: 220) }
                    }
                }

            }
            .tint(settingsManager.tintColor.color)
            .navigationTitle("settings")
            .navigationDestination(for: Navigation.self) { value in
                switch value {
                case .weekday: weekdaySelection
                case .tint: tintSelection
                case .today: todayIndicatorSelector
                case .privacy : ScrollView { PrivacyView() }
                case .help : HelpNavigationView().environmentObject(settingsManager)
                }
            }
        }
        
        .environment(\.defaultMinListRowHeight, 46)
        .navigationViewStyle(.stack)
    }

    private var weekdaySelection: some View {
        List {
            ForEach(weekdays.indices, id: \.self) { index in
                let weekday = weekdays[index]
                Button {
                    settingsManager.weekday = index + 1
                } label: {
                    HStack {
                        Text(weekday)
                            .foregroundColor(.primary)
                        Spacer()
                        if settingsManager.weekday == index + 1 {
                            Image(systemName: "checkmark")
                                .transition(.opacity)
                        }
                    }
                }

            }
        }
        .navigationTitle("firstweekday")
        .animation(.easeInOut(duration: 0.2), value: settingsManager.weekday)
    }

    let tintSpacing: CGFloat = 4
    var tintColumns: Array<GridItem> { Array(repeating: GridItem(spacing: tintSpacing), count: 3) }
    private var tintSelection: some View {
        GeometryReader { geo in
            ScrollView {
                Rectangle().frame(height: 10).hidden()
                LazyVGrid(columns: tintColumns, spacing: tintSpacing) {
                    ForEach(TintColor.allCases, id: \.self) { tint in
                        Button {
                            settingsManager.tintColor = tint
                        } label: {
                            ColorPreviewView(name: tint.name,
                                             selected: settingsManager.tintColor == tint,
                                             color: getColorAdjusted(tintColor: tint))
                                .frame(height: geo.size.width / 3)
                        }
                    }
                }
                .navigationTitle("colortheme")
                .padding(.horizontal, 4)
            }
        }
    }

    private func getColorAdjusted(tintColor: TintColor) -> Color {
        if colorScheme == .dark && tintColor == .blackwhite {
            return .white
        }
        return tintColor.color
    }

    // Toggle for setting days not in selected month to be greyed out slightly.
    private var greyDaysToggle: some View {
        Toggle(isOn: settingsManager.$greyed, label: {ImageLabel(title: String(localized: "dimoutside"), systemName: "lightbulb.fill", color: Color.hex("ff3c33"))})
            .toggleStyle(.switch)
    }
    
    private var offDaysToggle: some View {
        Toggle(isOn: settingsManager.$calendarShowOff, label: {ImageLabel(title: String(localized: "showoff"), systemName: "switch.2", color: Color.hex("ff3c33"))})
            .toggleStyle(.switch)
    }

    private var about: some View {
        NavigationLink("About") {
            VStack {
                Image(uiImage: UIImage(named: "SwiftShiftLogo")!)
                    .resizable()
                    .cornerRadius(20.0)
                    .frame(width: 100, height: 100, alignment: .center)
                Text("SwiftShift")
                    .padding(.top, 30)
                    .font(.system(size: 26.0))
            }
        }
    }

    @State var iCloud: Bool = false
    private var iCloudToggle: some View {
        Toggle(isOn: $iCloud) {
            ImageLabel(title: String(localized: "iCloudSync"), systemName: "cloud.fill", color: Color.hex("036bfc"))
        }
        .onAppear { iCloud = persistenceController.cloud }
        .onChange(of: iCloud) { persistenceController.enableiCloud($0) }
    }

    @State private var showingDeleteAlert = false
    private var deleteAllData: some View {
        Button("eraseall", role: .destructive, action: {showingDeleteAlert = true})
        .alert("eraseallalert", isPresented: $showingDeleteAlert) {
            Button("delete", role: .destructive) {
                Task {
                    CalendarManager(noLoad: true).deleteAll()
                    await ShiftManager(noLoad: true).deleteAll()
                    await PatternManager(noLoad: true).deleteAll()
                }
            }
        } message: {
            Text("eraseallmessage")
        }

    }

    private let typeNames = [
        String(localized: "indicatoroff"),
        String(localized: "indicatortype1"),
        String(localized: "indicatortype2"),
        String(localized: "indicatortype3"),
        String(localized: "indicatortype4")
    ]

    private var todayIndicatorSelector: some View {
        ScrollView {
            Rectangle().frame(height: 6).hidden()

            LazyVGrid(columns: [GridItem(spacing: 16), GridItem(spacing: 16)], spacing: 16) {
                ForEach(0...4, id: \.self) { index in
                    Button {
                        withAnimation { settingsManager.todayIndicatorType = index }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .foregroundColor(.primary)
                                .opacity(0.1)

                            if settingsManager.todayIndicatorType == index {
                                VStack {
                                    HStack {
                                        Spacer()
                                        CustomMarker(size: 24, primary: .blue, icon: "checkmark")
                                            .shadow(radius: 1)
                                            .padding(8)
                                    }
                                    Spacer()
                                }
                            }

                            VStack(spacing: 16) {
                                DateView(id: index,
                                         date: CalendarDate(id: index, date: Date.now, day: "12", greyed: false),
                                         greyed: false,
                                         offDay: settingsManager.calendarShowOff,
                                         today: index,
                                         tintColor: settingsManager.tintColor)
                                .frame(width: 60, height: 96)

                                Text(typeNames[index])
                                    .dynamicTypeSize(.small ... .xxxLarge)
                                    .multilineTextAlignment(.center)
                                    .bold()
                                    .foregroundColor(.primary)
                            }
                            .padding(16)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("todayindicator")
        .animation(.easeInOut, value: settingsManager.todayIndicatorType)
    }

    private func openWebsite() {
        if let url = URL(string: "https://olliemunday.co.uk/simpleshift") {
            UIApplication.shared.open(url)
        }
    }
}


