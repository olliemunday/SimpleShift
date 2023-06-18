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
            .onDisappear {
                isFlashing = false
                isBorderSpinning = false
            }
            .task {
                if today <= 0 { return }
                if today == 3 { isBorderSpinning = true }
                if today == 4 { isFlashing = true }
            }
    }
    
    private var main: some View {
        ZStack {
            backgroundLayer
        }
            .overlay {
                if today == 1 { topIndicator.transition(.opacity) }
                if today == 2 { capsuleIndicator.transition(.opacity) }
                if today == 3 { borderIndicator.transition(.opacity) }
                if today == 4 { flashingIndicator.transition(.opacity) }

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
            .foregroundColor(borderColor)
            .opacity(0.8)
            .mask {
                VStack {
                        Rectangle().frame(height: 20)
                        Spacer()
                    }
            }

        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundColor(tintColor.colorAdjusted(colorScheme))
            .mask( VStack {
                    Rectangle().frame(height: 18)
                    Spacer()
                } )
    }

    private var capsuleIndicator: some View {
        VStack {
            Spacer()
            ZStack {
                Capsule()
                    .foregroundColor(capsuleColor)

                Capsule()
                    .strokeBorder(lineWidth: 2, antialiased: true)
                    .foregroundColor(capsuleBorderColor)
            }
            .frame(height: 8)
            .padding(.horizontal, 14)
            .padding(.vertical, 4)
            .drawingGroup()
            .shadow(radius: 1)
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
                .padding(.top, 3)
            Spacer()
        }
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 10)
                .hidden()
            Text(template?.shift ?? (offDay ? String(localized: "off") : ""))
                .dynamicTypeSize(.xSmall ... .medium)
                .font(template?.isCustom == 2 ? .largeTitle : .body)
                .shadow(radius: template?.isCustom == 2 ? 1 : 0)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundColor(template?.gradient_2.textColor)
        }
        .padding(.horizontal, 1)
    }

    @State private var isBorderSpinning: Bool = false
    @ViewBuilder var borderIndicator: some View {
        ZStack {
            let tint = tintColor.colorAdjusted(colorScheme)
            let border = borderColor
            AngularGradient(colors: [border, tint], center: .center)
                .blur(radius: 3)
                .scaleEffect(x: 2, y: 6, anchor: .center)
                .rotationEffect(.degrees(isBorderSpinning ? 360.0 : 0.0))
                .animation(Animation.linear(duration: 2.0).repeat(while: isBorderSpinning, autoreverses: false), value: isBorderSpinning)
                .mask {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(lineWidth: 7)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                }


        }
    }

    @State private var isFlashing: Bool = false
    @ViewBuilder private var flashingIndicator: some View {
        Rectangle()
            .cornerRadius(cornerRadius)
            .foregroundColor(flashingColor)
            .opacity(isFlashing ? 0.5 : 0.0)
            .animation(.easeInOut(duration: 0.8).repeat(while: isFlashing), value: isFlashing)
    }

    var flashingColor: Color {
        if let template = template {
            return template.gradient_2.textColor
        } else {
            return capsuleBorderColor
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


