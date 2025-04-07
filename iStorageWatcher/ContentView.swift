//
//  ContentView.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 12/28/24.
//

import SwiftUI

struct ContentView: View {
    @State private var storageInfo: StorageInfo?
    
    #if os(macOS)
    @Binding var isMenuBarMode: Bool
    
    init(isMenuBarMode: Binding<Bool>) {
        self._isMenuBarMode = isMenuBarMode
    }
    #else
    init() {}
    #endif
    
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
        Group {
            VStack {
                if let info = storageInfo {
                    HomeView(storageInfo: info, isMenuBarMode: $isMenuBarMode)
                        .padding()
                } else {
                    Text(StorageWatcherStrings.fetchingStorageInfo.rawValue)
                }
            }
        }
        .onAppear {
            storageInfo = StorageManager.shared.getStorageInfo()
        }
        #endif
    }
}

#if DEBUG
#Preview {
    #if os(macOS)
    ContentView(isMenuBarMode: .constant(false))
    #else
    ContentView()
    #endif
}
#endif
