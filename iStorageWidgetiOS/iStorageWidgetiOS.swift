//
//  iStorageWidgetiOS.swift
//  iStorageWidgetiOS
//
//  Created by Wei Zhong Tee on 12/29/24.
//

import WidgetKit
import SwiftUI

struct iStorageWidgetiOSEntryView : View {
    var entry: StorageWidgetProvider.Entry

    var body: some View {
        iStorageWidgetiOSEntryView(entry: entry)
    }
}

struct iStorageWidgetiOS: Widget {
    let kind: String = StorageWatcherStrings.iStorageWidgetiOSType.rawValue

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
