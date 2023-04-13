//
//  PersistenceController.swift
//  CoreDataTest
//
//  Created by Ollie on 28/03/2022.
//

import CoreData
import SwiftUI

class PersistenceController {
    static let shared = PersistenceController()

    var container: NSPersistentContainer = NSPersistentContainer(name: "SwiftShiftModel")

    /// iCloud Boolean to control if iCloud is to be used.
    @AppStorage("iCloudSetting") var cloud: Bool = false

    /// Set iCloud and reload container.
    public func enableiCloud(_ bool: Bool) {
        if bool == self.cloud { return }
        self.cloud = bool
        self.createContainer()
    }

    /// Initialise a new `NSPersistentContainer`.
    private func createContainer() {
        container = NSPersistentCloudKitContainer(name: "SwiftShiftModel")

        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

        let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
        description?.setOption(true as NSNumber, forKey: remoteChangeKey)

        if !self.cloud { description?.cloudKitContainerOptions = nil }

        container.loadPersistentStores { description, err in }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)

        NotificationCenter.default.post(name: NSNotification.Name("CoreDataRefresh"), object: container.viewContext)
    }

    init() { self.createContainer() }

}
