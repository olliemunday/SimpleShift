//
//  PatternExample.swift
//  SwiftShift
//
//  Created by Ollie on 12/11/2022.
//

import SwiftUI

struct PatternExample: View {

    private let exampleShifts = [
        (0, "ff6a00", "ee0979"),
        (1, "ff6a00", "ee0979"),
        (2, "ff6a00", "ee0979"),
        (3, "ff6a00", "ee0979"),
        (4, "ff6a00", "ee0979"),
        (5, "00c6ff", "0072ff"),
        (6, "00c6ff", "0072ff")
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
                    ForEach(exampleShifts, id: \.0) {
                        GradientRounded(cornerRadius: 12, colors: [Color.hex($0.1), Color.hex($0.2)], direction: .vertical)
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
