//
//  CloudContainer.swift
//  iStorageWatcher
//
//  Creates a SwiftData ModelContainer configured for CloudKit syncing.
//

import Foundation
import SwiftData
import CloudKit

enum CloudContainerBuilder {
    static func make() -> ModelContainer? {
        let schema = Schema([Device.self])
        // Update to your CloudKit container ID in Xcode capabilities
        let cloudId = "iCloud.com.wei.iStorageWatcher"
        // iOS/macOS 18 SwiftData API expects an identifier and CloudKit database option
        let config = ModelConfiguration("Cloud", schema: schema, cloudKitDatabase: .private(cloudId))
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            print("CloudKit ModelContainer init failed: \(error)")
            return nil
        }
    }
}
