//
//  CalendarDateView.swift
//  SwiftShift
//
//  Created by Ollie on 06/11/2022.
//

import SwiftUI
import CoreHaptics

struct CalendarDateView: View, Sendable {
    @EnvironmentObject private var viewModel: CalendarPageViewModel
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

    let cornerRadius: CGFloat

    let spacing: CGFloat

    let dayFontSize: CGFloat

    // Animation for changing the page.
    let pageAnimation: Animation

    // Animation for holding down the calendar.
    let holdAnimation = Animation.interactiveSpring(response: 0.4, dampingFraction: 0.55)

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
        .animation(holdAnimation, value: calendarHoldScale)
        .gesture(calendarDrag)
        .simultaneousGesture(calendarEditHold)
        .sheet(isPresented: $showSelector) {
            NavigationView { shiftSelector.navigationTitle("selectshift") }
                .onDisappear { viewModel.deselectAll() }
            #if os(iOS)
                .presentationDetents([.fraction(0.8), .large])
            #endif
        }
        .sheet(isPresented: $showPatternConfirm) {
            NavigationView { patternConfirmation.navigationBarTitle("confirmpattern", displayMode: .inline) }
                .presentationDetents([.fraction(0.33), .medium])
                .onDisappear { viewModel.deselectAll(); calendarPattern.deselectPattern(); repeatCount = 1 }
        }
    }

    // Display dates on screen in a 7x6 grid.
    private var calendarSectionGrid: some View {
        Grid(alignment: .center,
             horizontalSpacing: spacing,
             verticalSpacing: spacing)
        {
            ForEach(viewModel.calendarPage.weeks) { week in
                GridRow {
                    ForEach(week.days) { day in
                        DateView(id: day.id,
                                 calendarDisplay: day,
                                 tintColor: viewModel.settingsManager.tintColor,
                                 cornerRadius: cornerRadius,
                                 dayFontSize: dayFontSize)
                    }
                }
            }
        }
             .padding(2)
             .id(viewModel.calendarPage.id)
             .transition(pageSlideTransition)
    }

    // Hidden grid to detect coordinates for selection
    private var calendarSelectionGrid: some View {
        Grid(alignment: .center,
             horizontalSpacing: spacing,
             verticalSpacing: spacing) {
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
                        if data.index == viewModel.getSelectionEnd() { return }
                        if (!isSelecting) {
                            viewModel.setSelectionStart(data.index)
                            isSelecting.toggle()
                        }
                        if !calendarPattern.isApplyingPattern {
                            withAnimation { viewModel.setSelectionEnd(data.index) }
                        }
                        hapticManager.medium()
                    }
                } else {
                    isHolding = true
                    if drag.translation.height > 0 { dateForward = false } else { dateForward = true }
                    withAnimation(.spring()) { slideOffset = drag.translation.height }
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
                    showSelector.toggle()
                    isSelecting.toggle()
                } else {
                    let height = $0.translation.height
                    if height > 0 { dateForward = false } else { dateForward = true }
                    calendarHoldScale = false
                    if abs(height) < 50 { withAnimation(.spring()) { slideOffset = 0 }; return }
                    disableInput = true
                    Task {
                        try await Task.sleep(for: .milliseconds(100))
                        withAnimation(pageAnimation) {
                            viewModel.iterateMonth(dateForward ? 1 : -1)
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
        ShiftSelector(shifts: viewModel.shiftManager.shifts) { viewModel.setSelectedDates($0) }
        actionDelete: { viewModel.deleteSelectedDates() }
    }

    private var patternConfirmation: some View {
        List {
            Stepper(value: $repeatCount, in: 1...10) {
                Text("\(String(localized: "repeat")) : \(repeatCount)")
            }
            
            Button("applypattern") {
                Task {
                    await viewModel.setPatternFromDate(calendarPattern.applyingPattern, repeatCount: repeatCount)
                    showPatternConfirm = false
                    isEditing = false
                    calendarPattern.isApplyingPattern = false
                    calendarPattern.applyingPattern = nil
                }
            }
        }

    }

    // Apply shift template to selected dates.
    func selectTemplate(templateId: UUID) { viewModel.setSelectedDates(templateId) }

    private var pageSlideTransition: AnyTransition {
        AnyTransition.asymmetric(insertion: .move(edge: dateForward ? .bottom : .top).combined(with: .opacity),
                                 removal: .move(edge: dateForward ? .top : .bottom).combined(with: .opacity))
    }

}
