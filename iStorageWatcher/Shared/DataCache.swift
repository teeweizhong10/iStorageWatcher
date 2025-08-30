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

private var _sharedGroupContainer: ModelContainer? = {
    let schema = Schema([Device.self])
    guard let url = URL.storeURL(for: AppGroups.id, databaseName: "iStorageWatcher.sqlite") else { return nil }
    let config = ModelConfiguration(schema: schema, url: url)
    return try? ModelContainer(for: schema, configurations: config)
}()

extension DataCache {
    /// Returns a ModelContext backed by the shared App Group store, reusing a single container.
    static func makeGroupContext() -> ModelContext? {
        guard let container = _sharedGroupContainer else { return nil }
        return ModelContext(container)
    }
}

enum DataCache {
    /// Remove duplicate Device rows, keeping the most recently updated per logical device key.
    @discardableResult
    static func cleanupDuplicates(in context: ModelContext) -> Int {
        guard let all = try? context.fetch(FetchDescriptor<Device>()) else { return 0 }
        var buckets: [String: Device] = [:]
        var toDelete: [Device] = []
        func key(for d: Device) -> String {
            if !d.deviceKey.isEmpty { return d.deviceKey }
            return "\(d.name.lowercased())|\(d.platform.lowercased())"
        }
        for d in all {
            let k = key(for: d)
            if let existing = buckets[k] {
                let existingDate = existing.lastUpdated ?? .distantPast
                let newDate = d.lastUpdated ?? .distantPast
                if newDate > existingDate {
                    toDelete.append(existing)
                    buckets[k] = d
                } else {
                    toDelete.append(d)
                }
            } else {
                buckets[k] = d
            }
        }
        guard !toDelete.isEmpty else { return 0 }
        toDelete.forEach { context.delete($0) }
        try? context.save()
        return toDelete.count
    }
    static func currentDevice(in context: ModelContext) -> Device {
        let key = localDeviceKey()
        let dn = deviceName()
        let pf = platformName()
        // Look up by stable deviceKey first
        if let existing = try? context.fetch(FetchDescriptor<Device>(
            predicate: #Predicate { $0.deviceKey == key }
        )).first {
            return existing
        }
        // Fallback: if no key match, attempt to find by name+platform (legacy rows)
        if let legacy = try? context.fetch(FetchDescriptor<Device>(
            predicate: #Predicate { $0.name == dn && $0.platform == pf }
        )).first {
            legacy.deviceKey = key
            try? context.save()
            return legacy
        }
        // Create new record
        let device = Device(name: dn, platform: pf, deviceKey: key)
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
        device.name = deviceName()
        device.platform = platformName()
        device.storageTotalBytes = info.totalSpace
        device.storageFreeBytes = info.freeSpace
        device.lastUpdated = Date()
        try? context.save()
    }

    static func updateBattery(in context: ModelContext, health: Double, capacity: Int, charging: Bool) {
        let device = currentDevice(in: context)
        device.name = deviceName()
        device.platform = platformName()
        device.batteryHealthPercent = health
        device.batteryCapacityPercent = capacity
        device.isCharging = charging
        device.lastUpdated = Date()
        try? context.save()
    }

    // Stable per-install device key used for deduplication; stored in UserDefaults
    static func localDeviceKey() -> String {
        let keyName = "localDeviceKey"
        if let existing = UserDefaults.standard.string(forKey: keyName) { return existing }
        let newKey = UUID().uuidString
        UserDefaults.standard.set(newKey, forKey: keyName)
        return newKey
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
