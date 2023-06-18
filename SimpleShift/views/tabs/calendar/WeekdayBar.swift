//
//  WeekdayBar.swift
//  SwiftShift
//
//  Created by Ollie on 13/09/2022.
//

import SwiftUI

struct WeekdayBar: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let weekday: Int
    var spacing: CGFloat = 2
    let tintColor: TintColor

    var body: some View {
        weekdayBar
    }
    
    func getWeekdays(start: Int) -> [String] {
        return Array(weekdays[start..<weekdays.count]+weekdays[0..<start])
    }

    let weekdays = [
        String(localized: "sun"),
        String(localized: "mon"),
        String(localized: "tue"),
        String(localized: "wed"),
        String(localized: "thu"),
        String(localized: "fri"),
        String(localized: "sat")
    ]
    
    private var weekdayBar: some View {
        return HStack(spacing: spacing) {
            ForEach(getWeekdays(start: weekday - 1), id: \.self) { wkday in
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(tintColor.colorAdjusted(colorScheme))
                    .opacity(0.95)
                    .overlay(
                        Text(wkday)
                            .foregroundColor(tintColor.textColor(colorScheme))
                            .font(.system(.title2, design: .rounded))
                            .dynamicTypeSize(.xSmall ... .large)
                            .bold()
                    )
            }
        }
    }
}
