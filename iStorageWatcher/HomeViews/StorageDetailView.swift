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
                Text("Storage")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text(getDeviceType())
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            #if os(iOS)
            VStack {
                RingView(percentage: storageInfo.usedSpacePercentage)
                    .padding()
                StorageNumbers(storageInfo: storageInfo)
            }
            .padding()
            #elseif os(macOS)
            Spacer()
            HStack {
                RingView(percentage: storageInfo.usedSpacePercentage)
                StorageNumbers(storageInfo: storageInfo)
            }
            Spacer()
            #endif

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
            Text("Open System Settings")
                .fontWeight(.bold)
        }
        .padding(.horizontal)
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
