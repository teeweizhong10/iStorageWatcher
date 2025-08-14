import Foundation
import Combine

class BatteryHealthManager: ObservableObject, Sendable {
    // MARK: - Published Properties
    @Published var batteryHealth: Double = 0.0
    @Published var batteryCapacity: Int = 0
    @Published var isCharging: Bool = false

    static let shared = BatteryHealthManager()

    private init() {
        Task {
            await updateBatteryInfo()
        }
    }

    // MARK: - Data Fetching

    /// Updates all battery properties by running an `ioreg` command.
    @MainActor
    func updateBatteryInfo() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                do {
                    // Use a more specific ioreg command that targets battery information only
                    let process = Process()
                    process.executableURL = URL(fileURLWithPath: "/usr/sbin/ioreg")
                    process.arguments = ["-r", "-c", "AppleSmartBattery", "-w0"]
                    
                    let pipe = Pipe()
                    process.standardOutput = pipe
                    process.standardError = Pipe() // Capture errors
                    
                    try process.run()
                    
                    // Add timeout to prevent hanging
                    let timeout = DispatchTime.now() + .seconds(5)
                    let group = DispatchGroup()
                    group.enter()
                    
                    DispatchQueue.global().async {
                        process.waitUntilExit()
                        group.leave()
                    }
                    
                    let result = group.wait(timeout: timeout)
                    
                    if result == .timedOut {
                        process.terminate()
                        print("❌ ioreg command timed out")
                        DispatchQueue.main.async {
                            continuation.resume()
                        }
                        return
                    }
                    
                    guard process.terminationStatus == 0 else {
                        print("❌ ioreg command failed with status: \(process.terminationStatus)")
                        DispatchQueue.main.async {
                            continuation.resume()
                        }
                        return
                    }
                    
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let output = String(data: data, encoding: .utf8) ?? ""
                    
                    
                    // Parse the output for battery properties
                    var designCapacity: Int?
                    var nominalCapacity: Int?
                    var currentCapacity: Int?
                    var chargingStatus: Bool?
                    
                    let lines = output.components(separatedBy: .newlines)
                    for line in lines {
                        let trimmed = line.trimmingCharacters(in: .whitespaces)
                        
                        if trimmed.contains("DesignCapacity") {
                            if let value = self.extractIntegerValue(from: trimmed) {
                                designCapacity = value
                            }
                        } else if trimmed.contains("NominalChargeCapacity") {
                            if let value = self.extractIntegerValue(from: trimmed) {
                                nominalCapacity = value
                            }
                        } else if trimmed.contains("CurrentCapacity") {
                            if let value = self.extractIntegerValue(from: trimmed) {
                                currentCapacity = value
                            }
                        } else if trimmed.contains("IsCharging") {
                            chargingStatus = trimmed.contains("Yes")
                        }
                    }
                    
                    DispatchQueue.main.async {
                        // Calculate and update the published properties.
                        if let design = designCapacity, let nominal = nominalCapacity, design > 0 {
                            self.batteryHealth = (Double(nominal) / Double(design)) * 100.0
                        }
                        
                        if let current = currentCapacity, let nominal = nominalCapacity, nominal > 0 {
                            self.batteryCapacity = Int(round((Double(current) / Double(nominal)) * 100.0))
                        }
                        
                        if let isCharging = chargingStatus {
                            self.isCharging = isCharging
                        }
                        
                        continuation.resume()
                    }
                    
                } catch {
                    print("❌ Error updating battery info: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        continuation.resume()
                    }
                }
            }
        }
    }
    
    // Helper function to extract integer values from ioreg output
    private func extractIntegerValue(from line: String) -> Int? {
        // Look for pattern like "DesignCapacity" = 5103
        if let equalsRange = line.range(of: "=") {
            let valueString = String(line[equalsRange.upperBound...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\"", with: "")
            return Int(valueString)
        }
        return nil
    }

    // MARK: - Your Original Functions

    func getBatteryHealthString() -> String {
        let health = Int(round(batteryHealth)) // Round for evaluation
        if health >= 90 {
            return "Excellent"
        } else if health >= 80 {
            return "Good"
        } else if health >= 70 {
            return "Fair"
        } else if health >= 60 {
            return "Poor"
        } else {
            return "Replace Soon"
        }
    }

    func getBatteryHealthPercent() -> String {
        // This format specifier rounds the Double to the nearest whole number for display
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
