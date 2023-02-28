//
//  DateView.swift
//  SwiftShift
//
//  Created by Ollie on 04/04/2022.
//

import SwiftUI
import CoreMIDI
import CoreAudio

struct DateView: View {
    @Environment(\.colorScheme) private var colorScheme

    /// ID, Date and Template inputs
    let id: Int
    let date: CalendarDate
    var template: Shift? = nil
    let greyed: Bool
    let offDay: Bool
    let today: Int
    let accentColor: Color

    let cornerRadius: CGFloat = 10
    
    var body: some View {
        selectable
            .drawingGroup()
            .scaleEffect(date.selected ? 1.03 : 1.0)
            .opacity(date.greyed && greyed ? 0.6: 1.0)
            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.8), value: date.selected)

    }
    
    private var selectable: some View {
        ZStack {
            backgroundLayer
            textLayer
                .animation(.easeInOut, value: date)
            if date.selected {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(.accentColor)
                    .opacity(0.5)
                    .transition(.opacity)
            }
        }
    }
    
    @ViewBuilder private var backgroundLayer: some View {
        if template != nil { gradientBackground } else { flatBackground }
        if today == 1 { topIndicator }
        if today == 2 { capsuleIndicator }
    }

    @ViewBuilder private var topIndicator: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundColor(.black)
            .mask(
                VStack {
                    Rectangle().frame(height: 17)
                    Spacer()
                }
            )
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundColor(.accentColor)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(lineWidth: 2)
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
            .mask(
                VStack {
                    Rectangle().frame(height: 15)
                    Spacer()
                }
            )
    }

    private var capsuleIndicator: some View {
        VStack {
            Spacer()
            ZStack {
                Capsule()
                    .foregroundColor(.accentColor)

                if let color = template?.gradient_2 {
                    Capsule()
                        .strokeBorder(lineWidth: 2, antialiased: true)
                        .foregroundColor(color.brightness == .dark ? Color.hex("cfcfcf") : Color.hex("2e2e2e"))
                } else {
                    Capsule()
                        .strokeBorder(lineWidth: 2, antialiased: true)
                        .foregroundColor(accentColor == .white ? Color.black : Color.white)
                }


            }
            .frame(height: 8)
            .padding(.horizontal, 14)
            .padding(.vertical, 4)
        }
    }

    private var gradientBackground: some View {
        LinearGradient(colors: template!.gradientArray, startPoint: UnitPoint.top, endPoint: UnitPoint.bottom)
            .cornerRadius(cornerRadius)
    }

    private var flatBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundColor(Color("ShiftBackground"))
    }
    
    private var todayIndicator: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.accentColor)
            RoundedRectangle(cornerRadius: 20)
                .stroke(.black, lineWidth: 2)
                .foregroundColor(.black)
        }
        .frame(height: 5, alignment: .center)
        .padding(.bottom, 3)
        .padding([.leading, .trailing], 15)
    }
    
    @ViewBuilder private var textLayer: some View {
        VStack {
            Text(date.day)
                .font(.system(size: 12))
                .bold()
                .foregroundColor(today == 1 ? accentColor == .white ? Color.black : Color.white : template?.gradient_1.textColor)
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

}


