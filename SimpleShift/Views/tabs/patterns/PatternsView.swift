//
//  PatternsView.swift
//  SwiftShift
//
//  Created by Ollie on 06/09/2022.
//

import SwiftUI

struct PatternsView: View {
    @StateObject var patternManager = PatternManager()
    @StateObject var shiftManager = ShiftManager()
    @StateObject private var hapticManager = HapticManager()
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var tabSelection: Int
    
    @State var scrollHeight: CGFloat = 0.0
    @State var frameHeight: CGFloat = 0.0

    @State var isEmpty: Bool = false

    @State private var isEditing: Bool = false
    @State private var isEditingTransitory = false
    @Namespace var namespace

    #if os(iOS)
    let editPlacement = ToolbarItemPlacement.topBarLeading
    #else
    let editPlacement = ToolbarItemPlacement.topBarTrailing
    #endif

    var body: some View {
        NavigationStack {
            ZStack {
                frameReader
                    .zIndex(-1)
                scrollView
                    .onAppear { isEmpty = patternManager.patternStore.isEmpty }
                    .onChange(of: patternManager.patternStore) { _ in isEmpty = patternManager.patternStore.isEmpty }
                    .zIndex(0)
            }
            #if os(iOS)
            .background(Color("Background"))
            #endif
        }
            .environmentObject(patternManager)
            .environmentObject(shiftManager)
            .environmentObject(hapticManager)
            .coordinateSpace(name: "FrameHeight")
            .onPreferenceChange(ScrollViewOffsetKey.self) { data in frameHeight = data }
            .navigationViewStyle(.stack)
    }
    
    var frameReader: some View {
        GeometryReader {
            Color.clear.preference(key: ScrollViewOffsetKey.self, value: $0.frame(in: .named("FrameHeight")).height)
        }
    }

    var scrollView: some View {
        ScrollViewReader { scroll in
            ScrollView {
                Rectangle().frame(height: 6).hidden()
                if isEditing { editStack } else { scrollStack }
            }
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: isEmpty)
            .coordinateSpace(name: "ScrollHeight")
            .onChange(of: patternManager.patternSelected) {
                if let first = $0.first {
                    if !(scrollHeight > frameHeight/2) { return }
                    Task {
                        try await Task.sleep(for: .milliseconds(500))
                        withAnimation {
                            scroll.scrollTo(first, anchor: UnitPoint.top )
                        }
                    }
                }
            }
        }
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.75), value: patternManager.patternSelected)
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.75), value: patternManager.patternStore)
        .navigationTitle("patterns")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { addButton }
            ToolbarItem(placement: editPlacement) { editButton }
        }
    }

    private var addButton: some View {
        Button(action: { addPattern() }) { Label("+", systemImage: "plus") }
            .disabled(patternManager.patternStore.count >= 10)
    }

    private var editButton: some View {
        Button(isEditing ? "done" : "edit") {
            isEditingTransitory = true
            let isEmpty = patternManager.patternSelected.isEmpty
            if !isEmpty { patternManager.patternSelected.removeAll() }
            Task {
                try await Task.sleep(for: .seconds(isEmpty ? 0 : 1))
                isEditing.toggle()
                isEditingTransitory = false
            }
        }
        .bold(isEditing)
        .disabled(isEditingTransitory)
        .disabled(patternManager.patternStore.isEmpty)
        #if os(xrOS)
        .buttonStyle(.bordered)
        #endif
    }

    var scrollStack: some View {
        LazyVStack{
            if isEmpty { PatternsTip().transition(.scaleInOut(anchor: .bottom)) }
            ForEach(patternManager.patternStore) { let id = $0.id
                PatternView(tabSelection: $tabSelection,
                            isEditing: $isEditing,
                            shifts: shiftManager.shifts,
                            pattern: $0,
                            tintColor: settingsManager.tintColor,
                            zoomedIn: patternManager.patternSelected.contains(id))
                    .id(id)
                    .transition(.scaleInOut(anchor: .top))
            }
        }
        .background(GeometryReader {
            Color.clear.preference(key: ScrollViewOffsetKey.self, value: $0.frame(in: .named("ScrollHeight")).height)
        })
        .onPreferenceChange(ScrollViewOffsetKey.self) { data in scrollHeight = data }
    }

    var editStack: some View {
        LazyVStack {
            ForEach(patternManager.patternStore) { pattern in
                PatternView(tabSelection: $tabSelection,
                            isEditing: $isEditing,
                            shifts: shiftManager.shifts,
                            pattern: pattern,
                            tintColor: settingsManager.tintColor,
                            isBasicView: true,
                            zoomedIn: false)
                    .id(pattern.id)
            }

        }
    }

    func addPattern() {
        patternManager.setPattern(pattern: Pattern(id: UUID()))
    }
}

