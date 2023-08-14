//
//  ShiftManageView.swift
//  SwiftShift
//
//  Created by Ollie on 03/04/2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct ShiftsView: View {
    @StateObject private var shiftManager = ShiftManager()

    @State var isEmpty: Bool = false
    @State var shiftEditing: Shift?
    @State var shiftIsNew = false
    @State var draggedShift: Shift?

    let gridRowAmount = 3
    let shiftAspectRatio = 0.7
    #if os(iOS)
    let gridSpacing = 30.0
    let shiftCornerRadius = 20.0
    let shiftTextPadding = 4.0
    let shiftTextSize = Font.TextStyle.title2
    #else
    let gridSpacing = 40.0
    let shiftCornerRadius = 50.0
    let shiftTextPadding = 12.0
    let shiftTextSize = Font.TextStyle.title
    #endif

    var body: some View {
        NavigationStack {
            newShiftView
                .environmentObject(shiftManager)
                .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: isEmpty)
                .onAppear { isEmpty = shiftManager.shifts.count < 1 }
                .onChange(of: shiftManager.shifts) { _ in isEmpty = shiftManager.shifts.count < 1 }
                .navigationTitle("shifts")
                .toolbar { ToolbarItem(placement: .navigationBarTrailing) { addButton } }
                .sheet(item: $shiftEditing) { shift in
                    ShiftEditor(shiftIsNew: $shiftIsNew, shift: shift)
                        .environmentObject(shiftManager)
                }
            #if os(iOS)
                .background(Color("Background"))
            #endif
        }
    }

    private var scrollSpace: some View { Color.clear.frame(height: 6) }

    @ViewBuilder private var newShiftView: some View {
        ScrollView {
            scrollSpace

            if isEmpty { ShiftsTip().transition(.scaleInOut(anchor: .bottom)) } else
            {
                LazyVGrid(columns: Array(repeating: GridItem(spacing: gridSpacing), count: gridRowAmount), spacing: gridSpacing) {
                    ForEach(shiftManager.shifts) { shift in
                        Button { shiftIsNew = false; shiftEditing = shift } label: {
                            ShiftView(shift: shift,
                                      textSize: shiftTextSize,
                                      textPadding: shiftTextPadding,
                                      cornerRadius: shiftCornerRadius)
                            .shadow(radius: 2)
                        }
                        .buttonStyle(.plain)
                        .aspectRatio(shiftAspectRatio, contentMode: .fit)
                        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: shiftCornerRadius, style: .continuous))
                        .onDrag {
                            draggedShift = shift
                            return NSItemProvider(object: "\(shift.shift)" as NSString)
                        }
                        .onDrop(of: [UTType.text], delegate: ShiftDropDelegate(shifts: $shiftManager.shifts, shift: shift, draggedShift: draggedShift, shiftManager: shiftManager))
                        .transition(.scale)
                    }
                }
                .padding(.horizontal, gridSpacing)
            }

            scrollSpace
        }
    }


    private var addButton: some View {
        Button(action: { shiftIsNew = true; shiftEditing = Shift() }) { Label("+", systemImage: "plus") }
            .disabled(shiftManager.shifts.count >= 50)
    }
}

struct ShiftDropDelegate: DropDelegate {
    @Binding var shifts: [Shift]
    let shift: Shift
    let draggedShift: Shift?
    let shiftManager: ShiftManager

    func performDrop(info: DropInfo) -> Bool { true }

    func dropEntered(info: DropInfo) {
        if shift == draggedShift {return}
        guard let dragged = draggedShift else { return }
        withAnimation(.spring) {
            shiftManager.moveShift(from: dragged.id, to: shift.id)
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

}
