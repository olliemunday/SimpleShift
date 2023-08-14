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
    let tintColor: TintColor
    let cornerRadius: CGFloat

    var body: some View {
        ZStack {
            GradientRounded(colors: colors, direction: .vertical)
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
        .hoverEffect(.lift)
        .clipShape(.rect(cornerRadius: cornerRadius))
        .shadow(radius: 1)


    }
}
