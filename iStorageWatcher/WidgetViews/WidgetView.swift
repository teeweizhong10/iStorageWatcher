//
//  WidgetView.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 12/28/24.
//
import WidgetKit
import SwiftUI

struct StorageWidgetProvider: TimelineProvider {
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
        let currentDate = Date()
        let entry = SimpleEntry(
            date: currentDate,
            storageInfo: StorageManager.shared.getStorageInfo() ?? StorageInfo(totalSpace: 500_000_000_000, freeSpace: 200_000_000_000)
        )
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
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
                    Text(StorageWatcherStrings.availableStorage.rawValue)
                        .font(.headline)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    Text("\(Image(systemName: "internaldrive.fill"))")
                }
                Spacer()
                WidgetRingView(percentage: entry.storageInfo.usedSpacePercentage, storageInGB: entry.storageInfo.freeSpaceInGB)
                HStack {
                    Text("\(StorageWatcherStrings.lastUpdated.rawValue) \(entry.date, style: .time)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .italic()
                    Spacer()
                }
            }
        case .systemMedium:
            VStack(alignment: .leading) {
                HStack {
                    Text(StorageWatcherStrings.storage.rawValue)
                        .font(.headline)
                    Spacer()
                    Text("\(Image(systemName: "internaldrive.fill"))")
                }
                Spacer()
                HStack {
                    Text(StorageWatcherStrings.total.rawValue)
                    Spacer()
                    Text(String(format: "%.1f GB", entry.storageInfo.totalSpaceInGB))
                }
                HStack {
                    Text(StorageWatcherStrings.used.rawValue)
                    Spacer()
                    Text(String(format: "%.1f GB", entry.storageInfo.usedSpaceInGB))
                }
                HStack {
                    Text(StorageWatcherStrings.free.rawValue)
                    Spacer()
                    Text(String(format: "%.1f GB", entry.storageInfo.freeSpaceInGB))
                }
                HStack {
                    Text("\(StorageWatcherStrings.lastUpdated.rawValue) \(entry.date, style: .time)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .italic()
                    Spacer()
                }
            }
            .padding()
        case .systemLarge, .systemExtraLarge:
            VStack(alignment: .leading) {
                HStack {
                    Text(StorageWatcherStrings.deviceStorageInformation.rawValue)
                        .font(.headline)
                    Spacer()
                    Text("\(Image(systemName: "internaldrive.fill"))")
                }
                Divider()
                Spacer()
                HStack {
                    Text(StorageWatcherStrings.totalSpace.rawValue)
                    Spacer()
                    Text(String(format: "%.2f GB", entry.storageInfo.totalSpaceInGB))
                    
                }
                HStack {
                    Text(StorageWatcherStrings.usedSpace.rawValue)
                    Spacer()
                    Text(String(format: "%.2f GB", entry.storageInfo.usedSpaceInGB))
                }
                HStack {
                    Text(StorageWatcherStrings.freeSpace.rawValue)
                    Spacer()
                    Text(String(format: "%.2f GB", entry.storageInfo.freeSpaceInGB))
                }
                Spacer()
                HStack {
                    Spacer()
                    WidgetRingView(percentage: entry.storageInfo.usedSpacePercentage)
                    Spacer()
                }
                Spacer()
                HStack {
                    Text("\(StorageWatcherStrings.lastUpdated.rawValue) \(entry.date, style: .time)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .italic()
                    Spacer()
                }

            }
            .padding()
        @unknown default:
            Text(StorageWatcherStrings.unsupportedSize.rawValue)
        }
    }
}
