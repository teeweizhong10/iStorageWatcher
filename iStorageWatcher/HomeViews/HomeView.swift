//
//  iOSHomeView.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 1/24/25.
//

import SwiftUI

struct HomeView: View {
    var storageInfo: StorageInfo
    
    #if os(macOS)
    @Binding var isMenuBarMode: Bool
    
    init(storageInfo: StorageInfo, isMenuBarMode: Binding<Bool>? = nil) {
        self.storageInfo = storageInfo
        self._isMenuBarMode = isMenuBarMode ?? .constant(false)
    }
    #else
    init(storageInfo: StorageInfo) {
        self.storageInfo = storageInfo
    }
    #endif

    var body: some View {
        VStack {
            StorageDetailView(storageInfo: storageInfo)

            #if os(macOS)
            // Add the menu bar toggle directly in the home view
            Toggle(StorageWatcherStrings.showAsMenubarIcon.rawValue, isOn: $isMenuBarMode)
                .padding(.horizontal)

            if !isMenuBarMode {
                HintView()
                    .padding()
            }
            #else
            HintView()
                .padding()
            #endif
        }
    }
}

#Preview {
    #if os(macOS)
    HomeView(storageInfo: StorageInfo(totalSpace: 1000, freeSpace: 800), isMenuBarMode: .constant(false))
    #else
    HomeView(storageInfo: StorageInfo(totalSpace: 1000, freeSpace: 800))
    #endif
}
