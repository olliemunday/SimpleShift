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
    let calendarDisplay: CalendarDisplay
    let tintColor: TintColor
    var customText = Font.body
    let cornerRadius: CGFloat
    let dayFontSize: CGFloat

    var body: some View {
        main
            .onDisappear {
                isFlashing = false
                isBorderSpinning = false
            }
            .task {
                if calendarDisplay.indicatorType <= 0 { return }
                if calendarDisplay.indicatorType == 3 { isBorderSpinning = true }
                if calendarDisplay.indicatorType == 4 { isFlashing = true }
            }

    }

    private var main: some View {
        ZStack {
            backgroundLayer.opacity(calendarDisplay.isGreyed ? 0.35 : 1.0)
            todayIndicator.opacity(calendarDisplay.isGreyed ? 0.35 : 1.0)
            textLayer.opacity(calendarDisplay.isGreyed ? 0.9 : 1.0)
        }
        .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.8), value: calendarDisplay.date.selected)
        .animation(.spring(), value: calendarDisplay.indicatorType)
        .overlay { selectedOverlay }
        .clipShape(.rect(cornerRadius: cornerRadius))
        .drawingGroup()
        .scaleEffect(calendarDisplay.date.selected ? 1.03 : 1.0)
    #if os(xrOS)
        .hoverEffect(.lift)
        .clipShape(.rect(cornerRadius: cornerRadius))
    #endif
    }

    @ViewBuilder private var todayIndicator: some View {
        switch calendarDisplay.indicatorType {
        case 2:
            capsuleIndicator.transition(.opacity)
        case 3:
            borderIndicator.transition(.opacity)
        case 4:
            flashingIndicator.transition(.opacity)
        default:
            EmptyView()
        }
    }

    private var selectedOverlay: some View {
        Rectangle()
            .foregroundColor(tintColor.colorAdjusted(colorScheme))
            .opacity(calendarDisplay.date.selected ? 0.5 : 0.0)
            .transition(.opacity)
    }
    
    @ViewBuilder private var backgroundLayer: some View {
        if let shift = calendarDisplay.shift {
            LinearGradient(colors: [shift.gradient_1,
                                    shift.gradient_2],
                           startPoint: UnitPoint.top,
                           endPoint: UnitPoint.bottom)
                .drawingGroup()
        } else {
            Rectangle()
                .foregroundColor(Color("ShiftBackground"))
        }
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

    @ViewBuilder private var topIndicatorNew: some View {
        if calendarDisplay.indicatorType == 1 {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(borderColor)
                    .blur(radius: 3.0)
                    .opacity(0.4)

                RoundedRectangle(cornerRadius: 4)
                    .opacity(0.95)
                    .foregroundStyle(tintColor.colorAdjusted(colorScheme))
            }


        } else {
            Color.clear
        }
    }

    private var capsuleIndicator: some View {
        VStack {
            Spacer()
            ZStack {
                Capsule()
                    .foregroundStyle(capsuleBorderColor)
                    .blur(radius: 3.0)
                    .opacity(0.4)

                Capsule()
                    .foregroundStyle(capsuleColor)
                    .opacity(0.95)

                Capsule()
                    .strokeBorder(lineWidth: 1, antialiased: true)
                    .foregroundStyle(capsuleBorderColor)
                    .opacity(0.75)
            }
            .frame(height: 7)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .drawingGroup()
            .shadow(radius: 1)
        }
    }
    
    @ViewBuilder private var textLayer: some View {
        VStack {
            Text(calendarDisplay.day)
                .font(.system(size: dayFontSize))
                .bold()
                .foregroundColor(calendarDisplay.indicatorType == 1 ? tintColor.textColor(colorScheme) : calendarDisplay.shift?.gradient_1.textColor)
                .padding(.horizontal, 4)
                .background(
                    topIndicatorNew
                )
                .padding(.top, 1)
            Spacer()
        }
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 10)
                .hidden()
            Text(calendarDisplay.shift?.shift ?? (calendarDisplay.showOff ? String(localized: "off") : ""))
                .dynamicTypeSize(calendarDisplay.shift?.isCustom == 0 ? DynamicTypeSize.medium : DynamicTypeSize.small)
                .font(calendarDisplay.shift?.isCustom == 2 ? .largeTitle : customText)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundColor(calendarDisplay.shift?.gradient_2.textColor)
                .shadow(radius: calendarDisplay.shift?.isCustom == 2 ? 1 : 0)
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
        if let shift = calendarDisplay.shift {
            return shift.gradient_2.textColor
        } else {
            return capsuleBorderColor
        }
    }

    var borderColor: Color {
        if tintColor == .blackwhite {
            return colorScheme == .light ? .white : .black
        }
        if let shift = calendarDisplay.shift {
            return shift.gradient_2.textColor
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


