//
//  CalendarDateView.swift
//  SwiftShift
//
//  Created by Ollie on 06/11/2022.
//

import SwiftUI
import CoreHaptics

struct CalendarDateView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @EnvironmentObject var shiftManager: ShiftManager

    @Binding var dateForward: Bool
    @Binding var isEditing: Bool
    @State var showBulkEdit: Bool = false
    @State var showPatternConfirm: Bool = false
    @State private var calendarHoldScale: Bool = false
    @State private var slideOffset: Double = 0
    var playHaptic: (Float, Float, Double) -> ()

    var body: some View {
        ZStack {
            calendarSelectionGrid.hidden()
            calendarSection
                .offset(y: slideOffset)
                .scaleEffect(calendarHoldScale ? 0.9 : 1.0)
                .onAnimationCompleted(for: calendarHoldScale ? 1.0 : 0.0, completion: {
                    if calendarHoldScale {
                        calendarHoldScale = false
                        editHaptic()
                        isEditing.toggle()
                    }
                })
                .onAnimationCompleted(for: pageAnimationActive ? 1.0 : 0.0) {
                    pageAnimationActive = false
                    calendarManager.updateViewDate()
                }
        }
        .animation(.interactiveSpring(response: 0.7, dampingFraction: 0.7), value: calendarManager.datesPage.id)
        .animation(.interactiveSpring(response: 0.7, dampingFraction: 0.7).speed(0.9), value: pageAnimationActive)
        .animation(.easeInOut, value: slideOffset)
        .animation(.interactiveSpring(response: 0.6), value: calendarHoldScale)
        .onChange(of: calendarManager.datesPage.id, perform: { _ in pageAnimationActive = true })
        .gesture(calendarDrag)
        .simultaneousGesture(calendarSelection)
        .simultaneousGesture(calendarEditHold)

    }

    // Selected Dates
    @State private var selectedViews: [Int] = []
    // View boundaries
    @State private var senseData: [SensePreferenceData] = []
    // Is User currently selecting
    @State private var isSelecting: Bool = false
    // Animation to track completion of month page animation.
    @State private var pageAnimationActive: Bool = false

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
                             accentColor: calendarManager.accentColor
                    )
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
                        .onDisappear { calendarManager.finishSelect(); calendarManager.deselectPattern() }
            })
        }
    }

    @State private var isHolding: Bool = false
    // Selection Gesture.
    private var calendarSelection: some Gesture {
        DragGesture(minimumDistance: 0.0, coordinateSpace: .named("MonthView"))
            .onChanged { drag in
                if !isEditing { isHolding = true }

                if isHolding { return }
                if let data = senseData.first(where: {$0.bounds.contains(drag.location)}) {
                    if calendarManager.selectionEnd == data.index { return }
                    if (!isSelecting) {
                        calendarManager.setSelectionStart(id: data.index)
                        isSelecting.toggle()
                    }
                    selectHaptic()
                    if !calendarManager.isApplyingPattern {
                        calendarManager.setSelectionEnd(id: data.index)
                    }

                }
            }
            .onEnded({ drag in
                if !isEditing { return }
                if isHolding {
                    isHolding = false
                    return
                }
                if calendarManager.isApplyingPattern {
                    isSelecting.toggle()
                    showPatternConfirm.toggle()
                    return
                }
                if isEditing {
                    showBulkEdit.toggle()
                    isSelecting.toggle()
                }
            })
    }
    private var calendarEditHold: some Gesture {
        LongPressGesture(minimumDuration: 0.2, maximumDistance: 0.0)
            .onEnded { _ in
                if isEditing { return }
                calendarHoldScale = true
                selectHaptic()
            }
    }

    // Drag calendar up & down to navigate months.
    private var calendarDrag: some Gesture {
        DragGesture(minimumDistance: 0.0, coordinateSpace: .named("MonthView"))
            .onChanged({
                if isEditing || calendarHoldScale || pageAnimationActive { return }
                if $0.translation.height > 0 { dateForward = false } else { dateForward = true }
                slideOffset = $0.translation.height
            })
            .onEnded {
                if isEditing || pageAnimationActive { return }
                calendarHoldScale = false
                slideOffset = 0
                if abs($0.translation.height) < 50 { return }
                if $0.translation.height > 0 { dateForward = false } else { dateForward = true }
                calendarManager.iterateMonthNoDisplay(value: $0.translation.height > 0 ? -1 : 1)
                calendarManager.setMonth()
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
                calendarManager.setPatternFromDate(repeatCount: repeatCount)
                showPatternConfirm = false
                isEditing = false
                calendarManager.isApplyingPattern = false
                calendarManager.applyingPattern = nil
            }
        }

    }

    private var patternRepresentation: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color("PatternBackground"))
            VStack {
                HStack {
                    Text(calendarManager.applyingPattern?.name ?? "Pattern")
                        .padding(8)
                    Spacer()

//                    HStack {
//                        ForEach(calendarManager.applyingPattern?.weekArray.first?.shiftArray ?? []) { shift in
//
//                            GradientRounded(cornerRadius: 12, colors: , direction: .vertical)
//
//                        }
//                    }
                }
                Spacer()
                .padding(3)
            }
        }
    }

    // Apply shift template to selected dates.
    func selectTemplate(templateId: UUID) {
        calendarManager.setSelectedDates(templateId: templateId)
    }

    private func selectHaptic() { playHaptic(0.5, 8, 0.5) }
    private func editHaptic() { playHaptic( 1, 8, 0.5 ) }



}
