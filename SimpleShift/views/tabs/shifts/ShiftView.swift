//
//  ShiftViewNew.swift
//  SwiftShift
//
//  Created by Ollie on 26/10/2022.
//

import SwiftUI

struct ShiftView: View {
    let shift: Shift
    
    var body: some View {
        background
            .frame(height: 120, alignment: .center)
            .drawingGroup()
            .shadow(radius: 2)
    }

    private var background: some View {
        ZStack {
            GradientRounded(cornerRadius: 18, colors: shift.gradientArray, direction: .vertical)
            Text(shift.shift)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(shift.gradient_2.textColor)
        }
    }
}

