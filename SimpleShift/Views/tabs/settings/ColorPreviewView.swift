//
//  ColorPreview.swift
//  SwiftShift
//
//  Created by Ollie on 12/11/2022.
//

import SwiftUI

struct ColorPreviewView: View {

    let name: String
    let selected: Bool
    let color: Color

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(color)

            Text(name)
                .padding()
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(color.textColor)
                .opacity(0.5)
                .font(.system(size: 18, weight: .semibold, design: .rounded))

            if selected {
                VStack() {
                    Spacer()
                    HStack{
                        Spacer()
                        TickMarker(size: 24)
                            .transition(.opacity)
                            .padding(5)
                            .shadow(color: .gray, radius: 1)
                    }

                }
            }
        }
        .hoverEffect(.highlight)
        .clipShape(.rect(cornerRadius: 20))
    }
}

struct ColorPreview_Previews: PreviewProvider {
    static var previews: some View {
        ColorPreviewView(name: "Purple", selected: true, color: .purple)
            .frame(width: 128, height: 128)
    }
}
