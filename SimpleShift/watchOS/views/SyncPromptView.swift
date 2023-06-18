//
//  SyncPromptView.swift
//  SimpleShiftWatch Watch App
//
//  Created by Ollie on 17/06/2023.
//

import SwiftUI

struct SyncPromptView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image("iOS_icon_128", bundle: .main)
            Text("Open the SimpleShift iOS app to sync.")
                .multilineTextAlignment(.center)
        }

    }
}

