//
//  PatternExample.swift
//  SwiftShift
//
//  Created by Ollie on 12/11/2022.
//

import SwiftUI

struct PatternExample: View {

    private let exampleShifts: [ShiftExample] = [
        ShiftExample(id: 0, color1: Color.hex("ff6a00"), color2: Color.hex("ee0979"), text: "06:00 14:00"),
        ShiftExample(id: 1, color1: Color.hex("ff6a00"), color2: Color.hex("ee0979"), text: "07:00 19:00"),
        ShiftExample(id: 2, color1: Color.hex("ff6a00"), color2: Color.hex("ee0979"), text: "09:00 17:00"),
        ShiftExample(id: 3, color1: Color.hex("ff6a00"), color2: Color.hex("ee0979"), text: "14:00 22:00"),
        ShiftExample(id: 4, color1: Color.hex("ff6a00"), color2: Color.hex("ee0979"), text: "14:00 22:00"),
        ShiftExample(id: 5, color1: Color.hex("00c6ff"), color2: Color.hex("0072ff"), text: "14:00 22:00"),
        ShiftExample(id: 6, color1: Color.hex("00c6ff"), color2: Color.hex("0072ff"), text: "14:00 22:00"),
    ]

    var body: some View {
        ZStack {
            Rectangle()
                .cornerRadius(16)
                .foregroundColor(Color("PatternExample"))
            VStack(spacing: 2) {
                HStack(alignment: .top) {
                    Text("Pattern")
                        .foregroundColor(.gray)
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.top, 10)
                .padding(.bottom, 6)

                HStack(spacing: 2) {
                    ForEach(exampleShifts) { shift in
                        GradientRounded(cornerRadius: 12, colors: [shift.color1, shift.color2], direction: .vertical)
                    }
                }
                .padding(.horizontal, 10)
                Spacer()
            }
        }
        .frame(width: 300, height: 106)
        .drawingGroup()
        .shadow(radius: 2)
    }
}

struct PatternExample_Previews: PreviewProvider {
    static var previews: some View {
        PatternExample()
    }
}
