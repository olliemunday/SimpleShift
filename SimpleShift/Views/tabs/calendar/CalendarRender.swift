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

    let calendarPage: CalendarPage
    let weekday: Int
    let tintColor: TintColor

    let shifts: [Shift]
    let gridSpacing: CGFloat = 2.0
    var gridColumns: Array<GridItem> { Array(repeating: GridItem(spacing: gridSpacing), count: 7) }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 5) {
                WeekdayBar(weekday: weekday, cornerRadius: 14, tintColor: tintColor)
                    .frame(height: 30)

                Grid(alignment: .center,
                     horizontalSpacing: 2,
                     verticalSpacing: 2) {
                    ForEach(calendarPage.weeks) { week in
                        GridRow {
                            ForEach(week.days) { day in
                                DateView(id: day.id,
                                         calendarDisplay: day,
                                         tintColor: tintColor,
                                         cornerRadius: 14,
                                         dayFontSize: 14)
                            }
                        }
                    }
                }

                Text(calendarPage.display)
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
