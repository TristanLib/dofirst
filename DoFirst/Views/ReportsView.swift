import SwiftData
import SwiftUI

struct ReportsView: View {
    @Query(sort: \FocusSession.startedAt, order: .reverse) private var sessions: [FocusSession]
    @Query(sort: \UnlockToken.createdAt, order: .reverse) private var tokens: [UnlockToken]
    @Query(sort: \EmergencyUnlock.usedAt, order: .reverse) private var emergencyUnlocks: [EmergencyUnlock]
    @Query(sort: \DailyStats.date, order: .reverse) private var storedStats: [DailyStats]

    private var snapshot: DailyStatsSnapshot {
        DailyStatsCalculator.snapshot(
            sessions: sessions,
            tokens: tokens,
            emergencyUnlocks: emergencyUnlocks,
            storedStats: storedStats
        )
    }

    private var weeklyFocusMinutes: Int {
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfYear, for: .now)
        return sessions
            .filter { session in
                session.completed && week?.contains(session.startedAt) == true
            }
            .reduce(0) { $0 + $1.plannedMinutes }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                summaryCard
                todayGrid
                weeklyCard
                screenTimeReportNote
            }
            .padding()
        }
        .background(AppTheme.pageBackground)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("你今天完成了 \(snapshot.completedSessions) 次专注，总计 \(snapshot.focusMinutes) 分钟。")
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            Text("已实际解锁 \(snapshot.unlockMinutes) 分钟娱乐时间，使用紧急解锁 \(snapshot.emergencyUnlocks) 次。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 8))
    }

    private var todayGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader("今日报告")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MetricTile(title: "专注时长", value: "\(snapshot.focusMinutes) 分钟", symbolName: "timer", tint: AppTheme.primary)
                MetricTile(title: "完成率", value: snapshot.completedSessions > 0 ? "100%" : "0%", symbolName: "checkmark.seal", tint: AppTheme.success)
                MetricTile(title: "娱乐解锁", value: "\(snapshot.unlockMinutes) 分钟", symbolName: "lock.open", tint: AppTheme.accent)
                MetricTile(title: "拦截次数", value: "\(snapshot.shieldTriggers)", symbolName: "hand.raised", tint: AppTheme.warning)
            }
        }
        .padding()
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 8))
    }

    private var weeklyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader("本周报告", subtitle: "先用本地专注和解锁数据稳定呈现，真机接入 DeviceActivityReport 后可补充系统屏幕时间。")

            HStack(spacing: 12) {
                MetricTile(title: "本周专注", value: "\(weeklyFocusMinutes) 分钟", symbolName: "calendar", tint: AppTheme.primary)
                MetricTile(title: "连续达标", value: "\(snapshot.streakDays) 天", symbolName: "flame", tint: AppTheme.warning)
            }

            Text(weeklySummary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 8))
    }

    private var screenTimeReportNote: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("DeviceActivityReport 接线点", systemImage: "chart.bar.doc.horizontal")
                .font(.headline)
            Text("工程已包含 DeviceActivityMonitor 和 DeviceActivityReport 扩展；完整系统活动报告需要 Family Controls entitlement，并在真机授权后继续验证。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 8))
    }

    private var weeklySummary: String {
        if weeklyFocusMinutes == 0 {
            return "完成第一次专注后，这里会开始形成周趋势。"
        }
        if snapshot.streakDays >= 3 {
            return "你已经连续 \(snapshot.streakDays) 天达标，可以考虑给自己一个周末奖励。"
        }
        return "本周已经累计 \(weeklyFocusMinutes) 分钟，把专注解锁规则保持到第三天会更容易形成习惯。"
    }
}
