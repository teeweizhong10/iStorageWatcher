//
//  WidgetView.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 12/28/24.
//
import WidgetKit
import SwiftUI

struct StorageWidgetProvider: TimelineProvider {
    // Associate the 'Entry' type with 'SimpleEntry'
    typealias Entry = SimpleEntry

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            storageInfo: StorageInfo(totalSpace: 500_000_000_000, freeSpace: 200_000_000_000)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            storageInfo: StorageManager.shared.getStorageInfo() ?? StorageInfo(totalSpace: 500_000_000_000, freeSpace: 200_000_000_000)
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            storageInfo: StorageManager.shared.getStorageInfo() ?? StorageInfo(totalSpace: 500_000_000_000, freeSpace: 200_000_000_000)
        )
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 15))) // Refresh every 15 minutes
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let storageInfo: StorageInfo
}

struct StorageWidgetEntryView : View {
    var entry: StorageWidgetProvider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            VStack {
                HStack {
                    Text("Available Storage")
                        .font(.headline)
                    Spacer()
                    Text("\(Image(systemName: "internaldrive.fill"))")
                }
                Divider()
                Text(String(format: "%.1f GB", entry.storageInfo.freeSpaceInGB))
            }
        case .systemMedium:
            VStack(alignment: .leading) {
                Text("Storage")
                    .font(.headline)
                HStack {
                    Text("Total:")
                    Spacer()
                    Text(String(format: "%.1f GB", entry.storageInfo.totalSpaceInGB))
                }
                HStack {
                    Text("Used:")
                    Spacer()
                    Text(String(format: "%.1f GB", entry.storageInfo.usedSpaceInGB))
                }
                HStack {
                    Text("Free:")
                    Spacer()
                    Text(String(format: "%.1f GB", entry.storageInfo.freeSpaceInGB))
                }
            }
            .padding()
        case .systemLarge, .systemExtraLarge:
            VStack(alignment: .leading) {
                Text("Device Storage Information")
                    .font(.headline)
                Divider()
                HStack {
                    Text("Total Space:")
                    Spacer()
                    Text(String(format: "%.2f GB", entry.storageInfo.totalSpaceInGB))
                }
                HStack {
                    Text("Used Space:")
                    Spacer()
                    Text(String(format: "%.2f GB", entry.storageInfo.usedSpaceInGB))
                }
                HStack {
                    Text("Free Space:")
                    Spacer()
                    Text(String(format: "%.2f GB", entry.storageInfo.freeSpaceInGB))
                }
                Spacer()
                Text("Last Updated: \(entry.date, style: .time)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding()
        @unknown default:
            Text("Unsupported size")
        }
    }
}
