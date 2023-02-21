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
                        ToolbarItemGroup(placement: .navigationBarLeading) { editButton; shareButton; }
                        ToolbarItemGroup(placement: .navigationBarTrailing) { todayButton }
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
        .onChange(of: snapshotImage, perform: { newValue in
            showShareSheet = true
        })
        .popover(isPresented: $showShareSheet) {
            ShareSheet(items: [snapshotImage!])
        }
    }

    private var navigationTitle: String {
        calendarManager.isApplyingPattern ? "Applying Pattern" : String(localized: "shiftcalendar")
    }

    // Set date to today.
    private var todayButton: some View {
        Button("today") {
            let now = Date.now
            if now > calendarManager.setDate { dateForward = true } else { dateForward = false }

            calendarManager.setCalendarDate(date: now)
        }
        .disabled(calendarManager.isSameMonth(date: calendarManager.getCalendarDate(date: Date.now) ?? Date.now))
    }
    // Activate editing.
    private var editButton: some View {
        Button { isEditing.toggle() } label: {
            if !isEditing {
                Image(systemName: "pencil.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .frame(height: 36)
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
                let renderer = ImageRenderer(content: CalendarRender(displayDate: calendarManager.dateViewArray.first?.date ?? "", weekday: calendarManager.weekday, accentColor: calendarManager.accentColor, dates: calendarManager.dates, shifts: shiftManager.shifts).environment(\.colorScheme, colorScheme))
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
    /// Date picker overlay
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
                .frame(height: 30)

            CalendarDateSection(isEditing: $isEditing, playHaptic: playHaptic)

            navigationSection
        }
    }


    ///=============================>
    ///  Navigation bottom bar.
    ///=============================>
    // State to pass to transition as binding if we are moving forward or backwards.
    @State var dateForward: Bool = false
    // Offset of date text via drag animation.
    @State var dateOffset: CGSize = CGSize.zero
    // Navigation bar parent.
    private var navigationSection: some View {
        ZStack {
            navigationBackground
            navigationDate
            navigationButtons
        }
        .frame(height: 50)
        .padding(.bottom, 6)
        .padding(.top, 2)
        .padding(.horizontal, 10)
        .scaleEffect(navigationIsScaled ? 0.85 : 1.0)
        .onAnimationCompleted(for: navigationIsScaled ? 1.0 : 0.0) {
            if !showDatePicker { enableDatePicker = false }
            if navigationIsScaled {
                playHaptic(intensity: 1.0, sharpness: 8, duration: 0.5)
                showDatePicker = true
                navigationIsScaled = false
            }
        }
        .animation(.interactiveSpring(dampingFraction: 0.55).speed(0.7), value: navigationIsScaled)
    }
    // Background for Navigation bar.
    private var navigationBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .foregroundColor(Color("NavBarBackground"))
            .shadow(radius: 1)
    }
    // Buttons for Navigation bar.
    private var navigationButtons: some View {
        HStack(spacing: 0) {
            let arrowColor = calendarManager.accentColor == .white ? Color.black : Color.white
            Button { if !showDatePicker { iterateMonth(forward: false) } } label: {
                ImageButton(arrow: "arrow.left.circle.fill", size: 40, color: calendarManager.accentColor, imageColor: arrowColor)
            }
            .padding(.leading, 5)
            
            Spacer()
            
            Button { if !showDatePicker { iterateMonth(forward: true) } } label: {
                ImageButton(arrow: "arrow.right.circle.fill", size: 40, color: calendarManager.accentColor, imageColor: arrowColor)
            }
            .padding(.trailing, 5)
        }
    }
    // Date display for Navigation bar.
    private var navigationDate: some View {
        ZStack{
            dateText
        }
        .gesture(dragGesture)
        .simultaneousGesture(longPress)
        .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.75), value: calendarManager.dateViewArray)
    }
    // Date Text View.
    @ViewBuilder private var dateText: some View {
        ForEach(calendarManager.dateViewArray) {
            Text($0.date)
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundColor(Color("ShiftText"))
                .transition(AnyTransition.asymmetric(insertion: .flyIn(forward: $dateForward, callback: flyInOutCallback), removal: .flyOut(forward: $dateForward)))
                .animation(.interactiveSpring(dampingFraction: 0.5), value: dateOffset)
                .offset(dateOffset)
                .drawingGroup()
        }
    }
    // Long press on bar gesture.
    private var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.2)
            .onEnded { _ in
                if showDatePicker { return }
                datePickerDate = calendarManager.setDate
                playHaptic(intensity: 0.5, sharpness: 1, duration: 0.3)
                dateOffset = .zero
                navigationIsScaled = true
                enableDatePicker = true
            }
    }
    // Drag on bar gesture.
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged({
                if showDatePicker || enableDatePicker { return }
                let width = $0.translation.width
                dateOffset = CGSize(width: width, height: 0)
            })
            .onEnded({
                // End of drag gesture and long press gesture
                let width = $0.translation.width
                dateOffset = .zero
                navigationIsScaled = false
                if showDatePicker || enableDatePicker { return }
                if width > 80 { iterateMonth(forward: false) }
                if width < -80 { iterateMonth(forward: true) }
            })
    }
    // Function to execute on animation completion.
    private func flyInOutCallback() {
        if showDatePicker { return }
        self.calendarManager.setMonth()
    }
    // Iterate calendarManager month
    private func iterateMonth(forward: Bool) {
        dateForward = forward
        calendarManager.iterateMonth(value: forward ? 1 : -1)
    }


    ///=============================>
    /// Core Haptics Functionality
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
