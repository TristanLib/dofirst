import Foundation
import ManagedSettings

enum SharedScreenTimeKeys {
    static let appGroupIdentifier = "group.tristan.dofirst"
    static let encodedSelection = "encodedFamilyActivitySelection"
    static let lastShieldAction = "lastShieldAction"
    static let activeRuleName = "activeRuleName"
    static let emergencyUnlockRequestedAt = "emergencyUnlockRequestedAt"
    static let activeDeviceActivityNames = "activeDeviceActivityNames"
}

extension ManagedSettingsStore.Name {
    static let daily = Self("DoFirstDailyStore")
}
