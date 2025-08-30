//
//  DataCache.swift
//  iStorageWatcher
//
//  Small helper for reading/writing SwiftData models.
//

import Foundation
import SwiftData
#if os(iOS)
import UIKit
#endif

extension URL {
    static func storeURL(for appGroup: String, databaseName: String) -> URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)?.appendingPathComponent(databaseName, isDirectory: false)
    }
}

extension DataCache {
    /// Creates a ModelContext backed by the shared App Group store, if available.
    static func makeGroupContext() -> ModelContext? {
        let schema = Schema([Device.self])
        guard let url = URL.storeURL(for: AppGroups.id, databaseName: "iStorageWatcher.sqlite") else { return nil }
        let config = ModelConfiguration(schema: schema, url: url)
        guard let container = try? ModelContainer(for: schema, configurations: config) else { return nil }
        return ModelContext(container)
    }
}

enum DataCache {
    static func currentDevice(in context: ModelContext) -> Device {
        let fetch = FetchDescriptor<Device>()
        if let existing = try? context.fetch(fetch).first {
            return existing
        }
        let device = Device(name: deviceName(), platform: platformName())
        context.insert(device)
        try? context.save()
        return device
    }

    static func cachedStorage(in context: ModelContext) -> StorageInfo? {
        guard let d = try? context.fetch(FetchDescriptor<Device>()).first,
              let total = d.storageTotalBytes,
              let free = d.storageFreeBytes else { return nil }
        return StorageInfo(totalSpace: total, freeSpace: free)
    }

    static func updateStorage(in context: ModelContext, with info: StorageInfo) {
        let device = currentDevice(in: context)
        device.storageTotalBytes = info.totalSpace
        device.storageFreeBytes = info.freeSpace
        device.lastUpdated = Date()
        try? context.save()
    }

    static func updateBattery(in context: ModelContext, health: Double, capacity: Int, charging: Bool) {
        let device = currentDevice(in: context)
        device.batteryHealthPercent = health
        device.batteryCapacityPercent = capacity
        device.isCharging = charging
        device.lastUpdated = Date()
        try? context.save()
    }

    static func deviceName() -> String {
        #if os(macOS)
        return Host.current().localizedName ?? "Mac"
        #else
        return UIDevice.current.name
        #endif
    }

    static func platformName() -> String {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone"
        #elseif os(macOS)
        return "Mac"
        #else
        return "Unknown"
        #endif
    }
}
