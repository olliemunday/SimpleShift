//
//  CalendarView.swift
//  SimpleShift Vision
//
//  Created by Ollie on 03/07/2023.
//

import SwiftUI

struct CalendarView: View {

    @EnvironmentObject var settingsManager: SettingsManager

    @StateObject var viewModel: CalendarPageViewModel
    @StateObject var hapticManager = HapticManager()

    // Is the next date more than or less than the current date?
    @State var dateForward: Bool = false

    // Is in editing mode?
    @State var isEditing: Bool = false

    @State private var navigationIsScaled = false

    @State private var showDatePicker = false

    @State private var enableDatePicker = false

    @State private var datePickerDate = Date()

    @Binding var tintOptionSelected: String
    @Binding var tabSelection: Int

    // Animation for changing pages.
    let pageAnimation = Animation.interactiveSpring(response: 0.7, dampingFraction: 0.65)

    init(settingsManager: SettingsManager,
         tintOptionSelected: Binding<String>,
         tabSelection: Binding<Int>)
    {
        _viewModel = StateObject(wrappedValue: CalendarPageViewModel(calendarManager: CalendarPageManager(),
                                                                     shiftManager: ShiftManager(),
                                                                     settingsManager: settingsManager))
        self._tintOptionSelected = tintOptionSelected
        self._tabSelection = tabSelection
    }


    var body: some View {
        NavigationStack {
            VStack(spacing: 4) {
                WeekdayBar(weekday: settingsManager.weekday,
                           spacing: 4,
                           cornerRadius: 24,
                           tintColor: settingsManager.tintColor)
                .frame(height: 36)
                .zIndex(2)
                CalendarDateView(dateForward: $dateForward,
                                 isEditing: $isEditing,
                                 cornerRadius: 24,
                                 spacing: 4,
                                 dayFontSize: 16,
                                 pageAnimation: pageAnimation)
            }
            .environmentObject(viewModel)
            .environmentObject(hapticManager)
            .padding(.bottom, 20)
            .padding(.horizontal, 14)
            .task { viewModel.setMonth() }
            .navigationTitle("shiftcalendar")
            .toolbar {
                ToolbarItem(placement: .bottomOrnament) { navigationBar }
                ToolbarItem(placement: .topBarTrailing) { shareButton }
                ToolbarItem(placement: .topBarTrailing) { todayButton }
                ToolbarItem(placement: .topBarTrailing) { editButton }
            }
        }
    }

    @MainActor
    private var editButton: some View {
        Button(isEditing ? "done" : "edit" ) { isEditing.toggle() }
            .buttonStyle(.bordered)
    }

    /// Set date to today.
    @MainActor
    private var todayButton: some View {
        Button(action: {
            if Date.now > viewModel.setDate { dateForward = true } else { dateForward = false }
            Task {
                try await Task.sleep(for: Duration.milliseconds(200))
                withAnimation(pageAnimation) {
                    viewModel.setCalendarDateToday()
                }
            }
        }, label: {
            Label("today", systemImage: "clock.arrow.circlepath")
        })
        .help("Today")
        .disabled(viewModel.isSameMonth(Date.now))
    }

    @MainActor
    private var shareButton: some View {
        Button(action: {

        }, label: {
            Label("share", systemImage: "square.and.arrow.up")
        })
    }

    @MainActor
    private var navigationBar: some View {
        NavigationBarView(navigationIsScaled: $navigationIsScaled,
                          enableDatePicker: $enableDatePicker,
                          showDatePicker: $showDatePicker,
                          isEditing: $isEditing,
                          datePickerDate: $datePickerDate,
                          dateForward: $dateForward,
                          visionBar: true)
        .frame(width: 450)
        .environmentObject(viewModel)
        .environmentObject(hapticManager)
    }
}

//#Preview {
//    CalendarView()
//}
