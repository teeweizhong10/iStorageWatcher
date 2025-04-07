//
//  iStorageWatcherApp.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 12/28/24.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

#if os(macOS)
class StatusBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var storageInfo: StorageInfo?
    
    @Published var isMenuBarMode: Bool = false {
        didSet {
            updateStatusBarItem()
        }
    }
    
    init() {
        self.storageInfo = StorageManager.shared.getStorageInfo()
    }
    
    func updateStatusBarItem() {
        if isMenuBarMode {
            DispatchQueue.main.async {
                if let window = NSApplication.shared.windows.first {
                    window.close()
                }
            }
            setupStatusBarItem()
        } else {
            removeStatusBarItem()
        }
    }
    
    private func setupStatusBarItem() {
        if statusItem == nil {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            
            if let button = statusItem?.button {
                button.image = NSImage(systemSymbolName: "externaldrive.fill", accessibilityDescription: "iStorage")
                button.action = #selector(togglePopover)
                button.target = self
            }
            
            setupPopover()
        }
    }
    
    private func removeStatusBarItem() {
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
            self.popover = nil
        }
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 360, height: 500)
        popover?.behavior = .transient

        let menuBarBinding = Binding<Bool>(
            get: { self.isMenuBarMode },
            set: { newValue in
                self.isMenuBarMode = newValue
                UserDefaults.standard.set(newValue, forKey: "showAsMenuBar")
            }
        )

        let homeView = HomeView(
            storageInfo: storageInfo ?? StorageInfo(totalSpace: 0, freeSpace: 0),
            isMenuBarMode: menuBarBinding
        ).padding()
        
        popover?.contentViewController = NSHostingController(rootView: homeView)
    }
    
    @objc private func togglePopover() {
        guard let popover = popover, let button = statusItem?.button else { return }
        
        if popover.isShown {
            popover.close()
        } else {
            self.storageInfo = StorageManager.shared.getStorageInfo()
            setupPopover()
            
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
#endif

@main
struct iStorageWatcherApp: App {
    #if os(macOS)
    @StateObject private var statusBarManager = StatusBarManager()
    @AppStorage("showAsMenuBar") private var showAsMenuBar = false
    #endif
    
    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            ContentView(isMenuBarMode: $showAsMenuBar)
                .frame(minWidth: 400, minHeight: 300)
                .onAppear {
                    statusBarManager.isMenuBarMode = showAsMenuBar
                }
                .onChange(of: showAsMenuBar) { newValue in
                    statusBarManager.isMenuBarMode = newValue

                    if newValue {
                        DispatchQueue.main.async {
                            if let window = NSApplication.shared.windows.first {
                                window.close()
                            }
                        }
                    }
                }
            #else
            ContentView()
            #endif
        }
    }
}
