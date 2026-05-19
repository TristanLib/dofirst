import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(ScreenTimeController.self) private var screenTime
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \FocusRule.createdAt) private var rules: [FocusRule]
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    var body: some View {
        List {
            authorizationSection
            ruleSwitchesSection
            privacySection
            resetSection
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.pageBackground)
    }

    private var authorizationSection: some View {
        Section("授权") {
            LabeledContent("Family Controls", value: screenTime.authorizationLabel)

            Button {
                Task { await screenTime.requestAuthorization() }
            } label: {
                Label("重新请求授权", systemImage: "hand.raised")
            }

            Button {
                screenTime.revokeAuthorization()
            } label: {
                Label("重置授权", systemImage: "arrow.counterclockwise")
            }
        }
    }

    private var ruleSwitchesSection: some View {
        Section("规则开关") {
            ForEach(rules) { rule in
                Toggle(rule.name, isOn: Binding(
                    get: { rule.isEnabled },
                    set: { isEnabled in
                        update(rule: rule, isEnabled: isEnabled)
                    }
                ))
            }
        }
    }

    private var privacySection: some View {
        Section("隐私说明") {
            Text("DoFirst 只保存系统提供的选择 token、规则、专注记录和解锁记录。App 选择由 FamilyControls 以隐私保护方式处理；没有 Family Controls entitlement 时，真机限制能力无法启用。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var resetSection: some View {
        Section("调试") {
            Button {
                screenTime.clearShield()
            } label: {
                Label("清除当前限制", systemImage: "lock.open")
            }

            Button(role: .destructive) {
                hasCompletedOnboarding = false
            } label: {
                Label("重新显示 Onboarding", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
    }

    private func update(rule: FocusRule, isEnabled: Bool) {
        rule.isEnabled = isEnabled
        rule.updatedAt = .now
        try? modelContext.save()

        if isEnabled {
            try? RuleScheduler().schedule(rule: rule)
        } else {
            RuleScheduler().stop(rule: rule)
        }
    }
}
