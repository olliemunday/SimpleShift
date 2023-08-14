//
//  ShiftsView.swift
//  SimpleShift visionOS
//
//  Created by Ollie on 07/08/2023.
//

//import SwiftUI
//
//struct ShiftsView: View {
//
//    @StateObject private var shiftManager = ShiftManager()
//
//    @State private var showEditor = false
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                shiftList
//            }
//            .padding(40)
//            .sheet(isPresented: $showEditor, content: {
//                ShiftEditor(isNewShift: true, shift: Shift())
//                    .environmentObject(shiftManager)
//            })
//            .toolbar(content: {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button() {
//                        showEditor.toggle()
//                    } label: {
//                        Label("+", systemImage: "plus")
//                    }
//                    .disabled(shiftManager.shifts.count >= 50)
//                }
//            })
//            .navigationTitle("shifts")
//        }
//    }
//
//    let gridSpacing: CGFloat = 40
//    var gridColumns: Array<GridItem> { Array(repeating: GridItem(spacing: gridSpacing), count: 3) }
//    @ViewBuilder private var shiftList: some View {
//        if shiftManager.shifts.count < 1 {
//            ShiftsTip(showBackground: false)
//                .glassBackgroundEffect()
//                .transition(.opacity)
//        } else {
//            GeometryReader { geo in
//                LazyVGrid(columns: gridColumns, spacing: gridSpacing) {
//                    ForEach(shiftManager.shifts) { shift in
//                        ShiftView(shift: shift,
//                                  textSize: .title,
//                                  textPadding: 12,
//                                  cornerRadius: 50)
//                        .frame(height: geo.size.width / 3)
//                        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 12, style: .continuous))
//                        .transition(.scale)
//                        .environmentObject(shiftManager)
//
//                    }
//                }
//                .animation(.spring(response: 0.6, dampingFraction: 0.65), value: shiftManager.shifts)
//            }
//        }
//    }
//
//}
//
//#Preview {
//    ShiftsView()
//}
