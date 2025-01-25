//
//  HintView.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 1/24/25.
//

import SwiftUI

struct HintView: View {
    var body: some View {
        HStack {
            Image(systemName: "lightbulb")
                .foregroundColor(Color.blue)
                .padding()
            Text(StorageWatcherStrings.widgetHint.rawValue)
                .foregroundColor(Color.blue)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

#Preview {
    HintView()
}
