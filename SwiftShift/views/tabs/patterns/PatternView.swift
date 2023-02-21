//
//  PatternView.swift
//  SwiftShift
//
//  Created by Ollie on 14/09/2022.
//

import SwiftUI
import CoreHaptics

struct PatternView: View {

    // Enivronment and Binding variables
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var patternManager: PatternManager
    @EnvironmentObject var shiftManager: ShiftManager
    @EnvironmentObject var calendarManager: CalendarManager
    @Binding var tabSelection: Int
    
    // Binding to pattern in patternManager array passed from parent view.
    var pattern: Pattern
    
    @State private var senseData: [SensePreferenceData] = []
    
    // Vars for name Textfield for disable and focus
    @State private var nameDisabled: Bool = true
    @FocusState private var nameFocus: Bool
    
    @State private var isDragging: Bool = false
    @State private var showShiftSelector: Bool = false
    @State private var getBounds: Bool = true
    @State private var hapticEngine: CHHapticEngine?
    
    let zoomedIn: Bool
    
    var body: some View {
        ZStack() {
            background
            VStack(spacing: 2) {
                topBar
                weekLayer
                    .padding(.bottom, zoomedIn ? 6 : 12)
            }
        }
        .padding(.horizontal, zoomedIn ? 2 : 15)
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.75), value: pattern.weekArray)
        .onAppear { prepareHaptics() }
        .onChange(of: zoomedIn) { zoomed in if !zoomed { nameDisabled = true } }
        .onChange(of: scenePhase, perform: { scene in if scene == .active {prepareHaptics()} })
        .popover(isPresented: $showShiftSelector) { shiftSelector }
        .onTapGesture { patternToggle(id: pattern.id) }
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: zoomedIn ? 12 : 20)
            .foregroundColor(Color("PatternBackground"))
            .shadow(radius: zoomedIn ?  3 : 1)
    }
    
    /// Top Bar Section
    private var topBar: some View {
        HStack(alignment: .top) {
            patternTitle
            Spacer()
            if zoomedIn { optionsButton.transition(.scale.combined(with: .opacity)) }
        }
        .padding(.bottom, zoomedIn ? 10 : 4)
    }
    
    @State var patternName: String = ""
    private var patternTitle: some View {
        ZStack {
            TextField("pattern", text: $patternName)
                .disabled(nameDisabled)
                .focused($nameFocus)
                .onAppear { patternName = pattern.name }
                .onChange(of: patternName, perform: { name in
                    patternManager.setPatternName(id: pattern.id, name: name)
                })
                .onSubmit { nameDisabled = true }
                .font(.title)
                .fontWeight(.bold)
                .dynamicTypeSize(.small ... .xLarge)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 20)
                .padding(.top, zoomedIn ? 16 : 10)
                .padding(.bottom, 8)
            
            Rectangle()
                .opacity(0.000001)
                .onTapGesture {
                    patternManager.patternToggle(id: pattern.id)
                }
                .onLongPressGesture {
                    if zoomedIn {
                        editName()
                    }
                }
        }
    }

    @State private var deleteAlert: Bool = false
    private var optionsButton: some View {
        Menu {
            Section {
                Button(action: {applyPattern()}, label: {Label("apply", systemImage: "arrowshape.turn.up.forward.circle")})
                Button(action: {editName()}, label: {Label("editname", systemImage: "pencil.circle")})
                Button(role: .destructive,action: {deletePattern()}, label: {Label("delete", systemImage: "minus.circle")})
                .foregroundColor(.red)
            }
            Section {
                Button(action: {addWeek()}, label: {Label("addweek", systemImage: "plus.square.on.square")})
                if pattern.weekArray.count > 1 {
                    Button(role: .destructive,action: {removeWeek()}, label: {Label("deleteweek", systemImage: "minus.circle")})
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .padding(.top, 20)
                .padding(.trailing, 16)
        }
        .alert("Delete Pattern", isPresented: $deleteAlert, actions: {
            Button("Delete", role: .destructive, action: {patternManager.deletePattern(id: pattern.id); deleteAlert = false})
            Button("Cancel", role: .cancel, action: {deleteAlert = false})
        })
            .onTapGesture { return }

    }
    
    /// Week section
    private var weekdayBar: some View {
        WeekdayBar(weekday: pattern.firstday, accentColor: calendarManager.accentColor)
            .padding(.horizontal, 2)
            .transition(.opacity.combined(with: .scale))
    }
    private var weekLayer: some View {
        ZStack {
            weekView
            if getBounds { senseLayer }
        }
            .coordinateSpace(name: pattern.id)
    }
    private var weekView: some View {
        VStack(spacing: 2) {
            weekStack
                .transition(.scaleInOut(anchor: .top, voffset: -100))
                .frame(height: zoomedIn ? 80 : 65)
                .padding(.horizontal, zoomedIn ? 0 : 10)
                .simultaneousGesture(
                    DragGesture(minimumDistance: isDragging ? 0 : 1000, coordinateSpace: .named(pattern.id))
                        .onChanged({ drag in
                            if !isDragging || !zoomedIn { return }
                            if let data = senseData.first(where: {$0.bounds.contains(drag.location)}) {
                                if patternManager.getSelectionEnd() == data.index { return }
                                selectionEnd(index: data.index)
                                selectHaptic()
                            }
                        })
                        .onEnded({ drag in
                            if isDragging {
                                showShiftSelector.toggle()
                                patternManager.setShiftsUnselected()
                            }
                            isDragging = false
                        })
                )
        }
        
    }
    @ViewBuilder private var weekStack: some View {
        ForEach(Array(pattern.weekArray.enumerated()), id: \.offset) { index, week in
            if (index == 0) || (zoomedIn && index > 0) {
                PatternWeekView(week: week, patternId: pattern.id, zoomedIn: zoomedIn, isDragging: $isDragging, startHaptic: startHaptic)
                    .zIndex(100 - Double(index))
            }
        }
    }
    private var shiftSelector: some View {
        NavigationView {
            ShiftSelector(action: {
                patternManager.setShiftTemplates(id: $0)
            }, actionDelete: {
                patternManager.setShiftTemplates(id: nil)
            })
                .navigationTitle("selectshift")
        }
        .presentationDetents([.fraction(0.7), .large])
    }
    
    private var senseLayer: some View {
        GeometryReader { geo in
            Rectangle()
                .hidden()
                .animation(.spring(), value: pattern.weekArray)
                .onAnimationCompleted(for: zoomedIn ? 1.0 : 0.0) {
                    let frame = geo.frame(in: .named(pattern.id))
                    let x = frame.minX
                    let y = frame.minY
                    let width = frame.width / 7
                    
                    for index in 0...6 {
                        let bounds = CGRect(x: x + (CGFloat(index) * width), y: y, width: width, height: .infinity)
                        senseData.append(SensePreferenceData(index: index, bounds: bounds))
                    }
                    getBounds = false
                }
        }

    }

    private func applyPattern() {
        calendarManager.applyingPattern = pattern
        calendarManager.isApplyingPattern = true
        tabSelection = 1
    }
    private func editName() {
        nameDisabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            nameFocus.toggle()
        }
    }
    private func deletePattern() {
        deleteAlert = true
//        patternManager.deletePattern(id: pattern.id)
    }
    private func addWeek() {
        patternManager.addWeekToPattern(id: pattern.id)
    }
    private func removeWeek() {
        patternManager.removeWeekFromPattern(id: pattern.id)
    }
    private func selectionEnd(index: Int) {
        patternManager.setSelectionEnd(index: index)
    }
    private func isFirstWeek( week: PatternWeek?, sense: SensePreferenceData? ) -> Bool {
        guard let weekId = week?.id else { return false }
        guard let senseId = sense?.weekId else { return false }
        
        if weekId == senseId { return true } else { return false}
    }
    
    /// Core Haptic Functions
    
    private func prepareHaptics() {
        hapticEngine = CHHapticEngine.prepareEngine()
    }
    private func playHaptic(intensity: Float, sharpness: Float, duration: Double) {
        hapticEngine?.playHaptic(intensity: intensity, sharpness: sharpness, duration: duration)
    }
    
    private func selectHaptic() { playHaptic(intensity: 0.5, sharpness: 0.5, duration: 0.5) }
    private func startHaptic() { playHaptic(intensity: 1, sharpness: 1, duration: 0.8) }

    private func patternToggle(id: UUID) -> Void {
        patternManager.patternToggle(id: id)
    }
}

