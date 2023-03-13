//
//  ButtonA.swift
//  SwiftShift
//
//  Created by Ollie on 14/09/2022.
//

import SwiftUI

struct ButtonA<T: View>: View {
    var size: CGFloat = 64
    var color: Color = .blue
    var foreground: Color = .white
    var cornerRadius: CGFloat = 20
    let content: T

    init(size: CGFloat = 64,
         color: Color = .blue,
         foreground: Color = .white,
         cornerRadius: CGFloat = 20,
         @ViewBuilder content: () -> T) {
        self.size = size
        self.color = color
        self.foreground = foreground
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .frame(width: size, height: size)
                .foregroundColor(color)
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(lineWidth: size/12, antialiased: true)
                .frame(width: size, height: size)
                .foregroundColor(foreground)
            if content is Image {
                if let image = content as? Image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size/2, height: size/2)
                        .foregroundColor(foreground)
                }
            } else {
                content
                    .frame(width: size/2, height: size/2)
            }
        }.drawingGroup()
    }
    
}

struct ButtonA_Previews: PreviewProvider {
    static var previews: some View {
        ButtonA {
            Image(systemName: "minus.circle.fill")
        }
            .shadow(radius: 3)
    }
}
