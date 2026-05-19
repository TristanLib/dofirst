import Foundation

enum DailyStatsCalculator {
    static func snapshot(
        sessions: [FocusSession],
        tokens: [UnlockToken],
        emergencyUnlocks: [EmergencyUnlock],
        storedStats: [DailyStats],
        calendar: Calendar = .current
    ) -> DailyStatsSnapshot {
        let completedToday = sessions.filter { session in
            session.completed && calendar.isDateInToday(session.startedAt)
        }
        let usedTokensToday = tokens.filter { token in
            token.status == .used && token.usedAt.map { calendar.isDateInToday($0) } == true
        }
        let todayEmergency = emergencyUnlocks.filter { calendar.isDateInToday($0.usedAt) }
        let storedToday = storedStats.first { calendar.isDateInToday($0.date) }

        return DailyStatsSnapshot(
            focusMinutes: completedToday.reduce(0) { $0 + $1.plannedMinutes },
            completedSessions: completedToday.count,
            unlockMinutes: usedTokensToday.reduce(0) { $0 + $1.minutes } + todayEmergency.reduce(0) { $0 + $1.minutes },
            emergencyUnlocks: todayEmergency.count,
            shieldTriggers: storedToday?.shieldTriggerCount ?? 0,
            streakDays: streakDays(from: sessions, calendar: calendar)
        )
    }

    static func streakDays(from sessions: [FocusSession], calendar: Calendar = .current) -> Int {
        let completedDays = Set(
            sessions
                .filter(\.completed)
                .map { calendar.startOfDay(for: $0.startedAt) }
        )
        var streak = 0
        var cursor = calendar.startOfDay(for: .now)

        while completedDays.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }
            cursor = previous
        }

        return streak
    }
}
