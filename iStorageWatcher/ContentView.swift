//
//  ContentView.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 12/28/24.
//

import SwiftUI

struct ContentView: View {
    @State private var storageInfo: StorageInfo?

    var body: some View {
        VStack {
            if let info = storageInfo {
                Text(String(format: "\(StorageWatcherStrings.total.rawValue) %.2f GB", info.totalSpaceInGB))
                Text(String(format: "\(StorageWatcherStrings.used.rawValue) %.2f GB", info.usedSpaceInGB))
                Text(String(format: "\(StorageWatcherStrings.free.rawValue) %.2f GB", info.freeSpaceInGB))
                storageSettingsButton
            } else {
                Text(StorageWatcherStrings.fetchingStorageInfo.rawValue)
            }
        }
        .padding()
        .onAppear {
            storageInfo = StorageManager.shared.getStorageInfo()
        }
    }

    var storageSettingsButton: some View {
            Button(action: {
                #if os(iOS)
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                #elseif os(macOS)
                if let url = URL(string: "x-apple.systempreferences:com.apple.StorageManagement-Settings.extension") {
                    NSWorkspace.shared.open(url)
                }
                #endif
            }) {
                Text("Open Storage Settings")
                    .font(.headline)
                    .padding()
            }
        }
}

#Preview {
    ContentView()
}
