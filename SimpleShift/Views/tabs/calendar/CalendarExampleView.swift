//
//  CalendarExampleView.swift
//  SwiftShift
//
//  Created by Ollie on 12/11/2022.
//

import SwiftUI

struct CalendarExampleView: View {

    let weekdayUtil = WeekdayUtil()

    var body: some View {
        calendarExample
    }

    private let exampleShifts = [
        (0, "ff6a00", "ee0979"),
        (1, "ff6a00", "ee0979"),
        (2, "ff6a00", "ee0979"),
        (3, "ff6a00", "ee0979"),
        (4, "ff6a00", "ee0979"),
        (5, "00c6ff", "0072ff"),
        (6, "00c6ff", "0072ff"),
    ]

    private var calendarExample: some View {
        VStack(spacing: 3) {
            HStack(spacing: 3) {
                ForEach(0..<7, id: \.self) { index in
                    ZStack {
                        Rectangle()
                            .cornerRadius(10)
                            .foregroundColor(.gray)
                        Text(weekdayUtil.weekdays[index])
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: 300, height: 24)

            HStack(spacing: 3) {
                ForEach(exampleShifts, id: \.0) {
                    GradientRounded(cornerRadius: 12, colors: [Color.hex($0.1), Color.hex($0.2)], direction: .vertical)
                        .frame(width: 40, height: 55)
                }
            }

        }
    }
}

struct CalendarExampleView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarExampleView()
    }
}
