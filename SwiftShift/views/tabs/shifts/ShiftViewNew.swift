//
//  ShiftViewNew.swift
//  SwiftShift
//
//  Created by Ollie on 26/10/2022.
//

import SwiftUI

struct ShiftViewNew: View {
    @EnvironmentObject private var shiftManager: ShiftManager

    let shift: Shift
    @State var showEditor: Bool = false
    
    var body: some View {
        Button {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showEditor = true
            }
        } label: {
            background
        }
        .frame(height: 120, alignment: .center)
        .drawingGroup()
        .shadow(radius: 2)
        .sheet(isPresented: $showEditor) { editor }

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

    private var editor: some View {
        ShiftEditor(shift: shift)
    }
}

