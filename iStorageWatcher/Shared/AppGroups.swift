//
//  AppGroups.swift
//  iStorageWatcher
//
//  Shared App Group identifier for cross-target storage (App + Widgets).
//  Update this to match the App Group you enable in Xcode capabilities.
//

import Foundation

enum AppGroups {
    #if os(macOS)
    static let id: String = "FG6VT6A3M9.iStorageWatcher"
    #else
    static let id: String = "group.iStorageWatcher"
    #endif
}

