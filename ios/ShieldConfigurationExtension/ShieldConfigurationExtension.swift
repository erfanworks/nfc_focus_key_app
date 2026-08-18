//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Created by Erfan Hasnat on 18/8/26.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private let appGroupId = "group.com.presencelabsllp.focuskeyapp"

    private func buildShieldConfiguration() -> ShieldConfiguration {
        let defaults = UserDefaults(suiteName: appGroupId)
        let reminderMessage = defaults?.string(forKey: "cached_reminder_message")
            ?? "This app is locked."

        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterialDark,
            backgroundColor: UIColor.black.withAlphaComponent(0.9),
            icon: UIImage(named: "AppIcon"),
            title: ShieldConfiguration.Label(text: "App Locked", color: .white),
            subtitle: ShieldConfiguration.Label(
                text: "\(reminderMessage)\n\nOpen Focus Key and scan your NFC key to unlock.",
                color: .lightGray
            ),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Got it", color: .white),
            primaryButtonBackgroundColor: UIColor.systemBlue,
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Close", color: .lightGray)
        )
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        buildShieldConfiguration()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        buildShieldConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        buildShieldConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        buildShieldConfiguration()
    }
}