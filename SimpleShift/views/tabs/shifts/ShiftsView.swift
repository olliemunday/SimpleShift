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

    @State var selectedShiftId: String = ""
    @State var startTime: Date = Date.now
    @State var endTime: Date = Date.now
    @State var isEmpty: Bool = false
    @State var showEditor: Bool = false

    var body: some View {
        NavigationView {
            shiftView
                .environmentObject(shiftManager)
                .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: isEmpty)
                .onAppear { isEmpty = shiftManager.shifts.count < 1; }
                .onChange(of: shiftManager.shifts, perform: { _ in
                    isEmpty = shiftManager.shifts.count < 1
                })
                .navigationTitle("shifts")
                .background(Color("Background"))
                .toolbar { ToolbarItem(placement: .navigationBarTrailing) { addButton } }
                .popover(isPresented: $showEditor) {
                    ShiftEditor(isNewShift: true, shift: Shift())
                        .environmentObject(shiftManager)
                }
        }
        .navigationViewStyle(.stack)
    }

    @State private var gridHeight = 30.0
    let gridSpacing = 30.0
    let gridRowAmount = 3
    @ViewBuilder private var shiftView: some View {
        ScrollView {
            Rectangle().frame(height: 6).hidden()
            if isEmpty { ShiftsTip().transition(.scaleInOut(anchor: .bottom)) }
            else {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: gridSpacing), count: gridRowAmount),
                      spacing: 30) {
                ForEach(shiftManager.shifts) { shift in
                    ShiftView(shift: shift)
                        .frame(height: gridHeight)
                        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .onDrag {
                            draggedShift = shift
                            return NSItemProvider(object: "\(shift.shift)" as NSString)
                        }
                        .onDrop(of: [UTType.text], delegate: ShiftDropDelegate(shifts: $shiftManager.shifts, shift: shift, draggedShift: draggedShift, shiftManager: shiftManager))
                        .transition(.scale)
                }
            }
                      .padding(.horizontal, gridSpacing)
            
            Rectangle().frame(height: 6).hidden()
        }
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        let spacingWidth = gridSpacing * Double(gridRowAmount + 1)
                        let width = (geo.size.width - spacingWidth) / Double(gridRowAmount)
                        gridHeight = width * 1.4
                    }
            }
        )
    }

    @State var draggedShift: Shift?
    private var shiftList: some View {
        let gridSpacing: CGFloat = 30
        var gridColumns: Array<GridItem> { Array(repeating: GridItem(spacing: gridSpacing), count: 3) }
        return GeometryReader { geo in
            LazyVGrid(columns: gridColumns, spacing: gridSpacing) {
                ForEach(shiftManager.shifts) { shift in
                    ShiftView(shift: shift)
                        .frame(height: geo.size.width / 3)
                        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .onDrag {
                            draggedShift = shift
                            
                            return NSItemProvider(object: "\(shift.shift)" as NSString)
                        }
                        .onDrop(of: [UTType.text], delegate: ShiftDropDelegate(shifts: $shiftManager.shifts, shift: shift, draggedShift: draggedShift, shiftManager: shiftManager))
                        .transition(.scale)
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.65), value: shiftManager.shifts)
            .padding(.horizontal, 30)

        }
    }

    private var addButton: some View {
        Button() {
            showEditor.toggle()
        } label: {
            Text("+").font(.system(size: 36, design: .rounded))
        }
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
        shiftManager.moveShift(from: dragged.id, to: shift.id)
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

}
