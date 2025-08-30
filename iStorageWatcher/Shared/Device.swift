//
//  Device.swift
//  iStorageWatcher
//
//  Adds SwiftData models for local caching of device metrics.
//

import Foundation
import SwiftData

@Model
final class Device {
    // Identity (defaults required for CloudKit-backed SwiftData)
    var id: UUID = UUID()
    var name: String = ""
    var platform: String = ""
    // Local stable key to deduplicate a physical device across restarts/sign-in cycles
    var deviceKey: String = ""

    // Metrics
    var lastUpdated: Date?
    var storageTotalBytes: UInt64?
    var storageFreeBytes: UInt64?
    var batteryHealthPercent: Double?
    var batteryCapacityPercent: Int?
    var isCharging: Bool?

    init(name: String = "", platform: String = "", deviceKey: String = "") {
        self.name = name
        self.platform = platform
        self.deviceKey = deviceKey
    }
}
