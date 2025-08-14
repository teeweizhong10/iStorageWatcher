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
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.blue.opacity(0.5))
                    .frame(width: 10, height: 10)
                Text("Total Space")
                    .frame(width: 110, alignment: .leading) // Adjust width as needed
                Text("\(storageInfo.totalSpaceInGB, specifier: "%.1f") GB")
                    .foregroundColor(.gray)
            }
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.yellow.opacity(0.5))
                    .frame(width: 10, height: 10)
                Text("Used Space")
                    .frame(width: 110, alignment: .leading)
                Text("\(storageInfo.usedSpaceInGB, specifier: "%.1f") GB")
                    .foregroundColor(.gray)
            }
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.green.opacity(0.5))
                    .frame(width: 10, height: 10)
                Text("Free Space")
                    .frame(width: 110, alignment: .leading)
                Text("\(storageInfo.freeSpaceInGB, specifier: "%.1f") GB")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    StorageNumbers(storageInfo: StorageInfo(totalSpace: 100000, freeSpace: 8000))
}
