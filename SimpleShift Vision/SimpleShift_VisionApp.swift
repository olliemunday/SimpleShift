//
//  SimpleShift_VisionApp.swift
//  SimpleShift Vision
//
//  Created by Ollie on 03/07/2023.
//

import SwiftUI

@main
struct SimpleShift_VisionApp: App {
    var body: some Scene {
        WindowGroup {
            TabsView()
        }
        .windowStyle(.plain)
        .defaultSize(CGSize(width: 850, height: 850))
    }
}
