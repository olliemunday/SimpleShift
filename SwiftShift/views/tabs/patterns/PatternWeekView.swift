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
    @EnvironmentObject var patternManager: PatternManager
    @EnvironmentObject var shiftManager: ShiftManager
    @EnvironmentObject var calendarManager: CalendarManager
    
    var week: PatternWeek
    let patternId: UUID
    let zoomedIn: Bool
    @Binding var isDragging: Bool
    let startHaptic: () -> Void
    @State var fixGeometry: Bool = false

    
    var body: some View {
        weekView
    }
    
    private var weekView: some View {
        HStack(spacing: 2) {
            ForEach(week.shiftArray) { shift in
                ZStack {                  
                    PatternShiftView(patternId: patternId, zoomedIn: zoomedIn, shift: shift)
                        .onTapGesture {
                            patternManager.patternToggle(id: patternId)
                        }
                        .onLongPressGesture(maximumDistance: 0) {
                            if !zoomedIn { return }
                            selectionStart(index: shift.id)
                            startHaptic()
                        }
                    
                    selectedOverlay
                        .opacity(shift.selected ? 0.5 : 0)

                }
                .scaleEffect(shift.selected ? 1.03 : 1.0)
            }
        }
        .padding(.horizontal, 2)
    }
    
    private var selectedOverlay: some View {
        RoundedRectangle(cornerRadius: 10)
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
