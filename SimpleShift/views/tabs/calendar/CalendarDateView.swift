//
//  CalendarDateView.swift
//  SwiftShift
//
//  Created by Ollie on 06/11/2022.
//

import SwiftUI
import CoreHaptics

struct CalendarDateView: View, Sendable {
    @EnvironmentObject private var calendarManager: CalendarPageManager
    @EnvironmentObject private var shiftManager: ShiftManager
    @EnvironmentObject private var hapticManager: HapticManager
    @EnvironmentObject private var calendarPattern: CalendarPattern

    // Is the next date more than or less than the current date?
    @Binding var dateForward: Bool

    // Is in editing mode?
    @Binding var isEditing: Bool

    // Show shift selector
    @State var showSelector: Bool = false

    // Is in pattern confirmation mode?
    @State var showPatternConfirm: Bool = false

    // Should calendar be scaled down? Used for editing gesture.
    @State private var calendarHoldScale: Bool = false

    // Offset of the grid when being dragged.
    @State private var slideOffset: Double = 0

    // Disable dragging for a time to prevent excessive scrolling
    @State private var disableInput = false

    // View boundaries
    @State private var senseData: [SensePreferenceData] = []

    // Is User currently selecting
    @State private var isSelecting: Bool = false

    // Amount of times to repeat the pattern being applied.
    @State private var repeatCount: Int = 1

    var body: some View {
        ZStack {
            calendarSelectionGrid.hidden()
            calendarSectionGrid
                .offset(y: slideOffset)
                .scaleEffect(calendarHoldScale ? 0.9 : 1.0)
                .onAnimationCompleted(for: calendarHoldScale ? 1.0 : 0.0, completion: {
                    if calendarHoldScale {
                        calendarHoldScale = false
                        hapticManager.medium()
                        isEditing.toggle()
                    }
                })
        }
        .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.55), value: calendarHoldScale)
        .gesture(calendarDrag)
        .simultaneousGesture(calendarEditHold)
        .popover(isPresented: $showSelector) {
            NavigationView { shiftSelector.navigationTitle("selectshift") }
                .presentationDetents([.fraction(0.8), .large])
                .onDisappear { calendarManager.deselectAll() }
        }
        .popover(isPresented: $showPatternConfirm, content: {
            NavigationView { patternConfirmation.navigationBarTitle("confirmpattern", displayMode: .inline) }
                    .presentationDetents([.fraction(0.33), .medium])
                    .onDisappear { calendarManager.deselectAll(); calendarPattern.deselectPattern() }
        })
    }

    // Display dates on screen in a 7x6 grid.
    private var calendarSectionGrid: some View {
        Grid(alignment: .center,
             horizontalSpacing: 2,
             verticalSpacing: 2) {
            let greyed = calendarManager.greyed
            let off = calendarManager.showOff
            let tint = calendarManager.tintColor
            let todayType = calendarManager.todayIndicatorType
            ForEach(calendarManager.calendarPage.weeks) { week in
                GridRow {
                    ForEach(week.days) { day in
                        let today = calendarManager.isToday(date: day.date) ? todayType : 0
                        let template = shiftManager.getShiftOrNil(id: day.templateId)
                        DateView(id: day.id,
                                 date: day,
                                 template: template,
                                 greyed: greyed,
                                 offDay: off,
                                 today: today,
                                 tintColor: tint)
                    }
                }
            }
        }
             .padding(2.0)
             .id(calendarManager.calendarPage.id)
             .transition(pageSlideTransition)
    }

    // Hidden grid to detect coordinates for selection
    private var calendarSelectionGrid: some View {
        Grid(alignment: .center,
             horizontalSpacing: 2,
             verticalSpacing: 2) {
            ForEach(0..<6) { row in
                GridRow {
                    ForEach(0..<7) { item in
                        Rectangle()
                            .background(
                                GeometryReader { geo in
                                    let index = item + (row * 7)
                                    Color.clear.preference(key: SensePreferenceKey.self,
                                                           value: [SensePreferenceData(index: index,
                                                                                              bounds: geo.frame(in: .named("MonthView")))])}
                            )
                    }
                }
            }
        }
             .padding(2)
             .coordinateSpace(name: "MonthView")
             .onPreferenceChange(SensePreferenceKey.self, perform: { data in
                 DispatchQueue.main.async { senseData = data }
             })
    }

    // Gesture for enabling editing of the grid
    private var calendarEditHold: some Gesture {
        LongPressGesture(minimumDuration: 0.2, maximumDistance: 0.0)
            .onEnded { _ in
                if isEditing { return }
                calendarHoldScale = true
                hapticManager.light()
            }
    }

    // Prevent selection starting whilst long press to edit is active
    @State private var isHolding: Bool = false

    // Drag calendar up & down to navigate months.
    private var calendarDrag: some Gesture {
        DragGesture(minimumDistance: 0.0, coordinateSpace: .named("MonthView"))
            .onChanged({ drag in
                if disableInput || calendarHoldScale { return }

                if isEditing {
                    if isHolding { return }
                    if let data = senseData.first(where: {$0.bounds.contains(drag.location)}) {
                        if calendarManager.selectionEnd == data.index { return }
                        if (!isSelecting) {
                            calendarManager.setSelectionStart(id: data.index)
                            isSelecting.toggle()
                        }
                        hapticManager.medium()
                        if !calendarPattern.isApplyingPattern {
                            withAnimation(.default) {
                                calendarManager.setSelectionEnd(id: data.index)
                            }

                        }

                    }
                } else {
                    isHolding = true
                    if drag.translation.height > 0 { dateForward = false } else { dateForward = true }
                    withAnimation(.spring()) {
                        slideOffset = drag.translation.height
                    }
                }

            })
            .onEnded {
                if disableInput { return }
                if isEditing {
                    if isHolding { isHolding = false; return }
                    if calendarPattern.isApplyingPattern {
                        isSelecting.toggle()
                        showPatternConfirm.toggle()
                        return
                    }
                    if isEditing { showSelector.toggle(); isSelecting.toggle() }
                } else {
                    let height = $0.translation.height
                    if height > 0 { dateForward = false } else { dateForward = true }
                    calendarHoldScale = false
                    if abs(height) < 50 { withAnimation(.spring()) { slideOffset = 0 }; return }
                    disableInput = true
                    Task {
                        try await Task.sleep(for: .milliseconds(100))
                        calendarManager.iterateMonth(value: height > 0 ? -1 : 1)
                        withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.65)) {
                            calendarManager.setMonth()
                            slideOffset = 0
                        }

                        try await Task.sleep(for: .milliseconds(500))
                        disableInput = false
                    }
                    isHolding = false
                }
            }
    }

    // View to select shift for selected dates.
    private var shiftSelector: some View {
        ShiftSelector { calendarManager.setSelectedDates(templateId: $0) }
        actionDelete: {
            calendarManager.deleteSelectedDates()
        }

    }

    private var patternConfirmation: some View {
        List {
            Stepper(value: $repeatCount, in: 1...10) {
                Text("Repeat : \(repeatCount)")
            }
            
            Button("applypattern") {
                Task {
                    calendarManager.setPatternFromDate(pattern: calendarPattern.applyingPattern, repeatCount: repeatCount)
                    showPatternConfirm = false
                    isEditing = false
                    calendarPattern.isApplyingPattern = false
                    calendarPattern.applyingPattern = nil
                }
            }
        }

    }

    // Apply shift template to selected dates.
    func selectTemplate(templateId: UUID) {
        calendarManager.setSelectedDates(templateId: templateId)
    }

    private var pageSlideTransition: AnyTransition {
        AnyTransition.asymmetric(insertion: .move(edge: dateForward ? .bottom : .top).combined(with: .opacity),
                                 removal: .move(edge: dateForward ? .top : .bottom).combined(with: .opacity))
    }

}
