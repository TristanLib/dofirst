import Foundation
import Observation
import SwiftData

enum FocusTimerState: Equatable {
    case idle
    case running
    case paused
    case finished
}

@MainActor
@Observable
final class FocusTimerModel {
    private var timer: Timer?
    private var startedAt: Date?

    var state: FocusTimerState = .idle
    var taskName: String = ""
    var plannedMinutes: Int = 25
    var rewardMinutes: Int = 15
    var remainingSeconds: Int = 25 * 60
    var canPause: Bool = true

    var progress: Double {
        let total = max(plannedMinutes * 60, 1)
        return 1 - (Double(remainingSeconds) / Double(total))
    }

    var formattedRemainingTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func start(taskName: String) {
        self.taskName = taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "专注任务" : taskName
        startedAt = .now
        remainingSeconds = plannedMinutes * 60
        canPause = true
        state = .running
        startTimer()
    }

    func pause() {
        guard state == .running, canPause else { return }
        timer?.invalidate()
        timer = nil
        canPause = false
        state = .paused
    }

    func resume() {
        guard state == .paused else { return }
        state = .running
        startTimer()
    }

    func abandon() {
        timer?.invalidate()
        timer = nil
        startedAt = nil
        taskName = ""
        remainingSeconds = plannedMinutes * 60
        canPause = true
        state = .idle
    }

    func claimReward(in context: ModelContext) -> UnlockToken? {
        guard state == .finished else { return nil }
        let session = FocusSession(
            taskName: taskName,
            startedAt: startedAt ?? .now,
            endedAt: .now,
            plannedMinutes: plannedMinutes,
            completed: true,
            rewardMinutes: rewardMinutes
        )
        let token = UnlockToken(minutes: rewardMinutes, sourceFocusSessionID: session.id)
        context.insert(session)
        context.insert(token)
        try? context.save()
        abandon()
        return token
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self else { return }
                guard self.remainingSeconds > 1 else {
                    self.remainingSeconds = 0
                    timer.invalidate()
                    self.timer = nil
                    self.state = .finished
                    return
                }
                self.remainingSeconds -= 1
            }
        }
    }
}
