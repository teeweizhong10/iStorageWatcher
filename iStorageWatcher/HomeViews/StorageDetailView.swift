//
//  StorageHomeView.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 1/24/25.
//

import SwiftUI

struct StorageDetailView: View {
    let storageInfo: StorageInfo

    var body: some View {
        VStack {
            HStack {
                Text(StorageWatcherStrings.storage.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text(getDeviceType())
                    .foregroundColor(.gray)
            }
            .padding()

            RingView(percentage: storageInfo.usedSpacePercentage)

            VStack {
                Label {
                    Text(StorageWatcherStrings.totalSpace_.rawValue)
                    Spacer()
                    Text("\(storageInfo.totalSpaceInGB, specifier: "%.1f") GB")
                        .foregroundColor(.gray)
                } icon: {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 10, height: 10)
                }
                .padding(.horizontal)

                Label {
                    Text(StorageWatcherStrings.usedSpace_.rawValue)
                    Spacer()
                    Text("\(storageInfo.usedSpaceInGB, specifier: "%.1f") GB")
                        .foregroundColor(.gray)
                } icon: {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 10, height: 10)
                }
                .padding(.horizontal)


                Label {
                    Text(StorageWatcherStrings.freeSpace_.rawValue)
                    Spacer()
                    Text("\(storageInfo.freeSpaceInGB, specifier: "%.1f") GB")
                        .foregroundColor(.gray)
                } icon: {
                    Circle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 10, height: 10)
                }
                .padding(.horizontal)
            }
            .padding()

            openSettingsButton
        }
        .padding()
    }

    var openSettingsButton: some View {
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
            Text(StorageWatcherStrings.openSystemSettings.rawValue)
                .fontWeight(.bold)
        }
        .padding()
    }
}

func getDeviceType() -> String {
    #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return "iPad"
        } else {
            return "iPhone"
        }
    #elseif os(macOS)
        return "Mac"
    #else
        return "Unknown Device"
    #endif
}

#Preview {
    StorageDetailView(storageInfo: StorageInfo(totalSpace: 100000, freeSpace: 8000))
}
