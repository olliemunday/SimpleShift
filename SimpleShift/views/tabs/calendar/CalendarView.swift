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

struct CalendarView: View {
    /// External variables/objects
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.timeZone) private var timeZone
    @EnvironmentObject private var calendarManager: CalendarManager
    @EnvironmentObject private var shiftManager: ShiftManager

    @Binding var tintOptionSelected: String
    @Binding var tabSelection: Int
    @State private var hapticEngine: CHHapticEngine?
    @State private var navigationIsScaled = false
    @State private var isEditing: Bool = false
    // State to pass to transition as binding if we are moving forward or backwards.
    @State var dateForward: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack{
                calendar
                datePickerBackground
                datePickerLayer
                renderingProgress
            }
                .background(Color("Background"))
                .navigationBarTitle(navigationTitle, displayMode: .inline)
                .toolbar {
                    if calendarManager.isApplyingPattern {
                        ToolbarItem(placement: .navigationBarTrailing) { cancelPatternButton }
                    } else {
                        ToolbarItemGroup(placement: .navigationBarTrailing) { editButton }
                        ToolbarItemGroup(placement: .navigationBarLeading) { todayButton; shareButton; }
                    }
                }
        }
        .navigationViewStyle(.stack)
        .onChange(of: scenePhase, perform: { if $0 == .active {
            if tintOptionSelected == "blackwhite" { withAnimation { calendarManager.accentColor = colorScheme == .light ? .black : .white } }
            calendarManager.setMonth()
            prepareHaptics()
        } })
        .onDisappear { isEditing = false }
        .onAppear() { calendarManager.setMonth(); prepareHaptics() }
        .onChange(of: calendarManager.isApplyingPattern) { applying in isEditing = applying }
        .onChange(of: tabSelection) { if !($0 == 1) { calendarManager.deselectPattern() } }
        .onChange(of: snapshotImage, perform: { _ in showShareSheet = true })
        .popover(isPresented: $showShareSheet) {
            ShareSheet(items: [snapshotImage!])
        }
    }

    private var navigationTitle: String {
        if calendarManager.isApplyingPattern { return "Applying Pattern" }
        if isEditing { return "Editing" }
        return String(localized: "shiftcalendar")
    }

    // Set date to today.
    private var todayButton: some View {
        Button("today") {
            if Date.now > calendarManager.setDate { dateForward = true } else { dateForward = false }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {calendarManager.setCalendarDateToday()})

        }
        .disabled(calendarManager.isSameMonth(date: calendarManager.getCalendarDate(date: Date.now) ?? Date.now))
    }
    // Toggle editing.
    private var editButton: some View {
        Button(isEditing ? "done" : "edit" ) {
            isEditing.toggle()
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

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let renderer = ImageRenderer(content: CalendarRender(displayDate: calendarManager.dateDisplay, weekday: calendarManager.weekday, accentColor: calendarManager.accentColor, dates: calendarManager.datesPage.dates, shifts: shiftManager.shifts).environment(\.colorScheme, colorScheme))
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
        Button("Cancel") {
            calendarManager.applyingPattern = nil
            calendarManager.isApplyingPattern = false
        }
    }

    ///=============================>
    /// Date Picker overlay
    ///=============================>
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
                let blurEffect = UIBlurEffect(style: colorScheme == .light ? .extraLight : .dark)

                ZStack {
                    VisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
                    VisualEffectView(effect: blurEffect)
                }
                .opacity(showDatePicker ? 1 : 0.0)
                .cornerRadius(28)
                
                if showDatePicker {
                    FixedDatePicker(selection: $datePickerDate)
                        .environment(\.timeZone, .gmt)
                        .frame(width: 280, height: 200)
                        .transition(.scaleInOut(anchor: .center, voffset: 120))
                        .onChange(of: datePickerDate) {
                            if calendarManager.isSameMonth(date: datePickerDate) { return }
                            if datePickerDate > calendarManager.setDate { dateForward = true } else { dateForward = false }
                            calendarManager.setDate = datePickerDate
                            calendarManager.setCalendarDate(date: $0)
                            calendarManager.setMonth()
                        }
                }
            }
            .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.55), value: showDatePicker)
            .frame(width: showDatePicker ? 330 : 100, height: showDatePicker ? 200 : 56)
            .padding(.bottom, showDatePicker ? 60 : 0)
            .onAnimationCompleted(for: showDatePicker ? 1 : 0) {
                if !showDatePicker { enableDatePicker = false }
            }
        }
    }

    private var calendar: some View {
        VStack(spacing: 0) {
            WeekdayBar(weekday: calendarManager.weekday, accentColor: calendarManager.accentColor)
                .padding(.horizontal, 2)
                .padding(.bottom, 1)
                .frame(height: 30)
                .zIndex(2)

            CalendarDateView(dateForward: $dateForward,isEditing: $isEditing, playHaptic: playHaptic)
                .zIndex(1)

            NavigationBarView(navigationIsScaled: $navigationIsScaled,
                              enableDatePicker: $enableDatePicker,
                              showDatePicker: $showDatePicker,
                              isEditing: $isEditing,
                              datePickerDate: $datePickerDate,
                              dateForward: $dateForward,
                              playHaptic: playHaptic)
                .zIndex(2)
                .padding(.top, 2)
        }
    }

    ///=============================>
    /// Core Haptics Events
    ///=============================>
    // Prepare Haptics.
    private func prepareHaptics() {
        hapticEngine = CHHapticEngine.prepareEngine()
    }
    // Play a haptic event.
    private func playHaptic(intensity: Float, sharpness: Float, duration: Double) {
        hapticEngine?.playHaptic(intensity: intensity, sharpness: sharpness, duration: duration)
    }
    // Haptic for selection.
    private func selectHaptic() { playHaptic(intensity: 0.5, sharpness: 8, duration: 0.5) }

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
