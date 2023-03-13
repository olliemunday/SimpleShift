//
//  SettingsView.swift
//  ShiftCal
//
//  Created by Ollie on 22/03/2022.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var calendarManager: CalendarManager
    @EnvironmentObject private var shiftManager: ShiftManager
    @EnvironmentObject private var patternManager: PatternManager

    @Environment(\.colorScheme) private var colorScheme

    @Binding var tintOptionSelected: String

    @State private var showPrivacy: Bool = false
    @State private var showHelp: Bool = false

    private enum Navigation: String, Hashable {
        case weekday = "Weekday"
        case tint = "Color Theme"
        case today = "Today Indicator"
        case privacy = "privacy"
        case help = "help"
    }

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
                    NavigationLink(value: Navigation.tint, label: {ImageLabel(title: String(localized: "accentcolor"), systemName: "paintpalette.fill", color: .accentColor, symbolColor: calendarManager.accentColor == .white ? Color.black : Color.white)})

                } header: { Text("theme") }

                Section {
                    NavigationLink(value: Navigation.privacy, label: {ImageLabel(title: String(localized: "privacy"), systemName: "hand.raised.fill", color: .blue)})
                    NavigationLink(value: Navigation.help, label: {ImageLabel(title: String(localized: "help"), systemName: "questionmark", color: .blue)})
                    Button(action: {openWebsite()}, label: {ImageLabel(title: String(localized: "website"), systemName: "safari.fill", color: .blue)})
                } header: {
                    Text("information")
                }

                Section { deleteAllData } header: { Text("data") }
                footer: { Text("SimpleShift v1.1b3\n© 2023 Ollie Munday").padding(.vertical, 10) }
            }
            .navigationTitle("settings")
            .navigationDestination(for: Navigation.self) { value in
                switch value {
                case .weekday: weekdaySelection
                case .tint: tintSelection
                case .today: todayIndicatorSelector
                case .privacy : ScrollView { PrivacyView() }
                case .help : HelpNavigationView()
                }
            }
            .popover(isPresented: $showPrivacy) { PrivacyView() }
            .popover(isPresented: $showHelp, content: { HelpView().presentationDetents([.fraction(0.7), .large]) })
        }
        .environment(\.defaultMinListRowHeight, 46)
        .navigationViewStyle(.stack)
    }

    let Weekdays = [
        WeekdayOption(id: 0, name: String(localized: "sunday")),
        WeekdayOption(id: 1, name: String(localized: "monday")),
        WeekdayOption(id: 2, name: String(localized: "tuesday")),
        WeekdayOption(id: 3, name: String(localized: "wednesday")),
        WeekdayOption(id: 4, name: String(localized: "thursday")),
        WeekdayOption(id: 5, name: String(localized: "friday")),
        WeekdayOption(id: 6, name: String(localized: "saturday")),
    ]

    private let tintOptions: [TintOption] = [
        TintOption(id: "blue", name: String(localized: "blue"), color: .blue),
        TintOption(id: "red", name: String(localized: "red"), color: .red),
        TintOption(id: "green", name: String(localized: "green"), color: .green),
        TintOption(id: "orange", name: String(localized: "orange"), color: .orange),
        TintOption(id: "purple", name: String(localized: "purple"), color: .purple),
        TintOption(id: "cyan", name: String(localized: "cyan"), color: .cyan),
        TintOption(id: "mint", name: String(localized: "mint"), color: .mint),
        TintOption(id: "pink", name: String(localized: "pink"), color: .pink),
        TintOption(id: "indigo", name: String(localized: "indigo"), color: .indigo),
        TintOption(id: "yellow", name: String(localized: "yellow"), color: .yellow),
        TintOption(id: "teal", name: String(localized: "teal"), color: .teal),
        TintOption(id: "maroon", name: String(localized: "maroon"), color: Color.hex("800000")),
        TintOption(id: "darkorange", name: String(localized: "darkorange"), color: Color(uiColor: #colorLiteral(red: 0.8608909249, green: 0.1735971868, blue: 0.08356299251, alpha: 1)) ),
        TintOption(id: "darkgreen", name: String(localized: "darkgreen"), color: Color(uiColor: #colorLiteral(red: 0.3049176335, green: 0.5427229404, blue: 0.1484210789, alpha: 1)) )
    ]


    private var weekdaySelection: some View {
        List {
            ForEach(Weekdays) { weekday in

                Button {
                    calendarManager.weekday = weekday.id + 1
                } label: {
                    HStack{
                        Text(weekday.name)
                            .foregroundColor(.primary)
                        Spacer()
                        if calendarManager.weekday == (weekday.id+1) {
                            Image(systemName: "checkmark")
                                .transition(.opacity)
                        }
                    }
                }

            }
        }
        .navigationTitle("firstweekday")
        .animation(.easeInOut(duration: 0.2), value: calendarManager.weekday)
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
                            calendarManager.accentColor = colorScheme == .light ? .black : .white
                            tintOptionSelected = "blackwhite"
                        }
                    } label: {
                        ColorPreviewView(name: String(localized: "blackwhite"), selected: tintOptionSelected == "blackwhite", color: colorScheme == .light ? .black : .white)
                            .frame(height: geo.size.width / 3)
                    }

                    ForEach(tintOptions) { tint in
                        Button {
                            withAnimation {
                                calendarManager.accentColor = tint.color
                                tintOptionSelected = tint.id
                            }
                        } label: {
                            ColorPreviewView(name: tint.name, selected: tintOptionSelected == tint.id, color: tint.color)
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
        Toggle(isOn: calendarManager.$greyed, label: {ImageLabel(title: String(localized: "dimoutside"), systemName: "lightbulb.fill", color: Color.hex("ff3c33"))})
            .toggleStyle(.switch)
    }
    
    private var offDaysToggle: some View {
        Toggle(isOn: calendarManager.$showOff, label: {ImageLabel(title: String(localized: "showoff"), systemName: "switch.2", color: Color.hex("ff3c33"))})
            .toggleStyle(.switch)
    }
    
    private var accentColorPicker: some View {
        ColorPicker("App Tint", selection: calendarManager.$accentColor)
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

    @State private var iCloud: Bool = PersistenceController.cloud
    private var iCloudToggle: some View {
        Toggle(isOn: $iCloud) {
            ImageLabel(title: String(localized: "iCloudSync"), systemName: "cloud.fill", color: Color.hex("036bfc"))
        }
            .onChange(of: iCloud) { refreshCoreData(cloud: $0) }
    }

    private func refreshCoreData(cloud: Bool) {
        PersistenceController.cloud = cloud
        PersistenceController.reloadController()
        NotificationCenter.default.post(name: NSNotification.Name("CoreDataRefresh"), object: nil)
    }

    @State private var showingDeleteAlert = false
    private var deleteAllData: some View {
        Button("eraseall", role: .destructive, action: {showingDeleteAlert = true})
        .alert("eraseallalert", isPresented: $showingDeleteAlert) {
            Button("delete", role: .destructive) {
                calendarManager.deleteAll()
                shiftManager.deleteAll()
                patternManager.deleteAll()
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
                        withAnimation { calendarManager.todayIndicatorType = index }
                    } label: {
                        HStack {
                            Spacer()
                            VStack(spacing: 10) {
                                CustomMarker(size: 20, primary: calendarManager.todayIndicatorType == index ? .blue : .gray, icon: "checkmark")
                                    .shadow(radius: 1)
                                IndicatorExampleView(type: index)
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


