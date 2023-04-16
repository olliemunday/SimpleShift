//
//  IndicatorExampleView.swift
//  SwiftShift
//
//  Created by Ollie on 12/11/2022.
//

import SwiftUI

struct IndicatorExampleView: View {

    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var settingsManager: SettingsManager

    let type: Int

    var body: some View {
        view
    }

    @State private var spinAngle: Double = 0.0
    private var view: some View {
        ZStack {
            let tintColor = settingsManager.tintColor.colorAdjusted(colorScheme)
            let textColor = settingsManager.tintColor.textColor(colorScheme)

            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(Color("ShiftBackground"))

            if type == 1 {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(borderColor)
                    .opacity(0.8)
                    .mask {
                        VStack {
                                Rectangle().frame(height: 28)
                                Spacer()
                            }
                    }

                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(tintColor)
                    .mask {
                        VStack {
                            Rectangle()
                                .frame(height: 25)
                            Spacer()
                        }
                    }
            }

            if type == 2 {
                VStack {
                    Spacer()
                    ZStack {
                        Capsule()
                            .foregroundColor(capsuleColor)

                        Capsule()
                            .strokeBorder(lineWidth: 3, antialiased: true)
                            .foregroundColor(capsuleBorderColor)
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 14)
                    .padding(.bottom, 5)
                }
            }


            if type == 3 {
                let border = borderColor
                AngularGradient(colors: [border, tintColor], center: .center)
                    .blur(radius: 6)
                    .scaleEffect(x: 3.2, y: 1.4, anchor: .center)
                    .rotationEffect(.degrees(spinAngle))
                    .animation(Animation.linear(duration: 2.2).repeatForever(autoreverses: false), value: spinAngle)
                    .mask {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 4)
                            .clipShape(RoundedRectangle(cornerRadius: 15))

                    }

                    .onAppear(perform: { spinAngle = 360.0 })
            }

            VStack {
                Text("12")
                    .foregroundColor(type == 1 ? textColor : .white)
                    .font(.system(size: 18))
                    .bold()
                    .padding(.vertical, 2)
                Spacer()
            }

        }
        .frame(width: 80, height: 128)
    }

    var borderColor: Color {
        if settingsManager.tintColor == .blackwhite {
            return colorScheme == .light ? .white : .black
        }
        return colorScheme == .light ? .white : .black
    }

    var capsuleBorderColor: Color {
        return colorScheme == .light ? .black : .white
    }

    var capsuleColor: Color {
        if settingsManager.tintColor == .blackwhite {
            return colorScheme == .light ? .white : .black
        }
        return settingsManager.tintColor.color
    }
}
