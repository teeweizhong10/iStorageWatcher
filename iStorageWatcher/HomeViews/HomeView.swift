//
//  iOSHomeView.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 1/24/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    var storageInfo: StorageInfo
    @AppStorage("isSignedIn") private var isSignedIn = true
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Device.lastUpdated, order: .reverse) private var devices: [Device]
    @State private var isSwitcherExpanded = false
    @State private var selectedDeviceID: UUID?
    
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
        VStack(spacing: 12) {
            header
            StorageDetailView(storageInfo: selectedStorageInfo ?? storageInfo,
                              deviceName: selectedDeviceName ?? localDeviceName)

            #if os(macOS)
            // Add the menu bar toggle directly in the home view
        //TODO: Reimplment menubar toggle one day
//            Toggle(StorageWatcherStrings.showAsMenubarIcon.rawValue, isOn: $isMenuBarMode)
//                .padding(.horizontal)
//
//            if !isMenuBarMode {
//                HintView()
//                    .padding()
//            }
            BatteryHealthView()
            #else
//            BatteryHealthView()
//                .padding()
            #endif
            deviceSwitcherBar
        }
    }
}

private extension HomeView {
    var header: some View {
        HStack {
            Text("Home")
                .font(.title2).bold()
            Spacer()
            Button("Sign Out") { isSignedIn = false }
                .buttonStyle(.bordered)
        }
        .padding(.horizontal)
    }

    var selectedStorageInfo: StorageInfo? {
        guard let id = selectedDeviceID, let d = uniqueDevices.first(where: { $0.id == id }),
              let total = d.storageTotalBytes, let free = d.storageFreeBytes else { return nil }
        return StorageInfo(totalSpace: total, freeSpace: free)
    }

    var deviceSwitcherBar: some View {
        VStack(spacing: 8) {
            Button(action: { withAnimation { isSwitcherExpanded.toggle() } }) {
                HStack {
                    Image(systemName: isSwitcherExpanded ? "chevron.down" : "chevron.up")
                    Text("Devices")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(devices.count == 0 ? "No devices yet" : "\(devices.count)")
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isSwitcherExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(uniqueDevices, id: \.id) { device in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(device.name).fontWeight(.semibold)
                                Text(device.platform).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            if let total = device.storageTotalBytes, let free = device.storageFreeBytes {
                                let used = Double(total) - Double(free)
                                let pct = total > 0 ? (used / Double(total)) * 100.0 : 0.0
                                let label = String(format: "%.0f%% used", pct)
                                Text(label)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { selectedDeviceID = device.id }
                    }
                }
                .padding(10)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

private extension HomeView {
    var selectedDeviceName: String? {
        guard let id = selectedDeviceID, let d = uniqueDevices.first(where: { $0.id == id }) else { return nil }
        return d.name.isEmpty ? nil : d.name
    }

    var localDeviceName: String {
        #if os(macOS)
        return Host.current().localizedName ?? "Mac"
        #else
        return UIDevice.current.name
        #endif
    }
}

private extension HomeView {
    // Deduplicate devices by deviceKey if present, else by name+platform, keeping most recently updated
    var uniqueDevices: [Device] {
        var buckets: [String: Device] = [:]
        for d in devices {
            let key = !(d.deviceKey.isEmpty) ? d.deviceKey : "\(d.name.lowercased())|\(d.platform.lowercased())"
            if let existing = buckets[key] {
                let existingDate = existing.lastUpdated ?? .distantPast
                let newDate = d.lastUpdated ?? .distantPast
                if newDate > existingDate { buckets[key] = d }
            } else {
                buckets[key] = d
            }
        }
        // Preserve sort by lastUpdated desc
        return buckets.values.sorted { ( ($0.lastUpdated ?? .distantPast) > ($1.lastUpdated ?? .distantPast) ) }
    }
}

#Preview {
    #if os(macOS)
    HomeView(storageInfo: StorageInfo(totalSpace: 1000, freeSpace: 800), isMenuBarMode: .constant(false))
    #else
    HomeView(storageInfo: StorageInfo(totalSpace: 1000, freeSpace: 800))
    #endif
}
