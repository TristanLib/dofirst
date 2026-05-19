import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(ScreenTimeController.self) private var screenTime
    @Environment(FocusTimerModel.self) private var focusTimer
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \AppSelectionProfile.createdAt, order: .reverse) private var profiles: [AppSelectionProfile]
    @Query(sort: \FocusSession.startedAt, order: .reverse) private var sessions: [FocusSession]
    @Query(sort: \UnlockToken.createdAt, order: .reverse) private var tokens: [UnlockToken]
    @Query(sort: \EmergencyUnlock.usedAt, order: .reverse) private var emergencyUnlocks: [EmergencyUnlock]
    @Query(sort: \DailyStats.date, order: .reverse) private var storedStats: [DailyStats]
    @Query(sort: \FocusRule.createdAt) private var rules: [FocusRule]

    @State private var taskName = ""
    @State private var emergencyReason = ""
    @State private var showEmergencyConfirmation = false

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

    private var availableTokens: [UnlockToken] {
        tokens.filter { token in
            token.status == .available && (token.expiresAt.map { $0 > .now } ?? true)
        }
    }

    private var snapshot: DailyStatsSnapshot {
        DailyStatsCalculator.snapshot(
            sessions: sessions,
            tokens: tokens,
            emergencyUnlocks: emergencyUnlocks,
            storedStats: storedStats
        )
    }

    private var hasEmergencyAvailableToday: Bool {
        !emergencyUnlocks.contains { Calendar.current.isDateInToday($0.usedAt) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                statusCard
                focusCard
                if !availableTokens.isEmpty {
                    availableRewardsCard
                }
                todayProgress
                emergencyUnlockCard
            }
            .padding()
        }
        .background(AppTheme.pageBackground)
        .task {
            SeedData.ensureDefaults(in: modelContext, existingRules: rules)
        }
        .confirmationDialog("使用今天的紧急解锁？", isPresented: $showEmergencyConfirmation, titleVisibility: .visible) {
            Button("解锁 5 分钟") {
                useEmergencyUnlock()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("这会解锁 5 分钟，今天只能使用 1 次。")
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(statusTitle)
                        .font(.title2.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(statusSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: statusSymbol)
                    .font(.title2)
                    .foregroundStyle(statusTint)
                    .frame(width: 44, height: 44)
                    .background(statusTint.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))
            }

            if let profile = activeProfile {
                Label(profile.summary, systemImage: "app.badge")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Button {
                    screenTime.applyShield(using: activeProfile)
                } label: {
                    Label("开始限制", systemImage: "lock")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!hasSavedSelection)

                Button {
                    screenTime.clearShield()
                } label: {
                    Label("解除", systemImage: "lock.open")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            if let error = screenTime.lastErrorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 8))
    }

    private var focusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("专注计时", subtitle: "完成 25 分钟专注后获得 15 分钟娱乐时间。")

            switch focusTimer.state {
            case .idle:
                TextField("例如：复习英语、写报告", text: $taskName)
                    .textFieldStyle(.roundedBorder)

                Button {
                    focusTimer.start(taskName: taskName)
                } label: {
                    Label("开始 25 分钟专注", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

            case .running, .paused:
                timerDisplay
                HStack(spacing: 12) {
                    Button {
                        focusTimer.state == .running ? focusTimer.pause() : focusTimer.resume()
                    } label: {
                        Label(focusTimer.state == .running ? "暂停" : "继续", systemImage: focusTimer.state == .running ? "pause.fill" : "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(focusTimer.state == .running && !focusTimer.canPause)

                    Button(role: .destructive) {
                        focusTimer.abandon()
                    } label: {
                        Label("放弃", systemImage: "xmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

            case .finished:
                VStack(alignment: .leading, spacing: 12) {
                    Label("你完成了 25 分钟专注。", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.success)
                    Text("已获得 15 分钟娱乐时间。")
                        .font(.headline)

                    HStack(spacing: 12) {
                        Button {
                            if let token = focusTimer.claimReward(in: modelContext) {
                                use(token: token)
                            }
                        } label: {
                            Label("立即解锁", systemImage: "lock.open")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            _ = focusTimer.claimReward(in: modelContext)
                        } label: {
                            Label("稍后使用", systemImage: "clock")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 8))
    }

    private var timerDisplay: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(.quaternary, lineWidth: 12)
                Circle()
                    .trim(from: 0, to: focusTimer.progress)
                    .stroke(AppTheme.primary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 4) {
                    Text(focusTimer.formattedRemainingTime)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                    Text(focusTimer.taskName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(width: 220, height: 220)
            .frame(maxWidth: .infinity)
        }
    }

    private var todayProgress: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader("今日进度")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MetricTile(title: "专注总时长", value: "\(snapshot.focusMinutes) 分钟", symbolName: "timer", tint: AppTheme.primary)
                MetricTile(title: "完成次数", value: "\(snapshot.completedSessions)", symbolName: "checkmark.circle", tint: AppTheme.success)
                MetricTile(title: "解锁娱乐", value: "\(snapshot.unlockMinutes) 分钟", symbolName: "lock.open", tint: AppTheme.accent)
                MetricTile(title: "连续达标", value: "\(snapshot.streakDays) 天", symbolName: "flame", tint: AppTheme.warning)
            }
        }
        .padding()
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 8))
    }

    private var availableRewardsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader("可用娱乐时间", subtitle: "稍后使用的奖励会保留到这里。")

            ForEach(availableTokens) { token in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(token.minutes) 分钟娱乐时间")
                            .font(.headline)
                        if let expiresAt = token.expiresAt {
                            Text("有效期至 \(expiresAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Button("使用") {
                        use(token: token)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!hasSavedSelection)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 8))
    }

    private var emergencyUnlockCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader("紧急解锁", subtitle: "每天 1 次，每次 5 分钟，会进入日报。")
            TextField("原因，可选", text: $emergencyReason)
                .textFieldStyle(.roundedBorder)
            Button {
                showEmergencyConfirmation = true
            } label: {
                Label(hasEmergencyAvailableToday ? "使用紧急解锁" : "今天已使用", systemImage: "exclamationmark.triangle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(!hasEmergencyAvailableToday || !hasSavedSelection)
        }
        .padding()
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 8))
    }

    private var statusTitle: String {
        if !hasSavedSelection {
            return "未选择限制对象"
        }
        if let end = screenTime.temporaryUnlockEndsAt, end > .now {
            return "已解锁娱乐"
        }
        if screenTime.isShieldActive {
            return "正在限制中"
        }
        if rules.contains(where: \.isEnabled) {
            return "规则已准备好"
        }
        return "未启用规则"
    }

    private var statusSubtitle: String {
        if !hasSavedSelection {
            return "请先在规则页选择并保存要限制的 App、类别或网站。"
        }
        if let end = screenTime.temporaryUnlockEndsAt, end > .now {
            return "娱乐时间到 \(end.formatted(date: .omitted, time: .shortened)) 结束。"
        }
        if screenTime.isShieldActive {
            return "当前限制对象：\(screenTime.lastAppliedProfileName ?? activeProfile?.name ?? "默认限制对象")。"
        }
        return "先完成重要任务，再有节制地使用娱乐 App。"
    }

    private var statusSymbol: String {
        screenTime.isShieldActive ? "lock.shield" : "sparkles"
    }

    private var statusTint: Color {
        screenTime.isShieldActive ? AppTheme.warning : AppTheme.primary
    }

    private func use(token: UnlockToken) {
        guard hasSavedSelection else {
            screenTime.lastErrorMessage = "请先在规则页保存一个限制对象。"
            return
        }
        token.status = .used
        token.usedAt = .now
        try? modelContext.save()
        screenTime.unlockEntertainment(minutes: token.minutes, profile: activeProfile)
    }

    private func useEmergencyUnlock() {
        guard hasSavedSelection else {
            screenTime.lastErrorMessage = "请先在规则页保存一个限制对象。"
            return
        }
        let unlock = EmergencyUnlock(reason: emergencyReason.isEmpty ? nil : emergencyReason)
        modelContext.insert(unlock)
        try? modelContext.save()
        UserDefaults(suiteName: SharedScreenTimeKeys.appGroupIdentifier)?
            .set(Date().timeIntervalSince1970, forKey: SharedScreenTimeKeys.emergencyUnlockRequestedAt)
        screenTime.unlockEntertainment(minutes: unlock.minutes, profile: activeProfile)
        emergencyReason = ""
    }
}
