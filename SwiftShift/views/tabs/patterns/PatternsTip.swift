//
//  PatternsTip.swift
//  SwiftShift
//
//  Created by Ollie on 25/10/2022.
//

import SwiftUI

struct PatternsTip: View {
    var body: some View {
        ZStack {
            background
            text
        }
            .frame(minHeight: 100, maxHeight: 1000)
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
            .drawingGroup()
            .shadow(radius: 2)
    }

    private var text: some View {
        VStack(spacing: 0) {
            HStack{
                VStack(alignment: .leading) {
                    Text("shiftpatterns")
                        .font(.system(size: 30, weight: .semibold, design: .default))

                    Text("shiftpatternstagline")
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.gray)
                }
                .padding(.top, 25)
                .padding(.horizontal, 25)
                Spacer()
            }

            patternExample

            Image(systemName: "arrow.down")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(.gray)
                .padding(.bottom, 20)

            calendarExample

        }
    }

    
    private var calendarExample: some View {
        CalendarExampleView()
            .padding(.bottom, 30)
    }

    private var patternExample: some View {
        PatternExample()
            .padding(.top, 20)
            .padding(.bottom, 20)
    }


    private var background: some View {
        Rectangle().cornerRadius(28)
            .foregroundColor(Color("GenericBackground"))
    }
}

struct PatternsTip_Previews: PreviewProvider {
    static var previews: some View {
        PatternsTip()
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
            .frame(height: 600)
    }
}
