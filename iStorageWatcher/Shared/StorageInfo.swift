//
//  StorageInfo.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 12/28/24.
//

import Foundation

struct StorageInfo {
    let totalSpace: UInt64
    let freeSpace: UInt64
    var usedSpace: UInt64 {
        return totalSpace - freeSpace
    }

    var totalSpaceInGB: Double {
        return Double(totalSpace) / 1_073_741_824
    }

    var freeSpaceInGB: Double {
        return Double(freeSpace) / 1_073_741_824
    }

    var usedSpaceInGB: Double {
        return Double(usedSpace) / 1_073_741_824
    }

    var freeSpacePercentage: Double {
        guard totalSpace > 0 else { return 0.0 }
        return (Double(freeSpace) / Double(totalSpace) * 100).rounded(toPlaces: 1)
    }

    var usedSpacePercentage: Double {
        guard totalSpace > 0 else { return 0.0 }
        return (Double(usedSpace) / Double(totalSpace) * 100).rounded(toPlaces: 1)
    }
}

extension Double {
    /// Rounds the double to 'places' decimal places.
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

struct StorageManager {
    static let shared = StorageManager()

    func getStorageInfo() -> StorageInfo? {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)

        do {
            let keys: Set<URLResourceKey> = [
                .volumeAvailableCapacityForImportantUsageKey,
                .volumeTotalCapacityKey
            ]
            let values = try fileURL.resourceValues(forKeys: keys)

            if let totalCapacity = values.volumeTotalCapacity,
               let availableCapacity = values.volumeAvailableCapacityForImportantUsage {
                return StorageInfo(totalSpace: UInt64(totalCapacity), freeSpace: UInt64(availableCapacity))
            }
        } catch {
            print("Error retrieving file system attributes: \(error.localizedDescription)")
        }
        return nil
    }
}
