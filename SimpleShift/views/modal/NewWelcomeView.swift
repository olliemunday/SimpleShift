//
//  NewWelcomeView.swift
//  SimpleShift
//
//  Created by Ollie on 12/03/2023.
//

import SwiftUI

struct NewWelcomeView: View {

    @EnvironmentObject var calendarManager: CalendarManager
    @State private var currentPage: Int = 0

    var body: some View {
        VStack {
            switch currentPage {
            case 0: featuresList
            case 1: weekdaySelection
            default: featuresList
            }

            Spacer()

            continueButton
        }
    }

    private var continueButton: some View {
        Button { withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { currentPage += 1 } }
        label: {
            GeometryReader { geo in
                    RoundedRectangle(cornerRadius: geo.size.width/18)
                        .foregroundColor(.accentColor)
                        .overlay(
                            Text("continue")
                                .bold()
                                .padding()
                                .foregroundColor(.white)
                        )
            }
        }
            .frame(height: 55)
            .padding(.horizontal)
            .padding(.bottom, 30)
    }

    private var featuresList: some View {
        WelcomeView()
            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
    }

    let Weekdays = [
        WeekdayOption(id: 0, name: String(localized: "sunday")),
        WeekdayOption(id: 1, name: String(localized: "monday")),
        WeekdayOption(id: 2, name: String(localized: "tuesday")),
        WeekdayOption(id: 3, name: String(localized: "wednesday")),
        WeekdayOption(id: 4, name: String(localized: "thursday")),
        WeekdayOption(id: 5, name: String(localized: "friday")),
        WeekdayOption(id: 6, name: String(localized: "saturday")),
    ]

    private var weekdaySelection: some View {
        VStack {
            Text("First day of the week")
                .font(.largeTitle.bold())
                .padding(.top, 50)

            List {
                ForEach(Weekdays) { weekday in
                    Button {
                        calendarManager.weekday = weekday.id + 1
                    } label: {
                        HStack {
                            Text(weekday.name)
                                .foregroundColor(.primary)
                            Spacer()
                            if calendarManager.weekday == (weekday.id+1) {
                                Image(systemName: "checkmark")
                                    .transition(.opacity)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .frame(width: 300, height: 500, alignment: .center)

        }
        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
    }


}


struct NewWelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        NewWelcomeView()
    }
}
