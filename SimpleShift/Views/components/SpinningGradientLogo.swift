//
//  SpinningGradientLogo.swift
//  SimpleShift
//
//  Created by Ollie on 08/04/2023.
//
//  Logo with spinning gradient underneath. Just looks cool. 😎
//

import SwiftUI

struct SpinningGradientLogo: View {
    let size: CGFloat
    @State private var spinAngle: Double = 0.0

    var body: some View {
        ZStack {
            AngularGradient(colors: [.red, .orange, .yellow, .green, .blue, .indigo, .purple, .red], center: .center)
                .rotationEffect(.degrees(spinAngle))
                .animation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false), value: spinAngle)
                .onAppear(perform: {
                    spinAngle = 360.0
                })
                .scaleEffect(2.0)
                .opacity(0.75)
                .mask {
                    RoundedRectangle(cornerRadius: size/4.7)
                }
                .blur(radius: 3.0)


            Image("Icon")
                .resizable()
                .scaledToFit()
                .hoverEffect(.highlight)
                .clipShape(.rect(cornerRadius: size / 4.7))
                .shadow(radius: 1)
                .frame(width: size * 0.97, height: size * 0.97)
        }
        .frame(width: size, height: size)
    }
}

struct SpinningGradient_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SpinningGradientLogo(size: 200)
        }
    }
}
