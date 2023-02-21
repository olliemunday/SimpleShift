//
//  ShiftsReorderView.swift
//  SwiftShift
//
//  Created by Ollie on 12/11/2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct ShiftsReorderView: View {
    @EnvironmentObject var shiftManager: ShiftManager

    @State private var array = ["One", "Two", "Three", "Four"]

    var body: some View {
        DragView()
//        NavigationView {
//            List {
//                ForEach(shiftManager.shifts) { shift in
//                    Text(shift.shift)
//                }
//                .onMove(perform: move)
//            }
//        }

    }

    func move(from source: IndexSet, to destination: Int) {
        print("Source: \(source) Destination: \(destination)")

        
    }
}


import SwiftUI

struct DragView: View {

    @State var items = ["1", "2", "3"]
    @State var draggedItem : String?

    var body: some View {
        LazyVStack(spacing : 15) {
            ForEach(items, id:\.self) { item in
                Text(item)
                    .frame(minWidth:0, maxWidth:.infinity, minHeight:50)
                    .border(Color.black).background(Color.red)
                    .onDrag({
                    self.draggedItem = item
                    return NSItemProvider(item: nil, typeIdentifier: item)
                }) .onDrop(of: [UTType.text], delegate: MyDropDelegate(item: item, items: $items, draggedItem: $draggedItem))
            }
        }
    }
}

struct MyDropDelegate : DropDelegate {

    let item : String
    @Binding var items : [String]
    @Binding var draggedItem : String?

    func performDrop(info: DropInfo) -> Bool {
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else {
            return
        }

        if draggedItem != item {
            let from = items.firstIndex(of: draggedItem)!
            let to = items.firstIndex(of: item)!
            withAnimation(.default) {
                self.items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
    }
}

struct ShiftsReorderView_Previews: PreviewProvider {
    static var previews: some View {
        ShiftsReorderView()
    }
}
