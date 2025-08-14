//
//  HintView.swift
//  iStorageWatcher
//
//  Created by Wei Zhong Tee on 1/24/25.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct BatteryHealthView: View {
    #if os(macOS)
    @StateObject private var batteryManager = BatteryHealthManager.shared
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
            }
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
