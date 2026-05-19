import FamilyControls
import SwiftData
import SwiftUI

struct RulesView: View {
    @Environment(ScreenTimeController.self) private var screenTime
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \FocusRule.createdAt) private var rules: [FocusRule]
    @Query(sort: \AppSelectionProfile.createdAt, order: .reverse) private var profiles: [AppSelectionProfile]

    @State private var isPickerPresented = false
    @State private var isShowingEditor = false
    @State private var editingRule: FocusRule?
    @State private var profileName = "默认限制对象"
    @State private var schedulerMessage: String?

    private var activeProfile: AppSelectionProfile? {
        if let activeProfileID = screenTime.activeProfileID,
           let profile = profiles.first(where: { $0.id == activeProfileID }) {
            return profile
        }
        return profiles.first(where: { $0.hasSelection }) ?? profiles.first
    }

    private var hasSavedSelection: Bool {
        activeProfile?.hasSelection == true
    }

    var body: some View {
        List {
            appSelectionSection
            rulesSection
            schedulingSection
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.pageBackground)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    editingRule = nil
                    isShowingEditor = true
                } label: {
                    Label("新建规则", systemImage: "plus")
                }
            }
        }
        .task {
            SeedData.ensureDefaults(in: modelContext, existingRules: rules)
        }
        .sheet(isPresented: $isShowingEditor) {
            NavigationStack {
                RuleEditorView(rule: editingRule)
            }
        }
        .familyActivityPicker(
            isPresented: $isPickerPresented,
            selection: Binding(
                get: { screenTime.selection },
                set: { screenTime.selection = $0 }
            )
        )
    }

    private var appSelectionSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text(screenTime.selectionSummary)
                    .font(.headline)

                TextField("配置名称", text: $profileName)
                    .textFieldStyle(.roundedBorder)

                HStack(spacing: 12) {
                    Button {
                        isPickerPresented = true
                    } label: {
                        Label("选择", systemImage: "plus.app")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        _ = screenTime.saveCurrentSelection(named: profileName, in: modelContext)
                    } label: {
                        Label("保存", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.vertical, 6)

            ForEach(profiles) { profile in
                let isActive = activeProfile?.id == profile.id
                Button {
                    screenTime.loadSelection(from: profile)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.name)
                                .foregroundStyle(.primary)
                            Text(profile.summary)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: isActive ? "checkmark.circle.fill" : "chevron.right")
                            .font(.footnote)
                            .foregroundStyle(isActive ? AppTheme.success : Color.secondary)
                    }
                }
            }
            .onDelete { offsets in
                offsets.map { profiles[$0] }.forEach(modelContext.delete)
                try? modelContext.save()
            }

            if let error = screenTime.lastErrorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        } header: {
            Text("App / 类别 / 网站选择")
        } footer: {
            Text("Family Activity Picker 需要 Family Controls entitlement；模拟器可编译，真实选择和限制需要真机验证。")
        }
    }

    private var rulesSection: some View {
        Section {
            ForEach(rules) { rule in
                RuleRow(rule: rule) {
                    editingRule = rule
                    isShowingEditor = true
                }
            }
            .onDelete { offsets in
                offsets.map { rules[$0] }.forEach { rule in
                    RuleScheduler().stop(rule: rule)
                    modelContext.delete(rule)
                }
                try? modelContext.save()
            }
        } header: {
            Text("规则列表")
        }
    }

    private var schedulingSection: some View {
        Section {
            Button {
                screenTime.applyShield(using: activeProfile)
            } label: {
                Label("立即开始限制", systemImage: "lock")
            }
            .disabled(!hasSavedSelection)

            Button {
                screenTime.clearShield()
            } label: {
                Label("临时暂停限制", systemImage: "pause.circle")
            }

            Button {
                scheduleEnabledRules()
            } label: {
                Label("同步固定时间段规则", systemImage: "calendar.badge.clock")
            }

            if let schedulerMessage {
                Text(schedulerMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let error = screenTime.lastErrorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        } header: {
            Text("限制控制")
        }
    }

    private func scheduleEnabledRules() {
        let scheduler = RuleScheduler()
        var scheduledCount = 0
        scheduler.stopAll()

        for rule in rules where rule.isEnabled {
            do {
                try scheduler.schedule(rule: rule)
                if rule.type != .focusUnlock {
                    scheduledCount += 1
                }
            } catch {
                schedulerMessage = "\(rule.name)：\(error.localizedDescription)"
                return
            }
        }

        schedulerMessage = "已同步 \(scheduledCount) 条时间段规则。"
    }
}

private struct RuleRow: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var rule: FocusRule
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: rule.type.systemImage)
                .foregroundStyle(AppTheme.primary)
                .frame(width: 34, height: 34)
                .background(AppTheme.primary.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(rule.name)
                    .font(.headline)
                Text("\(rule.type.title) · \(rule.weekdayDescription) · \(rule.scheduleDescription)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Toggle("启用", isOn: $rule.isEnabled)
                .labelsHidden()
                .onChange(of: rule.isEnabled) { _, isEnabled in
                    rule.updatedAt = .now
                    try? modelContext.save()
                    if isEnabled {
                        try? RuleScheduler().schedule(rule: rule)
                    } else {
                        RuleScheduler().stop(rule: rule)
                    }
                }

            Button(action: onEdit) {
                Image(systemName: "pencil")
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
}

struct RuleEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let rule: FocusRule?

    @State private var name: String
    @State private var type: FocusRuleType
    @State private var weekdays: Set<Int>
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isEnabled: Bool
    @State private var allowsEmergencyUnlock: Bool
    @State private var sendsReminder: Bool

    init(rule: FocusRule?) {
        self.rule = rule
        _name = State(initialValue: rule?.name ?? "新的专注规则")
        _type = State(initialValue: rule?.type ?? .focusUnlock)
        _weekdays = State(initialValue: Set(rule?.weekdays ?? Array(1...7)))
        _startDate = State(initialValue: Self.date(from: rule?.startTime) ?? Self.date(hour: 9, minute: 0))
        _endDate = State(initialValue: Self.date(from: rule?.endTime) ?? Self.date(hour: 12, minute: 0))
        _isEnabled = State(initialValue: rule?.isEnabled ?? true)
        _allowsEmergencyUnlock = State(initialValue: rule?.allowsEmergencyUnlock ?? true)
        _sendsReminder = State(initialValue: rule?.sendsReminder ?? true)
    }

    var body: some View {
        Form {
            Section("基础") {
                TextField("规则名称", text: $name)
                Picker("规则类型", selection: $type) {
                    ForEach(FocusRuleType.allCases) { type in
                        Label(type.title, systemImage: type.systemImage)
                            .tag(type)
                    }
                }
                Toggle("启用规则", isOn: $isEnabled)
            }

            if type != .focusUnlock {
                Section("时间") {
                    weekdayPicker
                    DatePicker("开始时间", selection: $startDate, displayedComponents: .hourAndMinute)
                    DatePicker("结束时间", selection: $endDate, displayedComponents: .hourAndMinute)
                }
            }

            Section("选项") {
                Toggle("允许紧急解锁", isOn: $allowsEmergencyUnlock)
                Toggle("睡前 / 开始前提醒", isOn: $sendsReminder)
            }
        }
        .navigationTitle(rule == nil ? "新建规则" : "编辑规则")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    save()
                }
            }
        }
    }

    private var weekdayPicker: some View {
        let items = [(1, "日"), (2, "一"), (3, "二"), (4, "三"), (5, "四"), (6, "五"), (7, "六")]
        return HStack(spacing: 8) {
            ForEach(items, id: \.0) { item in
                let isSelected = weekdays.contains(item.0)
                Button {
                    if isSelected {
                        weekdays.remove(item.0)
                    } else {
                        weekdays.insert(item.0)
                    }
                } label: {
                    Text(item.1)
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 34, height: 34)
                        .foregroundStyle(isSelected ? .white : AppTheme.primary)
                        .background(isSelected ? AppTheme.primary : AppTheme.primary.opacity(0.12), in: Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let savedName = trimmedName.isEmpty ? type.title : trimmedName
        let start = Calendar.current.dateComponents([.hour, .minute], from: startDate)
        let end = Calendar.current.dateComponents([.hour, .minute], from: endDate)
        let savedWeekdays = weekdays.isEmpty ? Array(1...7) : Array(weekdays)

        if let rule {
            rule.name = savedName
            rule.type = type
            rule.weekdays = savedWeekdays
            rule.startHour = start.hour
            rule.startMinute = start.minute
            rule.endHour = end.hour
            rule.endMinute = end.minute
            rule.isEnabled = isEnabled
            rule.allowsEmergencyUnlock = allowsEmergencyUnlock
            rule.sendsReminder = sendsReminder
            rule.updatedAt = .now
        } else {
            let newRule = FocusRule(
                name: savedName,
                type: type,
                weekdays: savedWeekdays,
                startTime: start,
                endTime: end,
                isEnabled: isEnabled,
                allowsEmergencyUnlock: allowsEmergencyUnlock,
                sendsReminder: sendsReminder
            )
            modelContext.insert(newRule)
        }

        try? modelContext.save()
        dismiss()
    }

    private static func date(from components: DateComponents?) -> Date? {
        guard let components else { return nil }
        var today = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        today.hour = components.hour
        today.minute = components.minute
        return Calendar.current.date(from: today)
    }

    private static func date(hour: Int, minute: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? .now
    }
}
