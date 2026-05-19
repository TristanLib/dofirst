import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings
import Observation
import SwiftData
import UserNotifications

@MainActor
@Observable
final class ScreenTimeController {
    private let authorizationCenter = AuthorizationCenter.shared
    private let managedSettingsStore = ManagedSettingsStore(named: .daily)
    private var unlockTimer: Timer?

    var authorizationStatus: AuthorizationStatus
    var selection = FamilyActivitySelection()
    var lastErrorMessage: String?
    var isShieldActive = false
    var temporaryUnlockEndsAt: Date?
    var lastAppliedProfileName: String?
    var activeProfileID: UUID?

    init() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }

    var authorizationLabel: String {
        switch authorizationStatus {
        case .approved:
            return "已授权"
        case .denied:
            return "已拒绝"
        case .notDetermined:
            return "未授权"
        default:
            if #available(iOS 26.4, *), authorizationStatus == .approvedWithDataAccess {
                return "已授权并允许数据访问"
            }
            return authorizationStatus.description
        }
    }

    var selectionSummary: String {
        let appCount = selection.applicationTokens.count
        let categoryCount = selection.categoryTokens.count
        let domainCount = selection.webDomainTokens.count
        let parts = [
            appCount > 0 ? "\(appCount) 个 App" : nil,
            categoryCount > 0 ? "\(categoryCount) 个类别" : nil,
            domainCount > 0 ? "\(domainCount) 个网站" : nil
        ].compactMap { $0 }
        return parts.isEmpty ? "尚未选择限制对象" : parts.joined(separator: "、")
    }

    func refreshAuthorizationStatus() {
        authorizationStatus = authorizationCenter.authorizationStatus
    }

    func requestAuthorization() async {
        do {
            try await authorizationCenter.requestAuthorization(for: .individual)
            refreshAuthorizationStatus()
            lastErrorMessage = nil
        } catch {
            refreshAuthorizationStatus()
            lastErrorMessage = error.localizedDescription
        }
    }

    func revokeAuthorization() {
        authorizationCenter.revokeAuthorization { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success:
                    self?.refreshAuthorizationStatus()
                    self?.lastErrorMessage = nil
                case .failure(let error):
                    self?.lastErrorMessage = error.localizedDescription
                }
            }
        }
    }

    @discardableResult
    func saveCurrentSelection(named name: String, in context: ModelContext) -> AppSelectionProfile? {
        guard selection.hasSelection else {
            lastErrorMessage = "请先选择至少一个 App、类别或网站。"
            return nil
        }

        do {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let data = try JSONEncoder().encode(selection)
            let profile = AppSelectionProfile(
                name: trimmedName.isEmpty ? "默认限制对象" : trimmedName,
                selectedTokensData: data,
                applicationCount: selection.applicationTokens.count,
                categoryCount: selection.categoryTokens.count,
                webDomainCount: selection.webDomainTokens.count
            )
            context.insert(profile)
            try context.save()
            saveSelectionForExtensions(data)
            activeProfileID = profile.id
            lastErrorMessage = nil
            return profile
        } catch {
            lastErrorMessage = "保存选择失败：\(error.localizedDescription)"
            return nil
        }
    }

    func loadSelection(from profile: AppSelectionProfile) {
        do {
            selection = try JSONDecoder().decode(FamilyActivitySelection.self, from: profile.selectedTokensData)
            saveSelectionForExtensions(profile.selectedTokensData)
            activeProfileID = profile.id
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "读取限制对象失败：\(error.localizedDescription)"
        }
    }

    func applyShield(using profile: AppSelectionProfile?) {
        guard let profile else {
            lastErrorMessage = "请先保存一个 App / 类别 / 网站选择。"
            return
        }
        guard profile.hasSelection else {
            lastErrorMessage = "当前配置没有限制对象，请重新选择并保存。"
            return
        }

        do {
            let decodedSelection = try JSONDecoder().decode(FamilyActivitySelection.self, from: profile.selectedTokensData)
            apply(selection: decodedSelection, activeRuleName: profile.name)
            activeProfileID = profile.id
            lastAppliedProfileName = profile.name
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "应用限制失败：\(error.localizedDescription)"
        }
    }

    func applyCurrentSelection(activeRuleName: String = "手动限制") {
        guard selection.hasSelection else {
            lastErrorMessage = "请先选择至少一个 App、类别或网站。"
            return
        }
        apply(selection: selection, activeRuleName: activeRuleName)
        lastErrorMessage = nil
    }

    func clearShield() {
        managedSettingsStore.clearAllSettings()
        isShieldActive = false
        temporaryUnlockEndsAt = nil
        lastAppliedProfileName = nil
        unlockTimer?.invalidate()
        unlockTimer = nil
    }

    func unlockEntertainment(minutes: Int, profile: AppSelectionProfile?) {
        guard let profile, profile.hasSelection else {
            lastErrorMessage = "请先保存一个 App / 类别 / 网站选择。"
            return
        }
        clearShield()
        temporaryUnlockEndsAt = Calendar.current.date(byAdding: .minute, value: minutes, to: .now)
        let profileData = profile.selectedTokensData
        let profileName = profile.name
        unlockTimer?.invalidate()
        unlockTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(minutes * 60), repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.applyShield(data: profileData, name: profileName)
            }
        }
    }

    func scheduleNotificationAuthorization() async {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        } catch {
            lastErrorMessage = "通知授权失败：\(error.localizedDescription)"
        }
    }

    private func apply(selection: FamilyActivitySelection, activeRuleName: String) {
        guard selection.hasSelection else {
            lastErrorMessage = "请先选择至少一个 App、类别或网站。"
            return
        }
        managedSettingsStore.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        managedSettingsStore.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        managedSettingsStore.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
        managedSettingsStore.shield.webDomainCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        isShieldActive = true
        lastAppliedProfileName = activeRuleName

        if let defaults = UserDefaults(suiteName: SharedScreenTimeKeys.appGroupIdentifier),
           let encoded = try? JSONEncoder().encode(selection) {
            defaults.set(encoded, forKey: SharedScreenTimeKeys.encodedSelection)
            defaults.set(activeRuleName, forKey: SharedScreenTimeKeys.activeRuleName)
        }
    }

    private func applyShield(data: Data?, name: String?) {
        guard let data else { return }
        do {
            let decodedSelection = try JSONDecoder().decode(FamilyActivitySelection.self, from: data)
            apply(selection: decodedSelection, activeRuleName: name ?? "自动恢复限制")
            lastErrorMessage = nil
        } catch {
            lastErrorMessage = "自动恢复限制失败：\(error.localizedDescription)"
        }
    }

    private func saveSelectionForExtensions(_ data: Data) {
        UserDefaults(suiteName: SharedScreenTimeKeys.appGroupIdentifier)?
            .set(data, forKey: SharedScreenTimeKeys.encodedSelection)
    }
}

private extension FamilyActivitySelection {
    var hasSelection: Bool {
        !applicationTokens.isEmpty || !categoryTokens.isEmpty || !webDomainTokens.isEmpty
    }
}
