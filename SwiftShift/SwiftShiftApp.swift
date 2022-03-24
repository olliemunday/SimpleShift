//
//  SwiftShiftApp.swift
//  SwiftShift
//
//  Created by Ollie on 24/03/2022.
//

import SwiftUI

@main
struct SwiftShiftApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
