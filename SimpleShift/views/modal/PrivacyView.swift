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
