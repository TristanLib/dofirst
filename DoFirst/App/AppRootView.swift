import SwiftUI

struct AppRootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var screenTime = ScreenTimeController()
    @State private var focusTimer = FocusTimerModel()

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                AppShellView()
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .environment(screenTime)
        .environment(focusTimer)
        .tint(AppTheme.primary)
        .task {
            screenTime.refreshAuthorizationStatus()
            await screenTime.scheduleNotificationAuthorization()
        }
    }
}

