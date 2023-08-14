//
//  SyncPromptView.swift
//  SimpleShiftWatch Watch App
//
//  Created by Ollie on 17/06/2023.
//

import SwiftUI

struct SyncPromptView: View {
    var watchConnectivity = WatchConnectivityManager.shared

    var body: some View {
        VStack(spacing: 10) {
            Image("iOS_icon_128", bundle: .main)
            Text("Open the SimpleShift iOS app to sync.")
                .multilineTextAlignment(.center)
        }
        .task { await syncTask() }
    }

    private func syncTask() async {
        while true {
            let syncId = watchConnectivity.syncId
            watchConnectivity.sendMessage(key: "sync_request", message: syncId)
            do {
                try await Task.sleep(for: .seconds(15))
            } catch {
                return
            }
        }
    }

}

