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
    
    var body: some View {
        selectable
            .drawingGroup()
            .animation(.interactiveSpring(), value: date.selected)
            .scaleEffect(date.selected ? 1.03 : 1.0)
            .opacity(date.greyed && greyed ? 0.6: 1.0)
            .animation(.interactiveSpring(dampingFraction: 0.25), value: date.selected)
    }
    
    private var selectable: some View {
        ZStack {
            display
                .animation(.easeInOut, value: date)
            if date.selected {
                RoundedRectangle(cornerRadius: 11)
                    .foregroundColor(.accentColor)
                    .opacity(0.5)
                    .transition(.opacity)
            }
        }
        .background(
            GeometryReader { geo in Color.clear.preference(key: SensePreferenceKey.self, value: [SensePreferenceData(index: self.id, bounds: geo.frame(in: .named("MonthView")))])}
        )
    }

    private var display: some View {
        ZStack {
            backgroundLayer
            textLayer
        }
    }
    
    private var backgroundLayer: some View {
        ZStack{
            if template != nil {
                gradientBackground
            } else {
                flatBackground
            }

            if today == 1 { topIndicator }
            if today == 2 { capsuleIndicator }
        }
    }

    @ViewBuilder private var topIndicator: some View {
        RoundedRectangle(cornerRadius: 11)
            .foregroundColor(.black)
            .mask(
                VStack {
                    Rectangle().frame(height: 17)
                    Spacer()
                }
            )
        RoundedRectangle(cornerRadius: 11)
            .foregroundColor(.accentColor)
            .overlay {
                RoundedRectangle(cornerRadius: 11)
                    .stroke(lineWidth: 2)
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 11))
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
            .cornerRadius(11)
    }

    private var flatBackground: some View {
        RoundedRectangle(cornerRadius: 11)
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
    
    private var textLayer: some View {
        ZStack {
            VStack {
                Text(date.day)
                    .font(.system(size: 12))
                    .bold()
                    .foregroundColor(today == 1 ? accentColor == .white ? Color.black : Color.white : getTopTextColor())
                    .padding(.top, 1)
                Spacer()
            }
            VStack(spacing: 0) {
                Rectangle()
                    .frame(height: 10)
                    .hidden()
                Text(getDisplayText())
                    .dynamicTypeSize(.xSmall ... .medium)
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundColor(getTextColor())
//                    .padding(.bottom, 4)
            }
            .padding(.horizontal, 1)

        }
    }
    
    private func getDisplayText() -> String {
        // If there is a template use the text if not use Off if it is set.
        if let shift = template?.shift { return shift }
        else if offDay { return String(localized: "off") }
        return ""
    }

    private func getTextColor() -> Color {
        // If there is a template set the text color if not set from colorScheme.
        // Text color has to be determined here as colorScheme is unreliable at init.
        if let color = template?.gradient_2 { return color.textColor }
        else { return colorScheme == .dark ? .white : .black }
    }

    private func getTopTextColor() -> Color {
        // If there is a template set the text color if not set from colorScheme.
        // Text color has to be determined here as colorScheme is unreliable at init.
        if let color = template?.gradient_1 { return color.textColor }
        else { return colorScheme == .dark ? .white : .black }
    }

}


