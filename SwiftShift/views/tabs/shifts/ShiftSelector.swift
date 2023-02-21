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
                ShiftSelectorOptionNew(
                    shift: Shift(shift: String(localized: "off"))) {
                        actionDelete()
                        presentationMode.wrappedValue.dismiss()
                    }

                ForEach(shiftManager.shifts) { shift in
                    ShiftSelectorOptionNew(shift: shift) {
                        action(shift.id)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .padding(.horizontal, 26)
            .padding(.top, 10)
        }
    }

}

struct ShiftSelectorOption: View {
    let shift: Shift
    let action: () -> ()

    var body: some View {
        Button { action() } label: { display }
            .frame(height: 80)
    }

    private var display: some View {
        ZStack {
            GradientRounded(cornerRadius: 10, colors: shift.gradientArray, direction: .vertical)
            Text(shift.shift)
                .foregroundColor(shift.gradient_2.textColor)
                .opacity(0.7)
        }
    }
}

struct ShiftSelectorOptionNew: View {
    let shift: Shift
    let action: () -> ()

    var body: some View {
        Button { action() } label: { display }
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


