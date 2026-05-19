import Foundation
import ManagedSettings

final class ShieldActionExtension: ShieldActionDelegate {
    override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handle(action: action, completionHandler: completionHandler)
    }

    override func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handle(action: action, completionHandler: completionHandler)
    }

    override func handle(
        action: ShieldAction,
        for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handle(action: action, completionHandler: completionHandler)
    }

    private func handle(action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        let defaults = UserDefaults(suiteName: SharedScreenTimeKeys.appGroupIdentifier)

        switch action {
        case .primaryButtonPressed:
            defaults?.set("startFocus", forKey: SharedScreenTimeKeys.lastShieldAction)
            completionHandler(.close)
        case .secondaryButtonPressed:
            defaults?.set("defer", forKey: SharedScreenTimeKeys.lastShieldAction)
            completionHandler(.defer)
        default:
            defaults?.set("unknown", forKey: SharedScreenTimeKeys.lastShieldAction)
            completionHandler(.close)
        }
    }
}

