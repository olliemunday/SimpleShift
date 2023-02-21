//
//  ShiftManageView.swift
//  SwiftShift
//
//  Created by Ollie on 03/04/2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct ShiftsView: View {
    @EnvironmentObject private var shiftManager: ShiftManager

    private var dateFormatter = DateFormatter()

    @State var selectedShiftId: String = ""
    
    @State var startTime: Date = Date.now
    @State var endTime: Date = Date.now
    @State var isEmpty: Bool = false
    @State var showEditor: Bool = false

    @Namespace var shiftNamespace

    @State var showReorderView: Bool = false
    
    init() {
        dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
    }
    
    var body: some View {
        NavigationView {
            shiftView
                .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: isEmpty)
                .onAppear { isEmpty = shiftManager.shifts.count < 1; }
                .onChange(of: shiftManager.shifts, perform: { _ in
                    isEmpty = shiftManager.shifts.count < 1
                })
                .navigationTitle("shifts")
                .background(Color("Background"))
                .toolbar { ToolbarItem(placement: .navigationBarTrailing) { addButton } }
                .popover(isPresented: $showReorderView, content: {ShiftsReorderView()})
                .sheet(isPresented: $showEditor, content: { newShiftEditor })
        }

        .navigationViewStyle(.stack)
    }

    @ViewBuilder private var shiftView: some View {
        ScrollView {
            Rectangle().frame(height: 10).hidden()
            if isEmpty { ShiftsTip().transition(.scaleInOut(anchor: .bottom)) } else { shiftList }
        }
    }


    @State var draggedShift: Shift?
    private var shiftList: some View {
        let gridSpacing: CGFloat = 26
        var gridColumns: Array<GridItem> { Array(repeating: GridItem(spacing: gridSpacing), count: 3) }
        return LazyVGrid(columns: gridColumns, spacing: gridSpacing) {
            ForEach(shiftManager.shifts) { shift in
                ShiftViewNew(shift: shift)
                    .onDrag {
                        draggedShift = shift
                        let provider = NSItemProvider(item: nil, typeIdentifier: shift.shift)
                        return provider
                    }
                    .onDrop(of: [UTType.text], delegate: ShiftDropDelegate(shifts: $shiftManager.shifts, shift: shift, draggedShift: draggedShift, entered: onEntered))
            }
        }
        .padding(.horizontal, 26)
    }

    func onEntered(dragged: Shift, entered: Shift) {
        let from = shiftManager.getShiftIndex(id: dragged.id)
        let to = shiftManager.getShiftIndex(id: entered.id)

        withAnimation {
            shiftManager.shifts.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        }
        shiftManager.updateIndexes()
    }

    private var addButton: some View {
        Button() {
            showEditor.toggle()
        } label: {
            Text("+").font(.system(size: 36, design: .rounded))
        }
        .disabled(shiftManager.shifts.count >= 50)
    }


    private var newShiftEditor: some View {
        ShiftEditor(shift: Shift(), newShift: true)
    }

}

struct ShiftDropDelegate: DropDelegate {
    @Binding var shifts: [Shift]
    let shift: Shift
    let draggedShift: Shift?

    let entered: (Shift, Shift) -> ()

    func performDrop(info: DropInfo) -> Bool { true }

    func dropEntered(info: DropInfo) {
        if shift == draggedShift {return}
        guard let dragged = draggedShift else { return }
        entered(dragged, shift)
    }

}
