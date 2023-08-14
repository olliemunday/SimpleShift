//
//  PatternWeekView.swift
//  SwiftShift
//
//  Created by Ollie on 17/09/2022.
//

import SwiftUI
import CoreHaptics

struct PatternWeekView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject private var patternManager: PatternManager
    @EnvironmentObject private var hapticManager: HapticManager
    
    var week: PatternWeek
    let patternId: UUID
    let zoomedIn: Bool
    let isFirst: Bool
    @Binding var isDragging: Bool
    @Binding var weekDeleteShowing: UUID
    @State var fixGeometry: Bool = false

    @State private var xOffset: CGFloat = 0.0
    @State private var dragOffset: CGFloat = 0.0
    
    var body: some View {
        weekView
    }
    
    private var weekView: some View {
        ZStack {
            HStack(spacing: 2) {
                ForEach(week.shiftArray) { shift in
                    PatternShiftView(patternId: patternId, zoomedIn: zoomedIn, shift: shift)
                        .onTapGesture {
                            patternManager.patternToggle(id: patternId)
                        }
                        .onLongPressGesture(maximumDistance: 0) {
                            if !zoomedIn { return }
                            selectionStart(index: shift.id)
                            hapticManager.mediumLight()
                        }
                        .simultaneousGesture(DragGesture(minimumDistance: 12, coordinateSpace: .named("ScrollHeight"))
                            .onChanged({
                                if !zoomedIn || isDragging || isFirst { return }
                                if xOffset == 0 || $0.translation.width > 0 { return }
                                if xOffset == -72 || $0.translation.width < 0 { return }
                                if abs($0.translation.height) > 40 { dragOffset = 0; return }
                                dragOffset = $0.translation.width
                            })
                        .onEnded({
                            dragOffset = 0
                            if !zoomedIn || isDragging || isFirst { return }
                            if abs($0.translation.height) > 40 { return }
                            if $0.translation.width < -30 { weekDeleteShowing = week.id;  }
                            if $0.translation.width > 30 { xOffset = 0 }
                        })
                        )
                        .overlay {
                            selectedOverlay
                                .opacity(shift.selected ? 0.5 : 0)
                        }
                        .scaleEffect(shift.selected ? 1.03 : 1.0)
                }
            }
            .padding(.horizontal, 2)
            if xOffset == -72 {
                HStack {
                    Spacer()
                    deleteButton
                        .offset(x: 64)
                }
                .transition(.opacity)
            }
        }
        .offset(x: xOffset + dragOffset)
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: xOffset)
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: dragOffset)
        .onChange(of: weekDeleteShowing) {
            if $0 == week.id {
                xOffset = -72
            } else {
                xOffset = 0
            }
        }
    }

    private var deleteButton: some View {
        Button {
            dragOffset = 0.0
            xOffset = 0.0
            Task {
                try await Task.sleep(for: .milliseconds(10))
                patternManager.removeWeekFromPattern(pattern: patternId, week: week.id)
            }
        } label: {
            Rectangle()
                .cornerRadius(12)
                .foregroundColor(Color("ShiftBackground"))
                .frame(width: 56, height: 56)
                .overlay { Image(systemName: "trash.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.red)
                            .frame(width: 32, height: 32, alignment: .center)
                }
        }
    }
    
    private var selectedOverlay: some View {
        Rectangle()
            .cornerRadius(10)
            .foregroundColor(.white)
    }
    
    private func selectionStart(index: Int) {
        patternManager.setSelectionStart(index: index, week: week.id)
        isDragging = true
    }
    
    private func selectionEnd(index: Int) {
        patternManager.setSelectionEnd(index: index)
    }
}
