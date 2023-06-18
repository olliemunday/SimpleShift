//
//  PrivacyView.swift
//  SwiftShift
//
//  Created by Ollie on 12/11/2022.
//

import SwiftUI

struct PrivacyView: View {

    var body: some View {
        VStack {
            Image(systemName: "hand.raised.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .padding(4)
                .frame(width: 80, height: 80, alignment: .center)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.blue)
                        .padding(1)
                )
                .drawingGroup()
                .shadow(radius: 2)

            Text("privacynotice")
                .padding()
            Spacer()
        }
        .navigationTitle("privacy")
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}
