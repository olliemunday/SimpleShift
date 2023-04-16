//
//  CalendarRender.swift
//  SwiftShift
//
//  Created by Ollie on 13/11/2022.
//
//  Render the current calendar to be exported as an image
//

import SwiftUI

struct CalendarRender: View {

    @Environment(\.colorScheme) private var colorScheme

    let displayDate: String
    let weekday: Int
    let tintColor: TintColor

    var dates = [
        CalendarDate(id: 1, date: Date.now, day: "1", greyed: false),
        CalendarDate(id: 2, date: Date.now, day: "2", greyed: false),
        CalendarDate(id: 3, date: Date.now, day: "3", greyed: false),
        CalendarDate(id: 4, date: Date.now, day: "4", greyed: false),
        CalendarDate(id: 5, date: Date.now, day: "5", greyed: false),
        CalendarDate(id: 6, date: Date.now, day: "6", greyed: false),
        CalendarDate(id: 7, date: Date.now, day: "7", greyed: false)
    ]

    let shifts: [Shift]
    let gridSpacing: CGFloat = 2.0
    var gridColumns: Array<GridItem> { Array(repeating: GridItem(spacing: gridSpacing), count: 7) }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 5) {
                WeekdayBar(weekday: weekday, tintColor: tintColor)
                    .frame(height: 30)


                LazyVGrid(columns: gridColumns, spacing: gridSpacing) {
                    ForEach(dates) { date in
                        DateView(id: date.id,
                                 date: date,
                                 template: shifts.first(where: {$0.id == date.templateId}),
                                 greyed: date.greyed,
                                 offDay: true,
                                 today: 0,
                                 tintColor: tintColor)
                            .frame(height: 90)

                    }
                }

                Text(displayDate)
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("ShiftText"))
                    .padding(.horizontal, 30)
                    .padding(.vertical, 6)
                    .background(
                        HCenter {
                            Color("NavBarBackground")
                                .cornerRadius(18)
                                .shadow(radius: 2)
                        }
                    )
                    .padding(.vertical, 2)
            }
            .padding(.horizontal, 3)


        }
    }

    var background: some View {
        Rectangle()
            .foregroundColor(colorScheme == .light ? .white : .black)
    }
}
