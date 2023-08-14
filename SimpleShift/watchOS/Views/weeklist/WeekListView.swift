//
//  CalendarListView.swift
//  SimpleShift
//
//  Created by Ollie on 18/06/2023.
//

import SwiftUI

struct WeekListView: View {
    @Environment(\.scenePhase) private var scenePhase

    var watchConnectivity = WatchConnectivityManager.shared

    @StateObject var viewModel: WeekListViewModel =
    WeekListViewModel(calendarManager: CalendarWatchManager(),
                      shiftManager: ShiftManager())

    let cornerRadius = 14.0

    var body: some View {
        NavigationView {
            listView
                .task { viewModel.populateListWeeks() }
        }
    }

    private var listView: some View {
        ScrollViewReader(content: { proxy in
            List { listWeeks }
            .listStyle(.carousel)
            .listRowInsets(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
            .onChange(of: scenePhase) { phase in
                if phase == .active {  Task { await updateList(proxy) } }
                else { showWeekCommence = false }
            }
        })
    }

    @State private var isFlashing: Bool = false
    @State private var showWeekCommence: Bool = false
    @ViewBuilder private var listWeeks: some View {
        ForEach(viewModel.weekList) { week in
            Text((showWeekCommence ? week.weekCommence : week.name) ?? "")
                .bold()
                .font(.title3)
                .dynamicTypeSize(.large ... .xxxLarge)
                .listRowBackground(Color.clear)
                .animation(.default, value: showWeekCommence)
                .onTapGesture {
                    showWeekCommence.toggle()
                }

            ForEach(week.days) { day in
                WeekListDateView(calendarDisplay: day)
                    .listRowBackground(
                            GradientRounded(cornerRadius: cornerRadius,
                                            colors: [day.shift?.gradient_1 ?? Color("CellBackground"),
                                                     day.shift?.gradient_2 ?? Color("CellBackground")],
                                            direction: .vertical)
                            .overlay(
                                ZStack {
                                    if day.indicatorType == 1 {
                                        Rectangle()
                                            .cornerRadius(cornerRadius)
                                            .foregroundColor(day.shift?.gradient_2.textColor ?? .white)
                                            .opacity(isFlashing ? 0.4 : 0.0)
                                            .animation(.default.speed(0.6).repeat(while: isFlashing), value: isFlashing)
                                    }
                                }
                            )
                    )
                    .task { if day.indicatorType == 1 { isFlashing = true } }
                    .onDisappear { if day.indicatorType == 1 { isFlashing = false } }
            }
        }
    }

    func updateList(_ proxy: ScrollViewProxy) async {
        do {
            viewModel.updateList()
            try await Task.sleep(for: .milliseconds(200))
            scrollToToday(proxy)
        } catch { return }
    }

    func scrollToToday(_ proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(viewModel.todayIndex, anchor: .center)
        }
    }

}
