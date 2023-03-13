//
//  WeekdayBar.swift
//  SwiftShift
//
//  Created by Ollie on 13/09/2022.
//

import SwiftUI

struct WeekdayBar: View {   
    let weekday: Int
    var spacing: CGFloat = 2
    let accentColor: Color

    var body: some View {
        weekdayBar
            .drawingGroup()
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
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(accentColor)
                    .opacity(0.8)
                    .overlay(alignment: .center) {
                        Text(wkday)
                            .foregroundColor(accentColor == .white ? .black : .white)
                            .font(.system(.title2, design: .rounded))
                            .dynamicTypeSize(.xSmall ... .large)
                            .bold()
                    }
            }
        }
    }
}
