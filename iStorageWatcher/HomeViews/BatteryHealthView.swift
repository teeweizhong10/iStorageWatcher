//
//  HintView.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 1/24/25.
//

import SwiftUI
#if canImport(SwiftData)
import SwiftData
#endif
#if os(iOS)
import UIKit
#endif

struct BatteryHealthView: View {
    #if os(macOS)
    @StateObject private var batteryManager = BatteryHealthManager.shared
    @Environment(\.modelContext) private var modelContext
    #endif
    
    var body: some View {
        HStack {
            #if os(macOS)
            Image(systemName: batteryManager.getBatteryIcon())
                .foregroundColor(.green)
                .padding(.horizontal)
            Text("Battery Health: \(batteryManager.batteryHealth, specifier: "%.0f")% (\(batteryManager.getBatteryHealthString()))")
                .foregroundColor(.green)
                .fontWeight(.semibold)
                .padding(.trailing)
                .padding(.vertical)
            #else
            Image(systemName: getBatteryIconForIOS())
                .foregroundColor(.green)
                .padding(.horizontal)
            Text("Battery: \(getBatteryLevelForIOS())% (Health not available)")
                .foregroundColor(.green)
                .fontWeight(.semibold)
                .padding(.trailing)
                .padding(.vertical)
            #endif
        }
        .padding()
        .background(Color.green.opacity(0.15))
        .cornerRadius(15)
        .padding(.horizontal)
        #if os(macOS)
        .onAppear {
            Task {
                await batteryManager.updateBatteryInfo()
                let ctx = DataCache.makeGroupContext() ?? modelContext
                DataCache.updateBattery(
                    in: ctx,
                    health: batteryManager.batteryHealth,
                    capacity: batteryManager.batteryCapacity,
                    charging: batteryManager.isCharging
                )
            }
        }
        .onChange(of: batteryManager.batteryHealth) { _ in
            let ctx = DataCache.makeGroupContext() ?? modelContext
            DataCache.updateBattery(
                in: ctx,
                health: batteryManager.batteryHealth,
                capacity: batteryManager.batteryCapacity,
                charging: batteryManager.isCharging
            )
        }
        .onChange(of: batteryManager.batteryCapacity) { _ in
            let ctx = DataCache.makeGroupContext() ?? modelContext
            DataCache.updateBattery(
                in: ctx,
                health: batteryManager.batteryHealth,
                capacity: batteryManager.batteryCapacity,
                charging: batteryManager.isCharging
            )
        }
        .onChange(of: batteryManager.isCharging) { _ in
            let ctx = DataCache.makeGroupContext() ?? modelContext
            DataCache.updateBattery(
                in: ctx,
                health: batteryManager.batteryHealth,
                capacity: batteryManager.batteryCapacity,
                charging: batteryManager.isCharging
            )
        }
        #endif
    }
    
    #if os(iOS)
    private func getBatteryLevelForIOS() -> Int {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return Int(UIDevice.current.batteryLevel * 100)
    }
    
    private func getBatteryIconForIOS() -> String {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = UIDevice.current.batteryLevel * 100
        let state = UIDevice.current.batteryState
        
        if state == .charging {
            return "battery.100.bolt"
        } else if level >= 90 {
            return "battery.100"
        } else if level >= 75 {
            return "battery.75"
        } else if level >= 50 {
            return "battery.50"
        } else if level >= 25 {
            return "battery.25"
        } else {
            return "battery.0"
        }
    }
    #endif
}

#Preview {
    BatteryHealthView()
}
