//
//  HelpViewOption.swift
//  SimpleShift
//
//  Created by Ollie on 13/03/2023.
//

import SwiftUI

struct HelpViewOption: View {

    @Environment(\.colorScheme) var colorScheme

    let size: CGFloat
    let image: String
    let text: String
    let colors: [Color]

    @AppStorage("_tintColor", store: .standard)
    public var tintColor: TintColor = .blue

    var body: some View {
            GradientRounded(cornerRadius: size / 5, colors: colors, direction: .vertical)
                .frame(height: size)
                .foregroundColor(tintColor.colorAdjusted(colorScheme))
                .cornerRadius(size / 5)
                .overlay {
                    VStack(alignment: .center) {
                        Rectangle()
                            .hidden()
                            .overlay {
                                Image(systemName: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.black)
                            }
                            .frame(height: size * 0.5)

                        Text(text)
                            .font(.system(size: max(16, 0.12 * (size)) , weight: .semibold, design: .rounded))
                            .dynamicTypeSize(.medium ... .large)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .foregroundColor(.black)

                    }
                }
                .drawingGroup()
                .shadow(radius: 1)
    }

}

struct HelpViewOption_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            HelpViewOption(size: 200, image: "calendar", text: "calendar", colors: [.cyan, .blue])
        }

    }
}
