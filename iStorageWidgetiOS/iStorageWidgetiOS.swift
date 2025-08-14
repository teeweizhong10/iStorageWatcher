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
    let kind: String = "iStorageWidgetiOS"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StorageWidgetProvider()) { entry in
            StorageWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Storage Information")
        .description("Displays the device's internal storage details.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
