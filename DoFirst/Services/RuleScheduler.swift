import DeviceActivity
import Foundation

enum RuleSchedulerError: LocalizedError {
    case missingSchedule

    var errorDescription: String? {
        switch self {
        case .missingSchedule:
            "规则缺少开始或结束时间。"
        }
    }
}

struct RuleScheduler {
    private let center = DeviceActivityCenter()

    func schedule(rule: FocusRule) throws {
        guard rule.isEnabled else { return }
        guard let start = rule.startTime, let end = rule.endTime else {
            if rule.type == .focusUnlock {
                return
            }
            throw RuleSchedulerError.missingSchedule
        }

        let crossesMidnight = Self.minutes(from: end) <= Self.minutes(from: start)

        for weekday in rule.weekdays {
            var intervalStart = start
            intervalStart.weekday = weekday

            var intervalEnd = end
            intervalEnd.weekday = crossesMidnight ? Self.nextWeekday(after: weekday) : weekday

            let schedule = DeviceActivitySchedule(
                intervalStart: intervalStart,
                intervalEnd: intervalEnd,
                repeats: true,
                warningTime: rule.sendsReminder ? DateComponents(minute: 30) : nil
            )

            try center.startMonitoring(
                DeviceActivityName("\(rule.id.uuidString)-\(weekday)"),
                during: schedule
            )
        }
    }

    func stop(rule: FocusRule) {
        let activityNames = rule.weekdays.map { DeviceActivityName("\(rule.id.uuidString)-\($0)") }
        center.stopMonitoring(activityNames)
    }

    func stopAll() {
        center.stopMonitoring()
    }

    private static func minutes(from components: DateComponents) -> Int {
        (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }

    private static func nextWeekday(after weekday: Int) -> Int {
        weekday == 7 ? 1 : weekday + 1
    }
}
