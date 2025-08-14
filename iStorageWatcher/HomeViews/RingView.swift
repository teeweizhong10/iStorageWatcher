//
//  RingView.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 1/24/25.
//

import SwiftUI

struct RingView: View {
    var percentage: Double
    var storageInGB: Double?

    private var ringColor: Color {
        let normalizedPercentage = percentage / 100
        return Color(
            hue: (1.0 - normalizedPercentage) * 0.4, // Green to Red in hue
            saturation: 1.0,
            brightness: 1.0
        )
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 15)
            Circle()
                .trim(from: 0.0, to: CGFloat(percentage / 100))
                .stroke(ringColor, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: percentage)

            Text("\(percentage, specifier: "%.1f")%\n\("used")")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 130, height: 130)
    }
}

#Preview {
    RingView(percentage: 8.0)
}
