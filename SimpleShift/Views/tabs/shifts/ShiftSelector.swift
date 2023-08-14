//
//  ShiftSelector.swift
//  SwiftShift
//
//  Created by Ollie on 13/09/2022.
//

import SwiftUI

struct ShiftSelector: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode

    let shifts: [Shift]

    var action: (UUID) -> Void
    var actionDelete: () -> Void

    #if os(iOS)
    let shiftAspectRatio = 0.7
    let shiftCornerRadius = 20.0
    let shiftPadding = 4.0
    #else
    let shiftAspectRatio = 0.8
    let shiftCornerRadius = 30.0
    let shiftPadding = 8.0
    #endif

    var body: some View {
//        VStack {
//            shiftList
//            Spacer()
//        }
            shiftList
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("close",
                               systemImage: "xmark",
                               role: .destructive) {
                            dismiss()
                        }
                    }
                }

    }

    let gridSpacing: CGFloat = 26
    var gridColumns: Array<GridItem> { Array(repeating: GridItem(spacing: gridSpacing), count: 3) }

    private var shiftList: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: gridSpacing) {
                Button { actionDelete(); presentationMode.wrappedValue.dismiss() }
                label: {
                    ShiftSelectorOption(shift: Shift(shift: String(localized: "off")), 
                                        cornerRadius: shiftCornerRadius, 
                                        padding: shiftPadding)
                }
                .aspectRatio(shiftAspectRatio, contentMode: .fit)
                .buttonStyle(.plain)

                ForEach(shifts) { shift in
                    Button { action(shift.id); presentationMode.wrappedValue.dismiss()}
                    label: {
                        ShiftSelectorOption(shift: shift,
                                            cornerRadius: shiftCornerRadius, 
                                            padding: shiftPadding)
                    }
                    .aspectRatio(shiftAspectRatio, contentMode: .fit)
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 26)
            .padding(.top, 10)
        }
    }

}
struct ShiftSelectorOption: View {
    let shift: Shift
    let cornerRadius: CGFloat
    let padding: CGFloat

    var body: some View {
        display
    }

    private var display: some View {
        ZStack() {
            GradientRounded(cornerRadius: cornerRadius,
                            colors: [shift.gradient_1,
                                     shift.gradient_2],
                            direction: .vertical)
            Text(shift.shift)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .dynamicTypeSize(.large ... .xLarge)
                .font(.system(shift.isCustom == 2 ? .largeTitle : .title3,
                              design: .rounded,
                              weight: .semibold))
                .shadow(radius: shift.isCustom == 2 ? 1 : 0)
                .foregroundColor(shift.gradient_2.textColor)
                .padding(.horizontal, padding)
        }
    }
}


