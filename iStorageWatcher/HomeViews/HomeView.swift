//
//  iOSHomeView.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 1/24/25.
//

import SwiftUI

struct HomeView: View {
    var storageInfo: StorageInfo

    init(storageInfo: StorageInfo) {
        self.storageInfo = storageInfo
    }

    var body: some View {
        VStack {
            StorageDetailView(storageInfo: storageInfo)
            Spacer()
            HintView()
        }
    }
}

#Preview {
    HomeView(storageInfo: StorageInfo(totalSpace: 1000, freeSpace: 8000))
}
