//
//  WidgetView.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 12/28/24.
//
//  Note: Widget currently fetches fresh values directly. If you want the widget
//  to write/read the same SwiftData store as the app, configure an App Group
//  and point your ModelContainer at the group URL in both targets. This
//  requires entitlements changes in Xcode.
import WidgetKit
import SwiftUI
import SwiftData

#if canImport(SwiftData)
@Model final class WidgetDevice {
    var id: UUID = UUID()
    var name: String = ""
    var platform: String = ""
    var lastUpdated: Date?
    var storageTotalBytes: UInt64?
    var storageFreeBytes: UInt64?
    var batteryHealthPercent: Double?
    var batteryCapacityPercent: Int?
    var isCharging: Bool?
    init(name: String = "", platform: String = "") {
        self.name = name
        self.platform = platform
    }
}

extension URL {
    static func widgetStoreURL(for appGroup: String, databaseName: String) -> URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)?.appendingPathComponent(databaseName, isDirectory: false)
    }
}
#endif

struct StorageWidgetProvider: TimelineProvider {
    typealias Entry = SimpleEntry

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            storageInfo: StorageInfo(totalSpace: 500_000_000_000, freeSpace: 200_000_000_000)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let fresh = StorageManager.shared.getStorageInfo() ?? StorageInfo(totalSpace: 500_000_000_000, freeSpace: 200_000_000_000)
        persistToSharedStore(info: fresh)
        let entry = SimpleEntry(date: Date(), storageInfo: fresh)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        let fresh = StorageManager.shared.getStorageInfo() ?? StorageInfo(totalSpace: 500_000_000_000, freeSpace: 200_000_000_000)
        persistToSharedStore(info: fresh)
        let entry = SimpleEntry(date: currentDate, storageInfo: fresh)
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
                    Text("Available Storage")
                        .font(.headline)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    Text("\(Image(systemName: "internaldrive.fill"))")
                }
                Spacer()
                WidgetRingView(percentage: entry.storageInfo.usedSpacePercentage, storageInGB: entry.storageInfo.freeSpaceInGB)
                HStack {
                    Text("Last updated \(entry.date, style: .time)")
                        .foregroundColor(.gray)
                        .italic()
                        .font(.system(size: 9))
                        .padding(.init(top: 2, leading: 0, bottom: 2, trailing: 0))
                    Spacer()
                }
            }
        case .systemMedium:
            VStack(alignment: .leading) {
                HStack {
                    Text("Device Storage Information")
                        .font(.headline)
                    Spacer()
                    Text("\(Image(systemName: "internaldrive.fill"))")
                }
                Divider()
                Spacer()
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
                HStack {
                    Text("Last updated \(entry.date, style: .time)")
                        .foregroundColor(.gray)
                        .italic()
                        .font(.system(size: 9))
                        .padding(.init(top: 5, leading: 0, bottom: 2, trailing: 0))
                    Spacer()
                }
            }
            .padding()
        case .systemLarge, .systemExtraLarge:
            VStack(alignment: .leading) {
                HStack {
                    Text("Device Storage Information")
                        .font(.headline)
                    Spacer()
                    Text("\(Image(systemName: "internaldrive.fill"))")
                }
                Divider()
                Spacer()
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
                HStack {
                    Spacer()
                    WidgetRingView(percentage: entry.storageInfo.usedSpacePercentage)
                    Spacer()
                }
                Spacer()
                HStack {
                    Text("Last updated \(entry.date, style: .time)")
                        .foregroundColor(.gray)
                        .italic()
                        .font(.system(size: 9))
                        .padding(.init(top: 2, leading: 0, bottom: 2, trailing: 0))
                    Spacer()
                }
            }
            .padding()
        @unknown default:
            Text("Unsupported size")
        }
    }
}

// MARK: - Shared Store Helpers (Widget)
private func persistToSharedStore(info: StorageInfo) {
    #if canImport(SwiftData)
    func currentDevice(in context: ModelContext) -> WidgetDevice {
        if let existing = try? context.fetch(FetchDescriptor<WidgetDevice>()).first { return existing }
        let device = WidgetDevice(name: "WidgetHost", platform: "macOS")
        context.insert(device)
        try? context.save()
        return device
    }

    let schema = Schema([WidgetDevice.self])
    #if os(macOS)
    let id: String = "FG6VT6A3M9.iStorageWatcher"
    #else
    let id: String = "group.iStorageWatcher"
    #endif
    if let url = URL.widgetStoreURL(for: id, databaseName: "iStorageWatcher.sqlite"),
       let container = try? ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, url: url)) {
        let context = ModelContext(container)
        let device = currentDevice(in: context)
        device.storageTotalBytes = info.totalSpace
        device.storageFreeBytes = info.freeSpace
        device.lastUpdated = Date()
        try? context.save()
    }
    #endif
}
