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
                Text(String(format: "Total: %.2f GB", info.totalSpaceInGB))
                Text(String(format: "Used: %.2f GB", info.usedSpaceInGB))
                Text(String(format: "Free: %.2f GB", info.freeSpaceInGB))
            } else {
                Text("Fetching storage information...")
            }
        }
        .padding()
        .onAppear {
            storageInfo = StorageManager.shared.getStorageInfo()
        }
    }
}

#Preview {
    ContentView()
}
