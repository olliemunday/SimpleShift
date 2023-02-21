//
//  ShiftsTip.swift
//  SwiftShift
//
//  Created by Ollie on 25/10/2022.
//

import SwiftUI

struct ShiftsTip: View {

    @State var easterEgg: Bool = false
    @State var easterEggCounter: Int = 0

    var body: some View {
        ZStack {
            background
            text
        }
            .frame(minHeight: 100, maxHeight: 1000)
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
            .drawingGroup()
            .shadow(radius: 2)
    }

    private let exampleShifts: [ShiftExample] = [
        ShiftExample(id: 0, color1: Color.hex("a8ff78"), color2: Color.hex("78ffd6"), text: "06:00 14:00"),
        ShiftExample(id: 1, color1: Color.hex("00c6ff"), color2: Color.hex("0072ff"), text: "07:00 19:00"),
        ShiftExample(id: 2, color1: Color.hex("ffc500"), color2: Color.hex("c21500"), text: "09:00 17:00"),
        ShiftExample(id: 3, color1: Color.hex("8f94fb"), color2: Color.hex("4e54c8"), text: "14:00 22:00")
    ]

    private var text: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("createshifts")
                        .font(.system(size: 30, weight: .semibold, design: .default))

                    Text("createshiftstagline")
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.gray)
                }
                .padding(.top, 25)
                .padding(.horizontal, 25)
                Spacer()
            }

            HStack(alignment: .center, spacing: -10) {
                ForEach(exampleShifts) { shift in
                    ZStack {
                        GradientRounded(cornerRadius: 18, colors: [shift.color1, shift.color2], direction: .vertical)
                        Text(shift.text)
                            .foregroundColor(shift.color1.textColor)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .multilineTextAlignment(.center)
                    }
                    .drawingGroup()
                    .rotationEffect(.degrees(Double(easterEgg ? 0 : 10)))
                    .animation(easterEgg ? .linear(duration: 0.2).repeatForever(autoreverses: true) : .default, value: easterEgg)
                    .frame(width: 80, height: 115)
                    .shadow(radius: 3)
                    .onTapGesture {
                        easterEggCounter += 1
                        if easterEggCounter == 32 {
                            easterEgg.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {easterEgg.toggle()}
                        }
                    }

                }
            }
            .padding(.vertical, 40)
        }
    }

    private var background: some View {
        Rectangle().cornerRadius(28)
            .foregroundColor(Color("GenericBackground"))
    }
}

struct ShiftsTip_Previews: PreviewProvider {
    static var previews: some View {
        ShiftsTip()
            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
            .frame(height: 300)
    }
}

