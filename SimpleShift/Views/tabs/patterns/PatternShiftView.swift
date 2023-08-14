//
//  PatternShiftView.swift
//  SwiftShift
//
//  Created by Ollie on 19/09/2022.
//

import SwiftUI

struct PatternShiftView: View {
    @EnvironmentObject var patternManager: PatternManager
    @EnvironmentObject var shiftManager: ShiftManager
    
    let patternId: UUID
    let zoomedIn: Bool
    var shift: PatternShift

    #if os(iOS)
    let cornerRadius: CGFloat = 12
    #else
    let cornerRadius: CGFloat = 24
    #endif

    var body: some View {
        if let id = shift.shift {
            let shiftdescriptor = shiftManager.getShift(id: id) ?? Shift(id: id, shift: "")
            ZStack {
                GradientRounded(cornerRadius: cornerRadius,
                                colors: [shiftdescriptor.gradient_1,
                                         shiftdescriptor.gradient_2],
                                direction: .vertical)
                if zoomedIn {
                    Text(shiftdescriptor.shift)
                        .dynamicTypeSize(.small ... .medium)
                        .bold()
                        .foregroundColor(shiftdescriptor.gradient_2.textColor)
                        .transition(.opacity.combined(with: .scale))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.9)
                        .zIndex(2)
                }
            }
        } else {
            ZStack {
                GradientRounded(cornerRadius: cornerRadius, colors: [Color("ShiftBackground"), Color("ShiftBackground")], direction: .vertical)
                if zoomedIn {
                    Text(String(localized: "off"))
                        .dynamicTypeSize(.small ... .medium)
                        .bold()
                        .foregroundColor(Color("ShiftText"))
                        .transition(.opacity.combined(with: .scale))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.9)
                        .zIndex(2)
                }
            }
        }
    }

}
