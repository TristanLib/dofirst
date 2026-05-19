import ManagedSettings
import ManagedSettingsUI
import UIKit

final class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        makeConfiguration()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        makeConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration()
    }

    private func makeConfiguration() -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: UIColor.systemBackground,
            title: ShieldConfiguration.Label(
                text: "你正在保护自己的注意力",
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "先完成 25 分钟专注，再回来玩 15 分钟。",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "开始专注",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.0, green: 0.38, blue: 0.42, alpha: 1.0),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "稍后再说",
                color: .secondaryLabel
            )
        )
    }
}

