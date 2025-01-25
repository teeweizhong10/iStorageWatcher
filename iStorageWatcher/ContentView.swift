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
#if os(iOS)
        NavigationView {
            VStack {
                if let info = storageInfo {
                    HomeView(storageInfo: info)
                } else {
                    Text(StorageWatcherStrings.fetchingStorageInfo.rawValue)
                }
                Spacer()
            }
            .navigationTitle(StorageWatcherStrings.appName.rawValue)
        }
        .onAppear {
            storageInfo = StorageManager.shared.getStorageInfo()
        }
#elseif os(macOS)
        VStack {
            if let info = storageInfo {
                HomeView(storageInfo: info)
            } else {
                Text(StorageWatcherStrings.fetchingStorageInfo.rawValue)
            }
        }
        .onAppear {
            storageInfo = StorageManager.shared.getStorageInfo()
        }
#endif
    }
}

#Preview {
    ContentView()
}
