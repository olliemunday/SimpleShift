//
//  CalendarExampleView.swift
//  SwiftShift
//
//  Created by Ollie on 12/11/2022.
//

import SwiftUI

struct CalendarExampleView: View {
    var body: some View {
        calendarExample
    }

    private let exampleShifts: [ShiftExample] = [
        ShiftExample(id: 0, color1: Color.hex("ff6a00"), color2: Color.hex("ee0979"), text: "06:00 14:00"),
        ShiftExample(id: 1, color1: Color.hex("ff6a00"), color2: Color.hex("ee0979"), text: "07:00 19:00"),
        ShiftExample(id: 2, color1: Color.hex("ff6a00"), color2: Color.hex("ee0979"), text: "09:00 17:00"),
        ShiftExample(id: 3, color1: Color.hex("ff6a00"), color2: Color.hex("ee0979"), text: "14:00 22:00"),
        ShiftExample(id: 4, color1: Color.hex("ff6a00"), color2: Color.hex("ee0979"), text: "14:00 22:00"),
        ShiftExample(id: 5, color1: Color.hex("00c6ff"), color2: Color.hex("0072ff"), text: "14:00 22:00"),
        ShiftExample(id: 6, color1: Color.hex("00c6ff"), color2: Color.hex("0072ff"), text: "14:00 22:00"),
    ]

    let weekdays = [
        String(localized: "sun"),
        String(localized: "mon"),
        String(localized: "tue"),
        String(localized: "wed"),
        String(localized: "thu"),
        String(localized: "fri"),
        String(localized: "sat")
    ]
    
    private var calendarExample: some View {
        VStack(spacing: 3) {
            HStack(spacing: 3) {
                ForEach(0..<7, id: \.self) { index in
                    ZStack {
                        Rectangle()
                            .cornerRadius(10)
                            .foregroundColor(.gray)
                        Text(weekdays[index])
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: 300, height: 24)

            HStack(spacing: 3) {
                ForEach(exampleShifts) { shift in
                    GradientRounded(cornerRadius: 12, colors: [shift.color1, shift.color2], direction: .vertical)
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
