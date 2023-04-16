//
//  DateView.swift
//  SwiftShift
//
//  Created by Ollie on 04/04/2022.
//

import SwiftUI

struct DateView: View, @unchecked Sendable {
    @Environment(\.colorScheme) private var colorScheme
    
    let id: Int
    let date: CalendarDate
    var template: Shift? = nil
    let greyed: Bool
    let offDay: Bool
    let today: Int
    let tintColor: TintColor

    let cornerRadius: CGFloat = 10
    
    var body: some View {
        main
            .drawingGroup()
            .scaleEffect(date.selected ? 1.03 : 1.0)
            .opacity(date.greyed && greyed ? 0.3 : 1.0)
            .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.8), value: date.selected)
            .animation(.spring(), value: today)
            .onChange(of: today) {
                if $0 == 3 { spinAngle = 360 }
                else { spinAngle = 0 }
            }
            .onAppear { if today == 3 { spinAngle = 360 } }
    }
    
    private var main: some View {
        ZStack {
            backgroundLayer
        }
            .overlay {
                if today == 1 { topIndicator.transition(.opacity) }
                if today == 2 { capsuleIndicator.transition(.opacity) }
                if today == 3 { borderIndicator.transition(.opacity) }

            }
            .overlay { textLayer }
            .overlay { selectedOverlay }
    }

    private var selectedOverlay: some View {
        Rectangle()
            .cornerRadius(cornerRadius)
            .foregroundColor(tintColor.colorAdjusted(colorScheme))
            .opacity(date.selected ? 0.5 : 0.0)
            .transition(.opacity)
    }
    
    @ViewBuilder private var backgroundLayer: some View {
        if template != nil { gradientBackground } else { flatBackground }
    }

    @ViewBuilder private var topIndicator: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundColor(tintColor.colorAdjusted(colorScheme))
            .mask( VStack {
                    Rectangle().frame(height: 16)
                    Spacer()
                } )
    }

    private var capsuleIndicator: some View {
        VStack {
            Spacer()
            ZStack {
                Capsule()
                    .foregroundColor(capsuleColor)

//                if let color = template?.gradient_2 {
//                    Capsule()
//                        .strokeBorder(lineWidth: 2, antialiased: true)
//                        .foregroundColor(color.brightness == .dark ? Color.hex("cfcfcf") : Color.hex("2e2e2e"))
//                } else {
//                    Capsule()
//                        .strokeBorder(lineWidth: 2, antialiased: true)
//                        .foregroundColor(tintColor.textColor(colorScheme))
//                }

                Capsule()
                    .strokeBorder(lineWidth: 2, antialiased: true)
                    .foregroundColor(capsuleBorderColor)

            }
            .frame(height: 8)
            .padding(.horizontal, 14)
            .padding(.vertical, 4)
        }
    }

    private var gradientBackground: some View {
        LinearGradient(colors: template!.gradientArray, startPoint: UnitPoint.top, endPoint: UnitPoint.bottom)
            .cornerRadius(cornerRadius)
            .drawingGroup()
    }

    private var flatBackground: some View {
        Rectangle()
            .foregroundColor(Color("ShiftBackground"))
            .cornerRadius(cornerRadius)
    }
    
    @ViewBuilder private var textLayer: some View {
        VStack {
            Text(date.day)
                .font(.system(size: 12))
                .bold()
                .foregroundColor(today == 1 ? tintColor.textColor(colorScheme) : template?.gradient_1.textColor)
                .padding(.top, 1)
            Spacer()
        }
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 10)
                .hidden()
            Text(template?.shift ?? (offDay ? String(localized: "off") : ""))
                .dynamicTypeSize(.xSmall ... .medium)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundColor(template?.gradient_2.textColor)
        }
        .padding(.horizontal, 1)
    }


    @State private var spinAngle: Double = 0.0
    @ViewBuilder var borderIndicator: some View {
        ZStack {
            let tint = tintColor.colorAdjusted(colorScheme)
            let border = borderColor
            AngularGradient(colors: [border, tint], center: .center)
                .blur(radius: 6)
                .scaleEffect(x: 3.2, y: 1.4, anchor: .center)
                .rotationEffect(.degrees(spinAngle))
                .animation(Animation.linear(duration: 2.2).repeatForever(autoreverses: false), value: spinAngle)
                .mask {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(lineWidth: 4)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

                }

        }
    }

    var borderColor: Color {
        if tintColor == .blackwhite {
            return colorScheme == .light ? .white : .black
        }
        if let template = template {
            return template.gradient_2.textColor
        }
        return colorScheme == .light ? .white : .black
    }

    var capsuleBorderColor: Color {
        return colorScheme == .light ? .black : .white
    }

    var capsuleColor: Color {
        if tintColor == .blackwhite {
            return colorScheme == .light ? .white : .black
        }
        return tintColor.color
    }
}


