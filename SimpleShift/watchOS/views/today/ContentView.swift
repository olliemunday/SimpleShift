//
//  ContentView.swift
//  SimpleShiftWatch Watch App
//
//  Created by Ollie on 11/06/2023.
//

import SwiftUI
import UIKit

struct ContentView: View {

    @StateObject private var calendarManager = CalendarWatchManager()
    @StateObject private var shiftManager = ShiftManager()

    @Environment(\.scenePhase) private var scenePhase

    private var watchConnectivity = WatchConnectivityManager.shared

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text("Today")
                    .padding(.horizontal)
                    .dynamicTypeSize(.large ... .xxxLarge)
                    .font(.title3)
                    .bold()
                Spacer()
            }

            Spacer()

            shift
                .frame(width: 90, alignment: .center)

            Spacer()
        }


    }

    @ViewBuilder private var shift: some View {
        if let date = calendarManager.displayDate,
           let shift = shiftManager.getShiftOrNil(id: date.templateId)
        {
            ZStack {
                GradientRounded(cornerRadius: 16,
                                colors: [shift.gradient_1, shift.gradient_2],
                                direction: .vertical)
                    .foregroundStyle(shift.gradient_1.textColor)
                    .shadow(radius: 1)

                VStack(spacing: 0) {
                    Text(date.day)
                        .font(.title3)
                        .foregroundStyle(shift.gradient_1.textColor)
                        .bold() 
                    Spacer()
                }

                Text(shift.shift)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(shift.gradient_1.textColor)
            }
        }
    }

}

