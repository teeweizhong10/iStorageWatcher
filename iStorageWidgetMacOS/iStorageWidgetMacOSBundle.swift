//
//  iStorageWidgetMacOSBundle.swift
//  iStorageWidgetMacOS
//
//  Created by Wei Zhong Tee on 12/28/24.
//

import WidgetKit
import SwiftUI

@main
struct iStorageWidgetMacOS: Widget {
    let kind: String = StorageWatcherStrings.iStorageWidgetMacOSType.rawValue

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StorageWidgetProvider()) { entry in
            StorageWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(StorageWatcherStrings.storageInformation.rawValue)
        .description(StorageWatcherStrings.storageInformationDescription.rawValue)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Preview
struct iStorageWidgetMacOS_Previews: PreviewProvider {
    static var previews: some View {
        StorageWidgetEntryView(entry: SimpleEntry(
            date: Date(),
            storageInfo: StorageInfo(totalSpace: 500_000_000_000, freeSpace: 200_000_000_000)
        ))
        .previewContext(WidgetPreviewContext(family: .systemSmall))

        StorageWidgetEntryView(entry: SimpleEntry(
            date: Date(),
            storageInfo: StorageInfo(totalSpace: 500_000_000_000, freeSpace: 200_000_000_000)
        ))
        .previewContext(WidgetPreviewContext(family: .systemMedium))

        StorageWidgetEntryView(entry: SimpleEntry(
            date: Date(),
            storageInfo: StorageInfo(totalSpace: 500_000_000_000, freeSpace: 200_000_000_000)
        ))
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
