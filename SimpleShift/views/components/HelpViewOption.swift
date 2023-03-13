//
//  HelpViewOption.swift
//  SimpleShift
//
//  Created by Ollie on 13/03/2023.
//

import SwiftUI

struct HelpViewOption: View {

    let image: String
    let text: String

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.accentColor)
                .cornerRadius(20)
            VStack {
                Image(systemName: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, 30)
                    .padding(.horizontal, 30)
                    .foregroundColor(Color.accentColor.textColor)

                Text(text)
//                    .font(.system(size: 24, weight: .semibold, design: .rounded))

                    .font(.system(.title2, design: .rounded, weight: .semibold))
                    .dynamicTypeSize(.small ... .xLarge)
                    .padding()
                    .foregroundColor(Color.accentColor.textColor)
            }
        }
        .drawingGroup()
        .shadow(radius: 1)
    }


}

struct HelpViewOption_Previews: PreviewProvider {
    static var previews: some View {
        HelpViewOption(image: "calendar", text: "calendar")
            .frame(width: 400)
    }
}
