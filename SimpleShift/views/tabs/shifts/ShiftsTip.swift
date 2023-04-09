//
//  ShiftsTip.swift
//  SwiftShift
//
//  Created by Ollie on 25/10/2022.
//

import SwiftUI

struct ShiftsTip: View {

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



    private let examples: [(String, String, String)] = [
        ("a8ff78", "78ffd6", "06:00 14:00"),
        ("00c6ff", "0072ff", "07:00 19:00"),
        ("ffc500", "c21500", "09:00 17:00"),
        ("8f94fb", "4e54c8", "14:00 22:00")
    ]

    private var text: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("createshifts")
                        .font(.system(size: 30, weight: .semibold, design: .default))
                        .padding(.bottom, 1)

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
                ForEach(examples, id: \.0) { shift in
                    ZStack {
                        GradientRounded(cornerRadius: 18, colors: [Color.hex(shift.0), Color.hex(shift.1)], direction: .vertical)
                        Text(shift.2)
                            .foregroundColor(Color.hex(shift.0).textColor)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 80, height: 115)
                    .rotationEffect(.degrees(10))
                    .drawingGroup()
                    .shadow(radius: 3)
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

