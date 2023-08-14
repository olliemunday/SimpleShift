//
//  WeekListDateView.swift
//  SimpleShiftWatch Watch App
//
//  Created by Ollie on 19/06/2023.
//

import SwiftUI

struct WeekListDateView: View {

    let calendarDisplay: CalendarDisplay
    let weekdayUtil = WeekdayUtil()

    let cornerRadius = 14.0

    var body: some View {
        main
    }

    private var main: some View {
        HStack(spacing: 0) {
            VStack(alignment: .center) {
                // Weekday
                Text(weekdayUtil.weekdays[min(6, calendarDisplay.weekday-1)])
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .dynamicTypeSize(.medium ... .medium)
                    .foregroundStyle(calendarDisplay.shift?.gradient_2.textColor ?? Color.white)
                    .bold()

                // Day number
                Text("\(calendarDisplay.day)")
                    .font(.system(.title2, design: .rounded, weight: .semibold))
                    .dynamicTypeSize(.medium ... .xxxLarge)
                    .foregroundStyle(calendarDisplay.shift?.gradient_2.textColor ?? Color.white)
            }
            .frame(width: 40)

            Spacer()

            // Shift
            Text(calendarDisplay.shift?.shift ?? "Off")
                .font(calendarDisplay.shift?.isCustom == 2 ? .title2 : .title3)
                .dynamicTypeSize(.medium ... .large)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundStyle(calendarDisplay.shift?.gradient_2.textColor ?? Color.white)
                .frame(width: 70)
        }
    }

    @State private var isFlashing: Bool = false
    @ViewBuilder private var flashingIndicator: some View {
        Rectangle()
            .cornerRadius(cornerRadius)
            .foregroundColor(flashingColor)
            .opacity(isFlashing ? 0.5 : 0.0)
            .animation(.easeInOut(duration: 0.8).repeat(while: isFlashing), value: isFlashing)
    }

    var flashingColor: Color {
        if let shift = calendarDisplay.shift {
            return shift.gradient_2.textColor
        } else {
            return .white
        }
    }
    
}

