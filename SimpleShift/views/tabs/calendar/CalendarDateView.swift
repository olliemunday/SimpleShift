//
//  CalendarDateView.swift
//  SwiftShift
//
//  Created by Ollie on 06/11/2022.
//

import SwiftUI
import CoreHaptics

struct CalendarDateView: View, Sendable {
    @EnvironmentObject private var calendarManager: CalendarManager
    @EnvironmentObject private var shiftManager: ShiftManager
    @EnvironmentObject private var hapticManager: HapticManager
    @EnvironmentObject private var calendarPattern: CalendarPattern

    @Binding var dateForward: Bool
    @Binding var isEditing: Bool
    @State var showBulkEdit: Bool = false
    @State var showPatternConfirm: Bool = false
    @State private var calendarHoldScale: Bool = false
    @State private var slideOffset: Double = 0

    // Disable dragging for a time to prevent excessive scrolling
    @State private var disableInput = false

    var body: some View {
        ZStack {
            calendarSelectionGrid.hidden()
            calendarSection
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
        .animation(.interactiveSpring(response: 0.7, dampingFraction: 0.65), value: calendarManager.datesPage.id)
        .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.55), value: calendarHoldScale)
        .animation(.spring(), value: slideOffset)
        .gesture(calendarDrag)
        .simultaneousGesture(calendarEditHold)
    }

    // Selected Dates
    @State private var selectedViews: [Int] = []
    // View boundaries
    @State private var senseData: [SensePreferenceData] = []
    // Is User currently selecting
    @State private var isSelecting: Bool = false

    let gridSpacing: CGFloat = 2.0
    var gridColumns: Array<GridItem> { Array(repeating: GridItem(spacing: gridSpacing), count: 7) }

    // Dates display.
    private var calendarSection: some View {
        GeometryReader { geo in
            LazyVGrid(columns: gridColumns, spacing: gridSpacing) {
                ForEach(calendarManager.datesPage.dates) { date in
                    DateView(id: date.id,
                             date: date,
                             template: shiftManager.getShiftOrNil(id: date.templateId),
                             greyed: calendarManager.greyed,
                             offDay: calendarManager.showOff,
                             today: calendarManager.isToday(date: date.date) ? calendarManager.todayIndicatorType : 0,
                             tintColor: calendarManager.tintColor)
                        .id(date.id)
                        .frame(height: (geo.size.height / 6) - gridSpacing)
                }
            }
            .padding(2.0)
        }
        // ID Tag off the month id this way we only transition when the month actually changes and not for edits or iCloud updates.
        .id(calendarManager.datesPage.id)
        .transition(pageSlideTransition)
    }

    private var pageSlideTransition: AnyTransition {
        AnyTransition.asymmetric(insertion: .move(edge: dateForward ? .bottom : .top).combined(with: .opacity),
                                     removal: .move(edge: dateForward ? .top : .bottom).combined(with: .opacity))
    }

    // Hidden selection grid to obtain touch coordinates.
    private var calendarSelectionGrid: some View {
        GeometryReader { geo in
            LazyVGrid(columns: gridColumns, spacing: gridSpacing) {
                ForEach(0...41, id: \.self) { index in
                    Color.red
                        .frame(height: (geo.size.height/6) - gridSpacing)
                        .background(
                            GeometryReader { geo in Color.clear.preference(key: SensePreferenceKey.self, value: [SensePreferenceData(index: index, bounds: geo.frame(in: .named("MonthView")))])}
                        )
                }
            }
            .padding(2.0)
            .coordinateSpace(name: "MonthView")
            .onPreferenceChange(SensePreferenceKey.self, perform: { data in
                DispatchQueue.main.async { senseData = data }
            })
            .popover(isPresented: $showBulkEdit) {
                NavigationView { bulkEditor.navigationTitle("selectshift") }
                    .presentationDetents([.fraction(0.8), .large])
                    .onDisappear { calendarManager.finishSelect() }
            }
            .popover(isPresented: $showPatternConfirm, content: {
                NavigationView { patternConfirmation.navigationBarTitle("Confirm Pattern", displayMode: .inline) }
                        .presentationDetents([.fraction(0.33), .medium])
                        .onDisappear { calendarManager.finishSelect(); calendarPattern.deselectPattern() }
            })
        }
    }

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
                            calendarManager.setSelectionEnd(id: data.index)
                        }

                    }
                } else {
                    isHolding = true
                    if drag.translation.height > 0 { dateForward = false } else { dateForward = true }
                    slideOffset = drag.translation.height
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
                    if isEditing { showBulkEdit.toggle(); isSelecting.toggle() }
                } else {
                    let height = $0.translation.height
                    if height > 0 { dateForward = false } else { dateForward = true }
                    calendarHoldScale = false
                    if abs(height) < 50 { slideOffset = 0; return }
                    disableInput = true
                    Task {
                        try await Task.sleep(for: .milliseconds(100))
                        calendarManager.iterateMonth(value: height > 0 ? -1 : 1)
                        await calendarManager.setMonth()
                        slideOffset = 0
                        try await Task.sleep(for: .milliseconds(500))
                        disableInput = false
                    }
                    isHolding = false
                }
            }
    }
    // View to select shift for selected dates.
    private var bulkEditor: some View {
        ShiftSelector { calendarManager.setSelectedDates(templateId: $0) }
        actionDelete: {
            calendarManager.deleteSelectedDates()
        }

    }

    @State private var repeatCount: Int = 1
    private var patternConfirmation: some View {
        List {
            Stepper(value: $repeatCount, in: 1...10) {
                Text("Repeat : \(repeatCount)")
            }
            
            Button("Apply Pattern") {
                calendarManager.setPatternFromDate(pattern: calendarPattern.applyingPattern, repeatCount: repeatCount)
                showPatternConfirm = false
                isEditing = false
                calendarPattern.isApplyingPattern = false
                calendarPattern.applyingPattern = nil
            }
        }

    }

    // Apply shift template to selected dates.
    func selectTemplate(templateId: UUID) {
        calendarManager.setSelectedDates(templateId: templateId)
    }

}
