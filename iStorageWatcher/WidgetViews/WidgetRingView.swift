import SwiftUI

struct WidgetRingView: View {
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
                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
            Circle()
                .trim(from: 0.0, to: CGFloat(percentage / 100))
                .stroke(ringColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: percentage)
            if let storageInGB = storageInGB {
                Text("\(storageInGB, specifier: "%.1f") GB")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
            } else {
                Text("\(percentage, specifier: "%.1f")%\n\("used")")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 100, height: 100)
    }
}

struct StorageRingView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetRingView(percentage: 75.0, storageInGB: 64.5)
            .previewLayout(.sizeThatFits)
    }
}
