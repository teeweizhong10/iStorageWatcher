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
}

class StorageManager {
    static let shared = StorageManager()

    private init() {}

    func getStorageInfo() -> StorageInfo? {
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let totalSpace = attributes[.systemSize] as? UInt64,
               let freeSpace = attributes[.systemFreeSize] as? UInt64 {
                return StorageInfo(totalSpace: totalSpace, freeSpace: freeSpace)
            }
        } catch {
            print("Error retrieving storage info: \(error.localizedDescription)")
        }
        return nil
    }
}
