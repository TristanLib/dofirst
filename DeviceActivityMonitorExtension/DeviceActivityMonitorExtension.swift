import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings

final class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let store = ManagedSettingsStore(named: .daily)

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        setActivity(activity, isActive: true)
        applySavedShield()
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        setActivity(activity, isActive: false)
        if hasActiveActivities {
            applySavedShield()
        } else {
            store.clearAllSettings()
        }
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
    }

    private func applySavedShield() {
        guard
            let data = UserDefaults(suiteName: SharedScreenTimeKeys.appGroupIdentifier)?
                .data(forKey: SharedScreenTimeKeys.encodedSelection),
            let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else {
            return
        }

        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
        store.shield.webDomainCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
    }

    private var hasActiveActivities: Bool {
        guard let defaults = UserDefaults(suiteName: SharedScreenTimeKeys.appGroupIdentifier) else {
            return false
        }
        return !(defaults.stringArray(forKey: SharedScreenTimeKeys.activeDeviceActivityNames) ?? []).isEmpty
    }

    private func setActivity(_ activity: DeviceActivityName, isActive: Bool) {
        guard let defaults = UserDefaults(suiteName: SharedScreenTimeKeys.appGroupIdentifier) else {
            return
        }

        var activeActivities = Set(defaults.stringArray(forKey: SharedScreenTimeKeys.activeDeviceActivityNames) ?? [])
        if isActive {
            activeActivities.insert(activity.rawValue)
        } else {
            activeActivities.remove(activity.rawValue)
        }
        defaults.set(Array(activeActivities), forKey: SharedScreenTimeKeys.activeDeviceActivityNames)
    }
}
