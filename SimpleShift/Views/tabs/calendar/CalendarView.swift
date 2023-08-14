//
//  CalendarView.swift
//  SwiftShift
//
//  Created by Ollie on 09/09/2022.
//

import SwiftUI
import UIKit
import os
import Combine
import CoreHaptics
import WatchConnectivity

struct CalendarView: View, Sendable {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.timeZone) private var timeZone
    @EnvironmentObject private var calendarPattern: CalendarPattern
    @StateObject var viewModel: CalendarPageViewModel
    @StateObject private var hapticManager = HapticManager()

    @Binding var tintOptionSelected: String
    @Binding var tabSelection: Int
    @State private var navigationIsScaled = false
    @State private var isEditing: Bool = false

    // State to pass to transition as binding if we are moving forward or backwards.
    @State var dateForward: Bool = false

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
        NavigationView {
            ZStack{
                calendar
                datePickerBackground
                datePickerLayer
                renderingProgress
            }
            .environmentObject(viewModel)
            .environmentObject(hapticManager)
            .background(Color("Background"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if calendarPattern.isApplyingPattern {
                    ToolbarItem(placement: .navigationBarTrailing) { cancelPatternButton }
                } else {
                    ToolbarItemGroup(placement: .navigationBarTrailing) { editButton }
                    ToolbarItemGroup(placement: .navigationBarLeading) { todayButton; shareButton; }
                }
                ToolbarItem(placement: .principal) {
                    Text(navigationTitle)
                        .bold()
                        .dynamicTypeSize(.xSmall ... .large)
                }
            }
        }
        .navigationViewStyle(.stack)
        .onChange(of: scenePhase, perform: { if $0 == .active {
            Task { withAnimation(pageAnimation) { viewModel.setMonth() } }
            hapticManager.prepareEngine()
        } })
        .onDisappear { isEditing = false }
        .onChange(of: calendarPattern.isApplyingPattern) { applying in isEditing = applying }
        .onChange(of: tabSelection) { if !($0 == 1) { calendarPattern.deselectPattern() } }
        .onChange(of: snapshotImage) { _ in showShareSheet = true }
        .popover(isPresented: $showShareSheet) { ShareSheet(items: [snapshotImage!]) }
        .onOpenURL{ url in
            if url.absoluteString.contains("now") { viewModel.setCalendarDateToday() }
        }
    }

    /// Text to show in the Navigation Title. Changes depending on calendar mode.
    private var navigationTitle: String {
        if calendarPattern.isApplyingPattern { return String(localized: "applyingpattern") }
        if isEditing { return String(localized: "editing") }
        return String(localized: "shiftcalendar")
    }

    /// Set date to today.
    private var todayButton: some View {
        Button("today") {
            if Date.now > viewModel.setDate { dateForward = true } else { dateForward = false }
            Task {
                try await Task.sleep(for: Duration.milliseconds(200))
                withAnimation(pageAnimation) {
                    viewModel.setCalendarDateToday()
                }
            }
        }
        .disabled(viewModel.isSameMonth(Date.now))
    }

    /// Toggle editing.
    private var editButton: some View {
        Button(isEditing ? "done" : "edit" ) { isEditing.toggle() }
            .bold(isEditing)
    }

    /// Main Calendar Grid
    private var calendar: some View {
        VStack(spacing: 0) {
            WeekdayBar(weekday: viewModel.calendarManager.weekday,
                       cornerRadius: 12,
                       tintColor: viewModel.settingsManager.tintColor)
                .padding(.horizontal, 2)
                .padding(.bottom, 1)
                .frame(height: 30)
                .zIndex(2)

            CalendarDateView(dateForward: $dateForward,
                             isEditing: $isEditing,
                             cornerRadius: 10,
                             spacing: 2,
                             dayFontSize: 14,
                             pageAnimation: pageAnimation)
                .zIndex(1)

            NavigationBarView(navigationIsScaled: $navigationIsScaled,
                              enableDatePicker: $enableDatePicker,
                              showDatePicker: $showDatePicker,
                              isEditing: $isEditing,
                              datePickerDate: $datePickerDate,
                              dateForward: $dateForward)
                .zIndex(2)
                .padding(.top, 2)
        }
    }

    @ViewBuilder private var renderingProgress: some View {
        if showRendering {
            Rectangle()
                .foregroundColor(.black)
                .opacity(0.1)
            VStack(alignment: .center) {
                Spacer()
                ZStack {
                    Rectangle()
                        .cornerRadius(18)
                        .opacity(0.7)
                        .foregroundColor(.black)
                    VStack(spacing: 20) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.3)
                        Text("exporting")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .semibold, design: .rounded))

                    }
                }
                .frame(width: 200, height: 140, alignment: .center)
                Spacer()
            }
            .transition(.opacity)
        }
    }

    @State private var showShareSheet: Bool = false
    @State private var snapshotImage: UIImage?
    @State private var showRendering: Bool = false
    private var shareButton: some View {
        Button {
            showRendering = true
            Task {
                try await Task.sleep(for: .milliseconds(500))
                let renderer = ImageRenderer(content: CalendarRender(calendarPage: viewModel.calendarPage,
                                                                     weekday: viewModel.settingsManager.weekday,
                                                                     tintColor: viewModel.settingsManager.tintColor,
                                                                     shifts: viewModel.shiftManager.shifts)
                    .environment(\.colorScheme, colorScheme))
                renderer.proposedSize = ProposedViewSize(width: 400, height: 660)
                renderer.scale = 3
                snapshotImage = renderer.uiImage
                showRendering = false
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .frame(height: 36)
        .padding(.bottom, 3)

    }

    private var cancelPatternButton: some View {
        Button("cancel") {
            calendarPattern.applyingPattern = nil
            calendarPattern.isApplyingPattern = false
        }
    }

    ///
    /// Date Picker overlay
    ///

    // Set before Date picker is activated.
    @State private var enableDatePicker: Bool = false
    // Activate opening of the Date picker.
    @State private var showDatePicker: Bool = false
    // State for date picker so we can compare to current date.
    @State private var datePickerDate: Date = Date.now
    // Background for when date picker is active.
    private var datePickerBackground: some View {
        Color.black
            .ignoresSafeArea()
            .opacity(showDatePicker ? 0.1 : 0.0)
            .onTapGesture { showDatePicker = false }
            .padding(.bottom, 60)
    }
    // Date picker view
    private var datePickerLayer: some View {
        VStack {
            Spacer()
            ZStack {
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                    .background(
                        Rectangle()
                            .foregroundColor(viewModel.settingsManager.tintColor.color)
                            .opacity(0.1)
                    )
                .opacity(showDatePicker ? 1 : 0.0)
                .cornerRadius(28)
                
                if showDatePicker {
                    DatePicker("", selection: $datePickerDate, displayedComponents: [.date])
                        .datePickerStyle(.wheel)
                        .clipped()
                        .labelsHidden()
                        .environment(\.timeZone, .gmt)
                        .frame(width: 280, height: 200)
                        .transition(.scaleInOut(anchor: .center, voffset: 120))
                        .onChange(of: datePickerDate) { date in
                            if viewModel.isSameMonth(datePickerDate) { return }
                            if date > viewModel.setDate { dateForward = true } else { dateForward = false }
                            Task {
                                try await Task.sleep(for: .microseconds(100))
                                viewModel.setDate = date
                                viewModel.setMonth() }
                        }
                        .onChange(of: viewModel.setDate) { new in withAnimation { datePickerDate = new } }
                }
            }
            .animation(.spring(response: 0.65, dampingFraction: 0.55), value: showDatePicker)
            .frame(width: showDatePicker ? 330 : 100, height: showDatePicker ? 200 : 56)
            .padding(.bottom, showDatePicker ? 65 : 0)
            .onAnimationCompleted(for: showDatePicker ? 1 : 0) {
                if !showDatePicker { enableDatePicker = false }
            }
        }
    }

}

struct ShareSheet: UIViewControllerRepresentable {

    var items : [UIImage]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        return
    }

}
