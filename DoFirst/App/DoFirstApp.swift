import SwiftData
import SwiftUI

@main
struct DoFirstApp: App {
    private let modelContainer: ModelContainer = {
        let schema = Schema([
            FocusRule.self,
            AppSelectionProfile.self,
            FocusSession.self,
            UnlockToken.self,
            EmergencyUnlock.self,
            DailyStats.self,
            UserGoal.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create SwiftData container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(modelContainer)
    }
}

