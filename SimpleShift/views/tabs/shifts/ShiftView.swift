//
//  ShiftViewNew.swift
//  SwiftShift
//
//  Created by Ollie on 26/10/2022.
//

import SwiftUI

struct ShiftView: View {
    let shift: Shift

    @State private var showEditor: Bool = false

    var textSize = Font.TextStyle.title2
    var emojiSize = Font.TextStyle.largeTitle
    var textPadding = 4.0

    var body: some View {
        Button {
            showEditor.toggle()
        } label: {
            background
                .drawingGroup()
                .shadow(radius: 2)
        }
        .popover(isPresented: $showEditor) {
            ShiftEditor(isNewShift: false, shift: shift)
        }
        
    }

    private var background: some View {
        ZStack {
            GradientRounded(cornerRadius: 20, colors: shift.gradientArray, direction: .vertical)
            Text(shift.shift)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .dynamicTypeSize(.large ... .xLarge)
                .font(.system(shift.isCustom == 2 ? emojiSize : textSize,
                              design: .rounded,
                              weight: .bold))
                .shadow(radius: shift.isCustom == 2 ? 1 : 0)
                .foregroundColor(shift.gradient_2.textColor)
                .padding(.horizontal, textPadding)
        }
    }
}

