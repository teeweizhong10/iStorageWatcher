import SwiftUI

struct StorageRingView: View {
    var percentage: Double 
    var storageInGB: Double?

    private var ringColor: Color {
        switch percentage {
        case 0.0..<50.0:
            return .green
        case 50.0..<80.0:
            return .yellow
        default:
            return .red
        }
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
                Text("\(percentage, specifier: "%.1f")%\nused")
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
        StorageRingView(percentage: 75.0, storageInGB: 64.5)
            .previewLayout(.sizeThatFits)
    }
}
