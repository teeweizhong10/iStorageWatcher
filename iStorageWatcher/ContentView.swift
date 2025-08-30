//
//  ContentView.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 12/28/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var storageInfo: StorageInfo?
    @Environment(\.modelContext) private var modelContext
    @AppStorage("isSignedIn") private var isSignedIn = false
    
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
        // Sidebar-based layout kept for reference
        /*
        NavigationView {
            VStack {
                if let info = storageInfo {
                    HomeView(storageInfo: info)
                } else {
                    Text("Fetching storage information...")
                }
                Spacer()
            }
            .navigationTitle("iStorageWatcher")
        }
        .onAppear {
            storageInfo = StorageManager.shared.getStorageInfo()
        }
        */

        // Use NavigationStack so the content appears in the main view on iPad
        NavigationStack {
            VStack {
                if let info = storageInfo {
                    HomeView(storageInfo: info)
                } else {
                    Text("Fetching storage information...")
                }
                Spacer()
            }
            .navigationTitle("iStorageWatcher")
        }
        .onAppear { bootstrapAndRefresh() }
        .overlay(alignment: .center) {
            if !isSignedIn { SignInOverlay() }
        }
        #elseif os(macOS)
        Group {
            VStack {
                if let info = storageInfo {
                    HomeView(storageInfo: info, isMenuBarMode: $isMenuBarMode)
                        .padding()
                } else {
                    Text("Fetching storage information...")
                }
            }
        }
        .onAppear { bootstrapAndRefresh() }
        .overlay(alignment: .center) {
            if !isSignedIn { SignInOverlay() }
        }
        #endif
    }
    
    private func bootstrapAndRefresh() {
        // Prefer shared App Group store if configured; fallback to default context
        let ctx = DataCache.makeGroupContext() ?? modelContext
        // 1) Use cached values immediately if available
        if let cached = DataCache.cachedStorage(in: ctx) {
            storageInfo = cached
        }
        // 2) Fetch fresh values and persist
        if let fresh = StorageManager.shared.getStorageInfo() {
            storageInfo = fresh
            DataCache.updateStorage(in: ctx, with: fresh)
        }
    }
}

private struct SignInOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2).ignoresSafeArea()
            SignInView()
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 10)
        }
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
