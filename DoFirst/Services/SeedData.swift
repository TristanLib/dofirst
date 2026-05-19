import Foundation
import SwiftData

enum SeedData {
    @MainActor
    static func ensureDefaults(in context: ModelContext, existingRules: [FocusRule]) {
        guard existingRules.isEmpty else { return }

        let focusUnlock = FocusRule(
            name: "专注后解锁娱乐",
            type: .focusUnlock,
            weekdays: Array(1...7)
        )

        let workBlock = FocusRule(
            name: "工作日上午封锁",
            type: .scheduledBlock,
            weekdays: [2, 3, 4, 5, 6],
            startTime: DateComponents(hour: 9, minute: 0),
            endTime: DateComponents(hour: 12, minute: 0)
        )

        let bedtime = FocusRule(
            name: "睡前保护",
            type: .bedtimeProtection,
            weekdays: Array(1...7),
            startTime: DateComponents(hour: 23, minute: 0),
            endTime: DateComponents(hour: 7, minute: 0)
        )

        context.insert(focusUnlock)
        context.insert(workBlock)
        context.insert(bedtime)
        try? context.save()
    }
}

