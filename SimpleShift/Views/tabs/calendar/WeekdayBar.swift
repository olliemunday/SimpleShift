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
    let cornerRadius: CGFloat
    let tintColor: TintColor

    let weekdayUtil = WeekdayUtil()

    var body: some View { weekdayBar }

    private var weekdayBar: some View {
        HStack(spacing: spacing) {
            ForEach(weekdayUtil.getWeekdays(start: weekday - 1), id: \.self) { wkday in
                RoundedRectangle(cornerRadius: cornerRadius)
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
