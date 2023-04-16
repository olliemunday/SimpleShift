//
//  WelcomeiCloudView.swift
//  SwiftShift
//
//  Created by Ollie on 10/11/2022.
//

import SwiftUI

struct WelcomeiCloudView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("_tintColor", store: .standard)
    public var tintColor: TintColor = .blue

    private var persistenceController = PersistenceController.shared

    let darkColor = Color(UIColor(#colorLiteral(red: 0.9179086089, green: 0.9179086089, blue: 0.9179086089, alpha: 1)))
    let lightColor = Color(UIColor(#colorLiteral(red: 0.1559881568, green: 0.1559881568, blue: 0.1559881568, alpha: 1)))

    var body: some View {
        NavigationView {
            VStack {
                Text("icloudtagline")
                    .padding()
                    .font(.headline)
                    .navigationTitle("iCloudSync")

                Spacer()

                HStack(spacing: 30) {
                    Image(systemName: "cloud.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(colorScheme == .light ? lightColor : darkColor)
                        .shadow(radius: 2)

                    Image(systemName: "apps.iphone")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(colorScheme == .light ? lightColor : darkColor)
                        .shadow(radius: 2)
                }
                .padding()
                .frame(height: 180)

                Spacer()

                enableButton
                disableButton
            }
        }
    }

    private var enableButton: some View {
        Button {
            persistenceController.enableiCloud(true)
            dismiss()
        }
        label: {
            GeometryReader { geo in
                ZStack{
                    RoundedRectangle(cornerRadius: geo.size.width/18)
                        .foregroundColor(tintColor.colorAdjusted(colorScheme))
                    Text("icloudenable")
                        .bold()
                        .padding()
                        .foregroundColor(.white)
                }
            }


        }
        .frame(height: 55)
        .padding(.horizontal)
    }

    private var disableButton: some View {
        Button("notnow", action: { dismiss() })
            .frame(height: 55)
            .padding(.horizontal)
            .padding(.bottom, 30)
    }
}

