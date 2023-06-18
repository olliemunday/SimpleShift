//
//  HelpViewOption.swift
//  SimpleShift
//
//  Created by Ollie on 13/03/2023.
//

import SwiftUI

struct HelpViewOption: View {

    @Environment(\.colorScheme) var colorScheme

    let image: String
    let text: String
    let colors: [Color]

    @AppStorage("_tintColor", store: .standard)
    public var tintColor: TintColor = .blue

    var body: some View {
        ZStack {
            GradientRounded(cornerRadius: 20, colors: colors, direction: .vertical)
                .foregroundColor(tintColor.colorAdjusted(colorScheme))

            VStack(alignment: .center, spacing: 6) {
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 30)

                Text(text)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .dynamicTypeSize(.medium ... .large)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundColor(.black)

            }
            .padding(.vertical, 20)
        }
            .drawingGroup()
            .shadow(radius: 1)


    }
}
