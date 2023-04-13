//
//  IndicatorExampleView.swift
//  SwiftShift
//
//  Created by Ollie on 12/11/2022.
//

import SwiftUI

struct IndicatorExampleView: View {

    @EnvironmentObject var settingsController: SettingsManager

    let type: Int

    var body: some View {
        view
    }

    private var view: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(Color("ShiftBackground"))

            if type == 1 {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.black)
                    .mask {
                        VStack {
                            Rectangle()
                                .frame(height: 27)
                            Spacer()
                        }
                    }


                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.accentColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 3)
                            .foregroundColor(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
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
                            .foregroundColor(.accentColor)

                        Capsule()
                            .strokeBorder(lineWidth: 3, antialiased: true)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 14)
                    .padding(.bottom, 5)
                }
            }

            VStack {
                Text("12")
                    .foregroundColor(type == 1 ? settingsController.accentColor == .white ? .black : .white : .white)
                    .font(.system(size: 18))
                    .bold()
                    .padding(.vertical, 2)
                Spacer()
            }

        }
        .frame(width: 80, height: 128)
    }
}
