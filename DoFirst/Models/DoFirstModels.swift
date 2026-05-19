import Foundation
import SwiftData

enum FocusRuleType: String, Codable, CaseIterable, Identifiable {
    case focusUnlock
    case scheduledBlock
    case bedtimeProtection

    var id: String { rawValue }

    var title: String {
        switch self {
        case .focusUnlock:
            "专注解锁"
        case .scheduledBlock:
            "固定时间段封锁"
        case .bedtimeProtection:
            "睡前保护"
        }
    }

    var systemImage: String {
        switch self {
        case .focusUnlock:
            "timer"
        case .scheduledBlock:
            "calendar.badge.clock"
        case .bedtimeProtection:
            "moon.zzz"
        }
    }
}

enum UnlockTokenStatus: String, Codable, CaseIterable, Identifiable {
    case available
    case used
    case expired

    var id: String { rawValue }
}

enum UserGoalType: String, Codable, CaseIterable, Identifiable {
    case study
    case work
    case sleepEarlier
    case reduceShortVideos

    var id: String { rawValue }

    var title: String {
        switch self {
        case .study:
            "学习时少刷手机"
        case .work:
            "工作时更专注"
        case .sleepEarlier:
            "晚上早点睡"
        case .reduceShortVideos:
            "减少短视频时间"
        }
    }
}

@Model
final class FocusRule {
    @Attribute(.unique) var id: UUID
    var name: String
    var typeRawValue: String
    var weekdaysRawValue: String
    var startHour: Int?
    var startMinute: Int?
    var endHour: Int?
    var endMinute: Int?
    var isEnabled: Bool
    var allowsEmergencyUnlock: Bool
    var sendsReminder: Bool
    var appSelectionProfileID: UUID?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        type: FocusRuleType,
        weekdays: [Int] = [2, 3, 4, 5, 6],
        startTime: DateComponents? = nil,
        endTime: DateComponents? = nil,
        isEnabled: Bool = true,
        allowsEmergencyUnlock: Bool = true,
        sendsReminder: Bool = true,
        appSelectionProfileID: UUID? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.typeRawValue = type.rawValue
        self.weekdaysRawValue = weekdays.sorted().map(String.init).joined(separator: ",")
        self.startHour = startTime?.hour
        self.startMinute = startTime?.minute
        self.endHour = endTime?.hour
        self.endMinute = endTime?.minute
        self.isEnabled = isEnabled
        self.allowsEmergencyUnlock = allowsEmergencyUnlock
        self.sendsReminder = sendsReminder
        self.appSelectionProfileID = appSelectionProfileID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var type: FocusRuleType {
        get { FocusRuleType(rawValue: typeRawValue) ?? .focusUnlock }
        set {
            typeRawValue = newValue.rawValue
            updatedAt = .now
        }
    }

    var weekdays: [Int] {
        get {
            weekdaysRawValue
                .split(separator: ",")
                .compactMap { Int($0) }
                .filter { (1...7).contains($0) }
        }
        set {
            weekdaysRawValue = newValue.sorted().map(String.init).joined(separator: ",")
            updatedAt = .now
        }
    }

    var startTime: DateComponents? {
        guard let startHour, let startMinute else { return nil }
        return DateComponents(hour: startHour, minute: startMinute)
    }

    var endTime: DateComponents? {
        guard let endHour, let endMinute else { return nil }
        return DateComponents(hour: endHour, minute: endMinute)
    }

    var scheduleDescription: String {
        switch type {
        case .focusUnlock:
            return "完成 25 分钟专注后解锁 15 分钟"
        case .scheduledBlock, .bedtimeProtection:
            guard let startTime, let endTime else { return "未设置时间段" }
            return "\(Self.format(time: startTime)) - \(Self.format(time: endTime))"
        }
    }

    var weekdayDescription: String {
        let labels = [1: "周日", 2: "周一", 3: "周二", 4: "周三", 5: "周四", 6: "周五", 7: "周六"]
        let days = weekdays
        if Set(days) == Set(1...7) {
            return "每天"
        }
        if Set(days) == Set([2, 3, 4, 5, 6]) {
            return "工作日"
        }
        return days.compactMap { labels[$0] }.joined(separator: "、")
    }

    private static func format(time: DateComponents) -> String {
        let hour = time.hour ?? 0
        let minute = time.minute ?? 0
        return String(format: "%02d:%02d", hour, minute)
    }
}

@Model
final class AppSelectionProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var selectedTokensData: Data
    var applicationCount: Int
    var categoryCount: Int
    var webDomainCount: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        selectedTokensData: Data = Data(),
        applicationCount: Int = 0,
        categoryCount: Int = 0,
        webDomainCount: Int = 0,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.selectedTokensData = selectedTokensData
        self.applicationCount = applicationCount
        self.categoryCount = categoryCount
        self.webDomainCount = webDomainCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var summary: String {
        let parts = [
            applicationCount > 0 ? "\(applicationCount) 个 App" : nil,
            categoryCount > 0 ? "\(categoryCount) 个类别" : nil,
            webDomainCount > 0 ? "\(webDomainCount) 个网站" : nil
        ].compactMap { $0 }
        return parts.isEmpty ? "尚未选择限制对象" : parts.joined(separator: "、")
    }

    var hasSelection: Bool {
        applicationCount + categoryCount + webDomainCount > 0
    }
}

@Model
final class FocusSession {
    @Attribute(.unique) var id: UUID
    var taskName: String
    var startedAt: Date
    var endedAt: Date?
    var plannedMinutes: Int
    var completed: Bool
    var rewardMinutes: Int

    init(
        id: UUID = UUID(),
        taskName: String,
        startedAt: Date = .now,
        endedAt: Date? = nil,
        plannedMinutes: Int = 25,
        completed: Bool = false,
        rewardMinutes: Int = 15
    ) {
        self.id = id
        self.taskName = taskName
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.plannedMinutes = plannedMinutes
        self.completed = completed
        self.rewardMinutes = rewardMinutes
    }
}

@Model
final class UnlockToken {
    @Attribute(.unique) var id: UUID
    var minutes: Int
    var createdAt: Date
    var expiresAt: Date?
    var usedAt: Date?
    var statusRawValue: String
    var sourceFocusSessionID: UUID?

    init(
        id: UUID = UUID(),
        minutes: Int,
        createdAt: Date = .now,
        expiresAt: Date? = Calendar.current.date(byAdding: .day, value: 1, to: .now),
        usedAt: Date? = nil,
        status: UnlockTokenStatus = .available,
        sourceFocusSessionID: UUID? = nil
    ) {
        self.id = id
        self.minutes = minutes
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.usedAt = usedAt
        self.statusRawValue = status.rawValue
        self.sourceFocusSessionID = sourceFocusSessionID
    }

    var status: UnlockTokenStatus {
        get { UnlockTokenStatus(rawValue: statusRawValue) ?? .available }
        set { statusRawValue = newValue.rawValue }
    }
}

@Model
final class EmergencyUnlock {
    @Attribute(.unique) var id: UUID
    var usedAt: Date
    var minutes: Int
    var reason: String?

    init(id: UUID = UUID(), usedAt: Date = .now, minutes: Int = 5, reason: String? = nil) {
        self.id = id
        self.usedAt = usedAt
        self.minutes = minutes
        self.reason = reason
    }
}

@Model
final class DailyStats {
    @Attribute(.unique) var id: UUID
    var date: Date
    var focusMinutes: Int
    var sessionsCompleted: Int
    var unlockMinutes: Int
    var emergencyCount: Int
    var shieldTriggerCount: Int

    init(
        id: UUID = UUID(),
        date: Date = Calendar.current.startOfDay(for: .now),
        focusMinutes: Int = 0,
        sessionsCompleted: Int = 0,
        unlockMinutes: Int = 0,
        emergencyCount: Int = 0,
        shieldTriggerCount: Int = 0
    ) {
        self.id = id
        self.date = date
        self.focusMinutes = focusMinutes
        self.sessionsCompleted = sessionsCompleted
        self.unlockMinutes = unlockMinutes
        self.emergencyCount = emergencyCount
        self.shieldTriggerCount = shieldTriggerCount
    }
}

@Model
final class UserGoal {
    @Attribute(.unique) var id: UUID
    var typeRawValue: String
    var targetFocusMinutes: Int
    var targetSleepHour: Int?
    var targetSleepMinute: Int?

    init(
        id: UUID = UUID(),
        type: UserGoalType,
        targetFocusMinutes: Int = 75,
        targetSleepTime: DateComponents? = nil
    ) {
        self.id = id
        self.typeRawValue = type.rawValue
        self.targetFocusMinutes = targetFocusMinutes
        self.targetSleepHour = targetSleepTime?.hour
        self.targetSleepMinute = targetSleepTime?.minute
    }

    var type: UserGoalType {
        get { UserGoalType(rawValue: typeRawValue) ?? .study }
        set { typeRawValue = newValue.rawValue }
    }

    var targetSleepTime: DateComponents? {
        guard let targetSleepHour, let targetSleepMinute else { return nil }
        return DateComponents(hour: targetSleepHour, minute: targetSleepMinute)
    }
}

struct DailyStatsSnapshot {
    let focusMinutes: Int
    let completedSessions: Int
    let unlockMinutes: Int
    let emergencyUnlocks: Int
    let shieldTriggers: Int
    let streakDays: Int
}

extension Sequence where Element == FocusSession {
    func completedToday(calendar: Calendar = .current) -> [FocusSession] {
        filter { session in
            session.completed && calendar.isDateInToday(session.startedAt)
        }
    }
}
