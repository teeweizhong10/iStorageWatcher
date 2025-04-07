//
//  StorageInfoTests.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 4/6/25.
//

import XCTest
@testable import iStorageWatcher

class StorageInfoTests: XCTestCase {

    func testUsedSpace() {
        let storageInfo = StorageInfo(totalSpace: 1000, freeSpace: 400)
        XCTAssertEqual(storageInfo.usedSpace, 600)
    }

    func testTotalSpaceInGB() {
        let storageInfo = StorageInfo(totalSpace: 1_073_741_824, freeSpace: 0)
        XCTAssertEqual(storageInfo.totalSpaceInGB, 1.0)
    }

    func testFreeSpaceInGB() {
        let storageInfo = StorageInfo(totalSpace: 1_073_741_824, freeSpace: 536_870_912)
        XCTAssertEqual(storageInfo.freeSpaceInGB, 0.5)
    }

    func testUsedSpaceInGB() {
        let storageInfo = StorageInfo(totalSpace: 1_073_741_824, freeSpace: 536_870_912)
        XCTAssertEqual(storageInfo.usedSpaceInGB, 0.5)
    }

    func testFreeSpacePercentage() {
        let storageInfo = StorageInfo(totalSpace: 1000, freeSpace: 400)
        XCTAssertEqual(storageInfo.freeSpacePercentage, 40.0)
    }

    func testUsedSpacePercentage() {
        let storageInfo = StorageInfo(totalSpace: 1000, freeSpace: 400)
        XCTAssertEqual(storageInfo.usedSpacePercentage, 60.0)
    }
}
