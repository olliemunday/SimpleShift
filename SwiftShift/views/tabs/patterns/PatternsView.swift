//
//  PatternsView.swift
//  SwiftShift
//
//  Created by Ollie on 06/09/2022.
//

import SwiftUI

struct PatternsView: View {
    @EnvironmentObject var patternManager: PatternManager
    @EnvironmentObject var shiftManager: ShiftManager
    @EnvironmentObject var calendarManager: CalendarManager
    @Binding var tabSelection: Int
    
    @State var scrollHeight: CGFloat = 0.0
    @State var frameHeight: CGFloat = 0.0

    @State var isEmpty: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                frameReader
                scrollView
                    .onAppear { isEmpty = patternManager.patternStore.isEmpty }
                    .onChange(of: patternManager.patternStore) { _ in
                        isEmpty = patternManager.patternStore.isEmpty
                    }
            }
        }
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
                Rectangle().frame(height: 10).hidden()
                scrollStack
            }
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: isEmpty)
            .coordinateSpace(name: "ScrollHeight")
            .onChange(of: patternManager.patternSelected) {
                if let first = $0.first {
                    if !(scrollHeight > frameHeight/2) { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                scroll.scrollTo(first, anchor: UnitPoint.top )
                            }
                        }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { addPattern() }) { Text("+").font(.system(size: 36, design: .rounded)) }
                    .disabled(patternManager.patternStore.count >= 10)
            }
        }
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.75), value: patternManager.patternSelected)
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.75), value: patternManager.patternStore)
        .background(Color("Background"))
        .navigationTitle("patterns")
    }
    
    var scrollStack: some View {
        LazyVStack{
            if isEmpty { PatternsTip().transition(.scaleInOut(anchor: .bottom)) }
            patternsList
        }
        .background(GeometryReader {
            Color.clear.preference(key: ScrollViewOffsetKey.self, value: $0.frame(in: .named("ScrollHeight")).height)
        })
        .onPreferenceChange(ScrollViewOffsetKey.self) { data in scrollHeight = data }
    }
    
    var patternsList: some View {
        ForEach(patternManager.patternStore) { let id = $0.id
            PatternView(tabSelection: $tabSelection, pattern: $0, zoomedIn: patternManager.patternSelected.contains(id))
                .id(id)
                .transition(.scaleInOut(anchor: .top))
        }
    }
    
    func addPattern() {
        patternManager.setPattern(pattern: Pattern(id: UUID(), name: "", firstday: 1))
    }
}

