//
//  DateView.swift
//  SwiftShift
//
//  Created by Ollie on 04/04/2022.
//

import SwiftUI

struct DateView: View {
    let id: Int
    let date: CalendarDate
    var template: Shift? = nil
    let greyed: Bool
    let offDay: Bool
    let today: Int
    let accentColor: Color

    let cornerRadius: CGFloat = 10
    
    var body: some View {
        main
            .drawingGroup()
            .scaleEffect(date.selected ? 1.03 : 1.0)
            .opacity(date.greyed && greyed ? 0.3 : 1.0)
            .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.8), value: date.selected)
    }
    
    private var main: some View {
        ZStack {
            backgroundLayer
        }
            .overlay {
                if today == 1 { topIndicator }
                if today == 2 { capsuleIndicator }
            }
            .overlay { textLayer }
            .overlay { selectedOverlay }
    }

    private var selectedOverlay: some View {
        Rectangle()
            .cornerRadius(cornerRadius)
            .foregroundColor(.accentColor)
            .opacity(date.selected ? 0.5 : 0.0)
            .transition(.opacity)
    }
    
    @ViewBuilder private var backgroundLayer: some View {
        if template != nil { gradientBackground } else { flatBackground }
    }

    @ViewBuilder private var topIndicator: some View {
        Rectangle()
            .foregroundColor(.black)
            .cornerRadius(cornerRadius)
            .mask {
                VStack {
                        Rectangle().frame(height: 17)
                        Spacer()
                    }
            }

        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundColor(accentColor == .black ? .gray : accentColor)
            .overlay { RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(lineWidth: 3)
                    .foregroundColor(.black)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
            .mask( VStack {
                    Rectangle().frame(height: 15)
                    Spacer()
                } )
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
                        .foregroundColor(.accentColor == .white ? Color.black : Color.white)
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


