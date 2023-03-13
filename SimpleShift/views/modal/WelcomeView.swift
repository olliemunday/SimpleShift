//
//  WelcomeView.swift
//  SwiftShift
//
//  Created by Ollie on 06/09/2022.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var bulletinObjects: [infoBulletinObject] = [
        infoBulletinObject(id: 0, title: String(localized: "welcomeBulletin1Title"), description: String(localized: "welcomeBulletin1"), icon: "rectangle.stack.fill"),
        infoBulletinObject(id: 1, title: String(localized: "welcomeBulletin2Title"), description: String(localized: "welcomeBulletin2"), icon: "clock.arrow.2.circlepath"),
        infoBulletinObject(id: 2, title: String(localized: "welcomeBulletin3Title"), description: String(localized: "welcomeBulletin3"), icon: "slider.horizontal.3"),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                Text("welcomeText")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.top, 50)
                    .padding(.bottom, 40)
                    .padding(.horizontal, 30)
                
                infoBulletin
                Spacer()
            }
            Button("welcomePrivacy") {
                showPrivacy = true
            }
            .padding(.vertical, 20)
            continueButton
                .frame(height: 55)
                .padding(.horizontal)
                .padding(.bottom, 30)
        }
        .popover(isPresented: $showPrivacy) {
            privacy
        }
    }

    private var continueButton: some View {
        Button { dismiss() }
        label: {
            GeometryReader { geo in
                ZStack{
                    RoundedRectangle(cornerRadius: geo.size.width/18)
                        .foregroundColor(.accentColor)
                    Text("continue")
                        .bold()
                        .padding()
                        .foregroundColor(.white)
                }
            }


        }
    }

    private var infoBulletin: some View {
        VStack(alignment: .leading) {
            let layout = dynamicTypeSize <= .xLarge ? AnyLayout(HStackLayout(spacing: 20)) : AnyLayout(VStackLayout(alignment: .leading))
            ForEach(bulletinObjects) { bulletinObject in
                layout {
                    Image(systemName: bulletinObject.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 36, height: 36)
                        .foregroundColor(.accentColor)
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(bulletinObject.title)
                                .bold()
                            Text(bulletinObject.description)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var info1: some View {
        HStack {
            Image(systemName: "plus.app.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.horizontal, 5)
            VStack(alignment: .leading) {
                Text("Create Shift Templates")
                    .bold()
                Text("Create shift card templates and easily add to the shift calendar")
            }
        }
        .padding(.horizontal, 15)
    }

    @State private var showPrivacy: Bool = false
    
    private var privacy: some View {
        NavigationView {
            PrivacyView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("done") { showPrivacy.toggle() }.bold()
                    }
                }
        }
    }
}

struct infoBulletinObject: Identifiable {
    let id: Int
    let title: String
    let description: String
    let icon: String
}
