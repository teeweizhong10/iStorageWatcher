import Foundation
#if os(macOS)
import IOKit.ps

class BatteryHealthManager: ObservableObject {
    @Published var batteryHealth: Double = 0.0
    @Published var batteryCapacity: Int = 0
    @Published var isCharging: Bool = false
    
    static let shared = BatteryHealthManager()
    
    private init() {
        updateBatteryInfo()
    }
    
    func updateBatteryInfo() {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        
        for ps in sources {
            let info = IOPSGetPowerSourceDescription(snapshot, ps).takeUnretainedValue() as! [String: AnyObject]
            
            if let type = info[kIOPSTypeKey] as? String, type == kIOPSInternalBatteryType {
                // Get maximum capacity and current capacity
                if let maxCapacity = info[kIOPSMaxCapacityKey] as? Int,
                   let currentCapacity = info[kIOPSCurrentCapacityKey] as? Int {
                    self.batteryCapacity = currentCapacity
                    self.batteryHealth = Double(currentCapacity)
                }
                
                // Get charging status
                if let powerSource = info[kIOPSPowerSourceStateKey] as? String {
                    self.isCharging = (powerSource == kIOPSACPowerValue)
                }
                
                // Try to get battery health from design capacity vs max capacity
                if let designCapacity = info["DesignCapacity"] as? Int,
                   let maxCapacity = info[kIOPSMaxCapacityKey] as? Int {
                    self.batteryHealth = (Double(maxCapacity) / Double(designCapacity)) * 100.0
                }
                
                break
            }
        }
    }
    
    func getBatteryHealthString() -> String {
        if batteryHealth >= 90 {
            return "Excellent"
        } else if batteryHealth >= 80 {
            return "Good"
        } else if batteryHealth >= 70 {
            return "Fair"
        } else if batteryHealth >= 60 {
            return "Poor"
        } else {
            return "Replace Soon"
        }
    }

    func getBatteryHealthPercent() -> String {
        return String(format: "%.0f%%", batteryHealth)
    }

    func getBatteryIcon() -> String {
        if isCharging {
            return "battery.100.bolt"
        } else if batteryCapacity >= 90 {
            return "battery.100"
        } else if batteryCapacity >= 75 {
            return "battery.75"
        } else if batteryCapacity >= 50 {
            return "battery.50"
        } else if batteryCapacity >= 25 {
            return "battery.25"
        } else {
            return "battery.0"
        }
    }
}
#endif
