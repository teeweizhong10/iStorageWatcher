import Foundation
#if os(macOS)
import IOKit.ps

class BatteryHealthManager: ObservableObject {
    @Published var batteryHealth: Double = 0.0 // Health percentage (e.g., 95.5)
    @Published var currentCharge: Int = 0     // Current charge level (e.g., 80)
    @Published var isCharging: Bool = false

    static let shared = BatteryHealthManager()

    private init() {
        updateBatteryInfo()
    }

    /// Updates all battery-related properties by querying IOKit power sources.
    func updateBatteryInfo() {
        // Take a snapshot of all power source info
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef] else {
            return
        }

        // Find the internal battery among the power sources
        for ps in sources {
            guard let info = IOPSGetPowerSourceDescription(snapshot, ps)?.takeUnretainedValue() as? [String: AnyObject] else {
                continue
            }

            // Filter for the internal battery
            if let type = info[kIOPSTypeKey] as? String, type == kIOPSInternalBatteryType {

                // Get current charge, max capacity, and design capacity
                if let currentCapacity = info[kIOPSCurrentCapacityKey] as? Int,
                   let maxCapacity = info[kIOPSMaxCapacityKey] as? Int,
                   let designCapacity = info[kIOPSDesignCapacityKey] as? Int,
                   designCapacity > 0 {

                    // Set the current charge level
                    self.currentCharge = currentCapacity

                    // Calculate and set the battery health
                    self.batteryHealth = (Double(maxCapacity) / Double(designCapacity)) * 100.0
                }

                // Get charging status
                if let isCharging = info[kIOPSIsChargingKey] as? Bool {
                    self.isCharging = isCharging
                }

                // Once we've found the internal battery, we can stop looking
                break
            }
        }
    }

    // MARK: - Helper Functions

    /// Returns a descriptive string for the battery's health.
    func getBatteryHealthString() -> String {
        if batteryHealth >= 95 {
            return "Excellent"
        } else if batteryHealth >= 85 {
            return "Good"
        } else if batteryHealth >= 75 {
            return "Fair"
        } else {
            return "Service Recommended"
        }
    }

    /// Returns the battery health as a formatted percentage string.
    func getBatteryHealthPercent() -> String {
        return String(format: "%.0f%%", batteryHealth)
    }

    /// Returns an appropriate SF Symbol name based on the battery's charge and state.
    func getBatteryIcon() -> String {
        if isCharging {
            return "battery.100.bolt"
        }

        // Use a switch statement for clarity
        switch currentCharge {
        case 90...100:
            return "battery.100"
        case 75..<90:
            return "battery.75"
        case 50..<75:
            return "battery.50"
        case 25..<50:
            return "battery.25"
        case 1..<25:
            return "battery.0"
        default:
            return "battery.0.warning" // For 0% or error states
        }
    }
}
#endif
