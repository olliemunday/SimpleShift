//
//  CalendarLayout.swift
//  SwiftShift
//
//  Created by Ollie on 06/11/2022.
//

import SwiftUI
import CoreHaptics

struct CalendarDateAnimSection: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @EnvironmentObject var shiftManager: ShiftManager

    @Binding var isEditing: Bool
    @State var showBulkEdit: Bool = false
    @State var showPatternConfirm: Bool = false
    var playHaptic: (Float, Float, Double) -> ()

    let gridSpacing: CGFloat = 2.0
    var gridColumns: Array<GridItem> { Array(repeating: GridItem(spacing: gridSpacing), count: 7) }

    var body: some View {
        calendarSection
    }

    // Selected Dates
    @State private var selectedViews: [Int] = []
    // View boundaries
    @State private var senseData: [SensePreferenceData] = []
    // Is User currently selecting
    @State private var isSelecting: Bool = false
    // Dates display.
    private var calendarSection: some View {
        return GeometryReader { geo in
            LazyVGrid(columns: gridColumns, spacing: gridSpacing) {
                let greyed = calendarManager.greyed
                let offDay = calendarManager.showOff

                ZStack {
                    ForEach(calendarManager.datesArray) { page in
                        LazyVGrid(columns: gridColumns, spacing: gridSpacing) {
                            ForEach(page.dates.indices, id: \.self) { index in
                                let date = calendarManager.dates[index]
                                let today = calendarManager.isToday(date: date.date) ? calendarManager.todayIndicatorType : 0
                                DateView(id: date.id, date: date, template: shiftManager.getShiftOrNil(id: date.templateId), greyed: greyed, offDay: offDay, today: today, accentColor: calendarManager.accentColor)
                                    .frame(height: (geo.size.height / 6) - gridSpacing)
                                    .frame(width: (geo.size.width / 7) - gridSpacing)
                                    .id(index)
                            }
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                }

//                ForEach(calendarManager.dates.indices, id: \.self) { index in
//                    let date = calendarManager.dates[index]
//                    let today = calendarManager.isToday(date: date.date) ? calendarManager.todayIndicatorType : 0
//                    DateView(id: date.id, date: date, template: shiftManager.getShiftOrNil(id: date.templateId), greyed: greyed, offDay: offDay, today: today, accentColor: calendarManager.accentColor)
//                        .frame(height: (geo.size.height / 6) - gridSpacing)
//                        .id(index)
//                    }
                }
        }
            .padding(.all, 2.0)
            .onPreferenceChange(SensePreferenceKey.self, perform: { data in
                DispatchQueue.main.async { senseData = data }
            })
            .gesture(calendarSelection)
            .simultaneousGesture(calendarEditHold)
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
            .coordinateSpace(name: "MonthView")
    }

//    @ViewBuilder var pages: some View {
//        let greyed = calendarManager.greyed
//        let offDay = calendarManager.showOff
//        ForEach(calendarManager.datesArray) { page in
//            LazyVGrid(columns: gridColumns, spacing: gridSpacing) {
//                ForEach(page.dates.indices, id: \.self) { index in
//                    let date = calendarManager.dates[index]
//                    let today = calendarManager.isToday(date: date.date) ? calendarManager.todayIndicatorType : 0
//                    DateView(id: date.id, date: date, template: shiftManager.getShiftOrNil(id: date.templateId), greyed: greyed, offDay: offDay, today: today, accentColor: calendarManager.accentColor)
//                        .frame(height: (geo.size.height / 6) - gridSpacing)
//                        .id(index)
//                }
//            }
//        }
//    }


    @State private var isHolding: Bool = false
    // Selection Gesture.
    private var calendarSelection: some Gesture {
        DragGesture(minimumDistance: 0.0, coordinateSpace: .named("MonthView"))
            .onChanged { drag in
                if !isEditing {
                    isHolding = true
                }
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
        LongPressGesture(minimumDuration: 1.0, maximumDistance: 0.0)
            .onEnded { _ in
                if isEditing { return }
                editHaptic()
                isEditing.toggle()
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
