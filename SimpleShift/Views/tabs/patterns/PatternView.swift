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
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var patternManager: PatternManager
    @EnvironmentObject var hapticManager: HapticManager
    @EnvironmentObject var calendarPattern: CalendarPattern
    @Binding var tabSelection: Int
    @Binding var isEditing: Bool

    let shifts: [Shift]

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
    @State private var slideOffset: CGFloat = 0.0
    @State private var mainOffset: CGFloat = 0.0
    @State private var draggedPatternId: UUID = UUID()
    @State private var weekDeleteShowing: UUID = UUID()
    @State private var isDnd: Bool = false
    let tintColor: TintColor

    var isBasicView: Bool = false
    
    let zoomedIn: Bool

    #if os(iOS)
    let titlePadding = 20.0
    #else
    let titlePadding = 26.0
    #endif

    var body: some View {
        viewSwitch
        #if os(xrOS)
        .padding(.horizontal, 20)
        #endif
    }

    @ViewBuilder private var viewSwitch: some View {
        if isBasicView { basicView .padding(.horizontal, 15)
        } else { mainView .padding(.horizontal, zoomedIn ? 2 : 15) }
    }

    private var basicView: some View {
        ZStack {
            background
            VStack(spacing: 2) {
                topBar
                weekLayer
                    .simultaneousGesture(slideGesture)
                    #if os(iOS)
                        .padding(.bottom, 12)
                    #else
                        .padding(.bottom, 20)
                        .padding(.horizontal, 14)
                    #endif
            }

            if mainOffset == -70 {
                deleteButton
                    .transition(.opacity)
            }
        }
        .offset(x: mainOffset + slideOffset)
        .animation(.interactiveSpring(), value: slideOffset)
        .animation(.interactiveSpring(), value: mainOffset)
        .gesture(slideGesture)
        .alert("deletepattern", isPresented: $deleteAlert, actions: {
            Button("delete", role: .destructive, action: {
                patternManager.deletePattern(id: pattern.id)
                deleteAlert = false
                if patternManager.patternStore.isEmpty {
                    isEditing = false
                }
            })
            Button("cancel", role: .cancel, action: {deleteAlert = false})
        })
        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 15, style: .continuous))
        .onDrag {
            draggedPatternId = pattern.id
            return NSItemProvider(object: "\(pattern.id.uuidString)" as NSString)
        }
        .onDrop(of: [.text], delegate: PatternDropDelegate(dragged: draggedPatternId, dropped: pattern.id, onEntered: patternManager.insertPattern))
        #if os(xrOS)
        .glassBackgroundEffect()
        #endif

    }

    private var mainView: some View {
        ZStack {
            background
            VStack(spacing: 2) {
                topBar
                weekLayer
                #if os(iOS)
                    .padding(.bottom, zoomedIn ? 6 : 12)
                #else
                    .padding(.bottom, 20)
                    .padding(.horizontal, 14)
                #endif
            }
        }
            .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.75), value: pattern.weekArray)
            .onAppear { hapticManager.prepareEngine() }
            .onChange(of: zoomedIn) { if !$0 { nameDisabled = true; weekDeleteShowing = UUID() }; mainOffset = 0 }
            .onChange(of: scenePhase) { scene in if scene == .active { hapticManager.prepareEngine() } }
            .sheet(isPresented: $showShiftSelector) { shiftSelector }
            .onTapGesture { if !isBasicView { patternToggle(id: pattern.id) } }
            .onLongPressGesture(minimumDuration: 1.0, perform: {
                if zoomedIn { return }
                isEditing.toggle()
                hapticManager.extraLight()
            })
            .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 20))
        #if os(xrOS)
            .glassBackgroundEffect()
        #endif
    }

    private var longPress: some Gesture {
        LongPressGesture(minimumDuration: 1.0)
            .onEnded { _ in
                if zoomedIn { return }
                isEditing.toggle()
                hapticManager.extraLight()
            }
    }

    private var onTap: some Gesture {
        TapGesture()
            .onEnded { _ in
                if !isBasicView { patternToggle(id: pattern.id) }
            }

    }

    private var slideGesture: some Gesture {
        DragGesture(minimumDistance: 3.0)
            .onChanged { drag in
                if zoomedIn { return }
                if abs(drag.translation.height) > 40 { slideOffset = 0 }
                slideOffset = drag.translation.width
            }
            .onEnded { drag in
                slideOffset = 0
                if zoomedIn { return }
                if abs(drag.translation.height) > 40 { return }
                if mainOffset == 0 && drag.translation.width < -20 { mainOffset = -70; return }
                if mainOffset == -70 && drag.translation.width > 20 { mainOffset = 0; return }
            }
    }

    private var deleteButton: some View {
        HStack {
            Spacer()
            Button { deleteAlert = true; mainOffset = 0 } label: {
                Rectangle()
                    .cornerRadius(12)
                    .foregroundColor(Color("PatternBackground"))
                    .frame(width: 60, height: 60)
                    .shadow(radius: 2)
                    .overlay {
                        Image(systemName: "trash.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.red)
                            .frame(width: 36, height: 36)
                    }
            }
                .offset(x: 72)
        }
    }

    @ViewBuilder private var background: some View {
        #if os(iOS)
        Rectangle()
            .cornerRadius(zoomedIn ? 12 : 20)
            .foregroundColor(Color("PatternBackground"))
            .shadow(radius: zoomedIn ?  3 : 1)
        #elseif os(xrOS)
        Color.clear
        #endif
    }

    #if os(iOS)
    let topBarSpacing = 10.0
    #else
    let topBarSpacing = 0.0
    #endif

    /// Top Bar Section
    private var topBar: some View {
        ZStack {
            HStack {
                patternTitle
                Spacer()
                if zoomedIn {
                    Rectangle()
                        .hidden()
                        .frame(width: 80, height: 1)
                }
            }

            HStack(spacing: topBarSpacing) {
                Spacer()
                editNameButton
                    .scaleEffect(zoomedIn ? 1 : 0.05, anchor: .top)
                    .rotationEffect(.degrees(zoomedIn ? 0 : -45))
                    .opacity(zoomedIn ? 1.0 : 0.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: zoomedIn)
                applyButton
                    .scaleEffect(zoomedIn ? 1 : 0.05, anchor: .top)
                    .rotationEffect(.degrees(zoomedIn ? 0 : -45))
                    .opacity(zoomedIn ? 1.0 : 0.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0).delay(0.1), value: zoomedIn)
            }
                .zIndex(10)
                .padding(.top, 14)
                .padding(.trailing, 14)
                .padding(.leading, 10)

        }
        .padding(.bottom, zoomedIn ? 10 : 4)
    }
    
    @State var patternName: String = ""

    private var patternTitle: some View {
        ZStack {
            patternTitleBackground

            TextField("pattern", text: $patternName)
                .disabled(nameDisabled)
                .focused($nameFocus)
                .onAppear { patternName = pattern.name }
                .onChange(of: patternName) { patternManager.setPatternName(id: pattern.id, name: $0)  }
                .onSubmit { nameDisabled = true }
                .font(.title)
                .fontWeight(.bold)
                .dynamicTypeSize(.small ... .xLarge)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, titlePadding)
                .padding(.top, zoomedIn ? 16 : 10)
        }

    }

    @ViewBuilder private var patternTitleBackground: some View {
        Rectangle()
            .padding(.horizontal, 20)
            .padding(.top, zoomedIn ? 16 : 10)
            .foregroundColor(Color("PatternBackground"))
            .onTapGesture { patternToggle(id: pattern.id) }
            .onLongPressGesture {
                if zoomedIn {
                    editName()
                }
            }
        #if os(xrOS)
            .opacity(0.001)
        #endif
    }

    @State private var deleteAlert: Bool = false

    private var applyButton: some View {
        Button {
            applyPattern()
        } label: {
            #if os(iOS)
            Image(systemName: "arrowshape.turn.up.forward.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
            #else
            Label("apply", systemImage: "arrowshape.turn.up.forward.circle")
                .labelStyle(.iconOnly)
            #endif
        }
    }

    private var editNameButton: some View {
        Button {
            editName()
        } label: {
            #if os(iOS)
            Image(systemName: "a.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
            #else
            Label("rename", systemImage: "a.circle")
                .labelStyle(.iconOnly)
            #endif
        }
    }

    private var weekLayer: some View {
        ZStack {
            weekView
            if getBounds { senseLayer }
        }
            .coordinateSpace(name: pattern.id)
    }

    #if os(iOS)
    let weekHeight: CGFloat = 80
    let weekSpacing: CGFloat = 2
    #else
    let weekHeight: CGFloat = 96
    let weekSpacing: CGFloat = 4
    #endif

    private var weekView: some View {
        VStack(spacing: weekSpacing) {
            ForEach(pattern.weekArray) { week in
                let isFirst = patternManager.isFirstWeek(weekId: week.id, patternId: pattern.id)
                if zoomedIn || isFirst {
                    PatternWeekView(week: week,
                                    patternId: pattern.id,
                                    zoomedIn: zoomedIn,
                                    isFirst: isFirst,
                                    isDragging: $isDragging,
                                    weekDeleteShowing: $weekDeleteShowing)
                        .transition(.scaleInOut(anchor: .top, voffset: -100))
                        .frame(height: zoomedIn ? weekHeight : weekHeight * 0.8)
                }
            }

            if zoomedIn && !(pattern.weekArray.count >= 16) {
                addWeekButton
                    .padding(weekSpacing)
                .transition(.scaleInOut(anchor: .top, voffset: CGFloat(-70 * pattern.weekArray.count)))
            }
        }
            .animation(.spring(), value: pattern.weekArray)
            .padding(.horizontal, zoomedIn ? 0 : 10)
            .simultaneousGesture(
                DragGesture(minimumDistance: isDragging ? 0 : 1000, coordinateSpace: .named(pattern.id))
                    .onChanged({ drag in
                        if !isDragging || !zoomedIn { return }
                        if let data = senseData.first(where: {$0.bounds.contains(drag.location)}) {
                            if patternManager.getSelectionEnd() == data.index { return }
                            selectionEnd(index: data.index)
                            hapticManager.extraLight()
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

    private var addWeekButton: some View {
        Button {
            addWeek()
        } label: {
            ZStack {
                Rectangle()
                    .cornerRadius(16)
                    .foregroundColor(Color("ShiftBackground"))

                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 26, height: 26)
                    .foregroundColor(tintColor.colorAdjusted(colorScheme))
            }
        }
            .frame(width: 100, height: 45, alignment: .center)
    }

    private var shiftSelector: some View {
        NavigationView {
            ShiftSelector(shifts: shifts, action: {
                patternManager.setShiftTemplates(id: $0)
            }, actionDelete: {
                patternManager.setShiftTemplates(id: nil)
            })
                .navigationTitle("selectshift")
        }
        #if os(iOS)
        .presentationDetents([.fraction(0.7), .large])
        #endif
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

    // Needs re-working.
    private func applyPattern() {
        calendarPattern.applyingPattern = pattern
        calendarPattern.isApplyingPattern = true
        tabSelection = 1
    }
    private func editName() {
        nameDisabled = false
        Task {
            try await Task.sleep(for: .milliseconds(200))
            nameFocus.toggle()
        }
    }
    private func addWeek() {
        patternManager.addWeekToPattern(id: pattern.id)
        weekDeleteShowing = UUID()
    }
    private func removeWeek() {
        patternManager.removeLastWeekFromPattern(id: pattern.id)
    }
    private func selectionEnd(index: Int) {
        patternManager.setSelectionEnd(index: index)
    }
    private func isFirstWeek( week: PatternWeek?, sense: SensePreferenceData? ) -> Bool {
        guard let weekId = week?.id else { return false }
        guard let senseId = sense?.weekId else { return false }
        
        if weekId == senseId { return true } else { return false}
    }
    private func patternToggle(id: UUID) {
        if !(mainOffset == 0) { return }
        patternManager.patternToggle(id: id)
    }

}

struct PatternDropDelegate: DropDelegate {

    let dragged: UUID
    let dropped: UUID
    let onEntered: (UUID, UUID) -> ()

    func performDrop(info: DropInfo) -> Bool { true }

    func dropEntered(info: DropInfo) { onEntered(dragged, dropped) }

    func dropUpdated(info: DropInfo) -> DropProposal? { DropProposal(operation: .move) }

}
