//
//  SettingsView.swift
//  ShiftCal
//
//  Created by Ollie on 22/03/2022.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsController = SettingsManager()

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

    private let tintOptions: [(String, Color)] = [
        ("blue", .blue),
        ("red", .red),
        ("green", .green),
        ("orange", .orange),
        ("purple", .purple),
        ("cyan", .cyan),
        ("mint", .mint),
        ("pink", .pink),
        ("indigo", .indigo),
        ("yellow", .yellow),
        ("teal", .teal),
        ("maroon", .hex("800000")),
        ("darkorange", Color(uiColor: #colorLiteral(red: 0.8608909249, green: 0.1735971868, blue: 0.08356299251, alpha: 1))),
        ("darkgreen", Color(uiColor: #colorLiteral(red: 0.3049176335, green: 0.5427229404, blue: 0.1484210789, alpha: 1))),
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
                    NavigationLink(value: Navigation.tint, label: {ImageLabel(title: String(localized: "accentcolor"), systemName: "paintpalette.fill", color: .accentColor, symbolColor: settingsController.accentColor == .white ? Color.black : Color.white)})
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
                            Text("SimpleShift v1.1\n© 2023 Ollie Munday")
                                .padding(.vertical, 10)
                            Spacer()
                        }
                        Rectangle()
                            .hidden()
                            .overlay { SpinningGradientLogo(size: 80).offset(y: 220) }
                    }
                }

            }
            .navigationTitle("settings")
            .navigationDestination(for: Navigation.self) { value in
                switch value {
                case .weekday: weekdaySelection
                case .tint: tintSelection
                case .today: todayIndicatorSelector
                case .privacy : ScrollView { PrivacyView() }
                case .help : HelpNavigationView().environmentObject(settingsController)
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
                    settingsController.weekday = index + 1
                } label: {
                    HStack {
                        Text(weekday)
                            .foregroundColor(.primary)
                        Spacer()
                        if settingsController.weekday == index + 1 {
                            Image(systemName: "checkmark")
                                .transition(.opacity)
                        }
                    }
                }

            }
        }
        .navigationTitle("firstweekday")
        .animation(.easeInOut(duration: 0.2), value: settingsController.weekday)
    }

    let tintSpacing: CGFloat = 4
    var tintColumns: Array<GridItem> { Array(repeating: GridItem(spacing: tintSpacing), count: 3) }
    private var tintSelection: some View {
        GeometryReader { geo in
            ScrollView {
                Rectangle().frame(height: 10).hidden()
                LazyVGrid(columns: tintColumns, spacing: tintSpacing) {
                    Button {
                        withAnimation {
                            settingsController.accentColor = colorScheme == .light ? .black : .white
                            tintOptionSelected = "blackwhite"
                        }
                    } label: {
                        ColorPreviewView(name: String(localized: "blackwhite"),
                                         selected: tintOptionSelected == "blackwhite",
                                         color: colorScheme == .light ? .black : .white)
                            .frame(height: geo.size.width / 3)
                    }

                    ForEach(tintOptions, id: \.self.1) { tint in
                        let colorName = String(localized: String.LocalizationValue(tint.0))
                        Button {
                            settingsController.accentColor = tint.1
                            tintOptionSelected = tint.0
                        } label: {
                            ColorPreviewView(name: colorName,
                                             selected: tintOptionSelected == tint.0,
                                             color: tint.1)
                            .frame(height: geo.size.width / 3)
                        }
                    }
                }
                .navigationTitle("colortheme")
                .padding(.horizontal, 4)
            }
        }
    }
    
    // Toggle for setting days not in selected month to be greyed out slightly.
    private var greyDaysToggle: some View {
        Toggle(isOn: settingsController.$greyed, label: {ImageLabel(title: String(localized: "dimoutside"), systemName: "lightbulb.fill", color: Color.hex("ff3c33"))})
            .toggleStyle(.switch)
    }
    
    private var offDaysToggle: some View {
        Toggle(isOn: settingsController.$calendarShowOff, label: {ImageLabel(title: String(localized: "showoff"), systemName: "switch.2", color: Color.hex("ff3c33"))})
            .toggleStyle(.switch)
    }
    
    private var accentColorPicker: some View {
        ColorPicker("App Tint", selection: settingsController.$accentColor)
            .navigationBarTitleDisplayMode(.inline)
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
                    await CalendarManager(noLoad: true).deleteAll()
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
        String(localized: "indicatortype2") ]

    private var todayIndicatorSelector: some View {
        List {
            ForEach(0...2, id: \.self) { index in
                Section {
                    Button {
                        withAnimation { settingsController.todayIndicatorType = index }
                    } label: {
                        HStack {
                            Spacer()
                            VStack(spacing: 10) {
                                CustomMarker(size: 20, primary: settingsController.todayIndicatorType == index ? .blue : .gray, icon: "checkmark")
                                    .shadow(radius: 1)
                                IndicatorExampleView(type: index)
                                    .environmentObject(settingsController)
                            }
                            Spacer()
                        }
                    }
                } header: {
                    Text(typeNames[index])
                }
            }
        }
        .navigationTitle("todayindicator")
    }

    private func openWebsite() {
        if let url = URL(string: "https://olliemunday.co.uk/simpleshift") {
            UIApplication.shared.open(url)
        }
    }
}


