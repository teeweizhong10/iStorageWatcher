//
//  StorageHomeView.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 1/24/25.
//

import SwiftUI

struct StorageNumbers: View {
    let storageInfo: StorageInfo

    var body: some View {
        VStack {
            Label {
                Text(StorageWatcherStrings.totalSpace_.rawValue)
                Spacer()
                Text("\(storageInfo.totalSpaceInGB, specifier: "%.1f") GB")
                    .foregroundColor(.gray)
            } icon: {
                Circle()
                    .fill(Color.blue.opacity(0.5))
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
                    .fill(Color.yellow.opacity(0.5))
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
                    .fill(Color.green.opacity(0.5))
                    .frame(width: 10, height: 10)
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)


    }
}

#Preview {
    StorageNumbers(storageInfo: StorageInfo(totalSpace: 100000, freeSpace: 8000))
}
