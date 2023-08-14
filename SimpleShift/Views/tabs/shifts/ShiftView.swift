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
    let cornerRadius: CGFloat
    @State var isHover: Bool = false

    var body: some View {
        ZStack {
            GradientRounded(cornerRadius: 0, colors: [shift.gradient_1, shift.gradient_2], direction: .vertical)
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
            .hoverEffect(.highlight)
            .clipShape(.rect(cornerRadius: cornerRadius))
    }

}

