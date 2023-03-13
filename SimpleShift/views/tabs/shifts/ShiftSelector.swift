//
//  ShiftSelector.swift
//  SwiftShift
//
//  Created by Ollie on 13/09/2022.
//

import SwiftUI

struct ShiftSelector: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var shiftManager: ShiftManager
    
    var action: (UUID) -> Void
    var actionDelete: () -> Void
    
    var body: some View {
        VStack {
            shiftList
            Spacer()
        }
    }
    
    private var shiftList: some View {
        let gridSpacing: CGFloat = 26
        var gridColumns: Array<GridItem> { Array(repeating: GridItem(spacing: gridSpacing), count: 3) }
        return ScrollView {
            LazyVGrid(columns: gridColumns, spacing: gridSpacing) {
                Button { actionDelete(); presentationMode.wrappedValue.dismiss() }
                label: { ShiftSelectorOption(shift: Shift(shift: String(localized: "off"))) }
                ForEach(shiftManager.shifts) { shift in
                    Button { action(shift.id); presentationMode.wrappedValue.dismiss()}
                    label: { ShiftSelectorOption(shift: shift) }
                }
            }
            .padding(.horizontal, 26)
            .padding(.top, 10)
        }
    }

}
struct ShiftSelectorOption: View {
    let shift: Shift

    var body: some View {
        display
            .frame(height: 120)
    }

    private var display: some View {
        ZStack() {
            GradientRounded(cornerRadius: 18, colors: shift.gradientArray, direction: .vertical)
            Text(shift.shift)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(shift.gradient_2.textColor)
        }
    }
}


