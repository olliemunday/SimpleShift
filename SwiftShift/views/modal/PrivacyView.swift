//
//  PrivacyView.swift
//  SwiftShift
//
//  Created by Ollie on 12/11/2022.
//

import SwiftUI

struct PrivacyView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Text("privacynotice")
                    .padding()
                Spacer()
            }
            .navigationTitle("privacy")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done") { dismiss() }.bold()
                }
            }
        }
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}
