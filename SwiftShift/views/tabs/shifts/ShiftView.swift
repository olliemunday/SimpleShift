//
//  ShiftView.swift
//  SwiftShift
//
//  Created by Ollie on 08/04/2022.
//

import SwiftUI

struct ShiftView: View {
    
    @EnvironmentObject private var shiftManager: ShiftManager
    
    let id: UUID
    let shift: Shift
    
    var body: some View {
        background
            .frame(height: 120, alignment: .center)
            .drawingGroup()
            .shadow(radius: 2)
    }

    private var background: some View {
        ZStack() {
            GradientRounded(cornerRadius: 18, colors: shift.gradientArray, direction: .vertical)
            Text(shift.shift)
                .foregroundColor(shift.gradient_2.textColor)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
        }
    }
}
