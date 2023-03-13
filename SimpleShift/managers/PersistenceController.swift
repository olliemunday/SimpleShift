//
//  PersistenceController.swift
//  CoreDataTest
//
//  Created by Ollie on 28/03/2022.
//

import CoreData
import SwiftUI

struct PersistenceController {
    static var shared = PersistenceController(cloud: cloud)

    var container: NSPersistentContainer

    @AppStorage("iCloudSetting") static var cloud: Bool = false

    static func reloadController() {
        shared = PersistenceController(cloud: cloud)
    }

    init(inMemory: Bool = false, cloud: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "SwiftShiftModel")


        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

        let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
        description?.setOption(true as NSNumber, forKey: remoteChangeKey)

        if !cloud {
            description?.cloudKitContainerOptions = nil
        }

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

}
