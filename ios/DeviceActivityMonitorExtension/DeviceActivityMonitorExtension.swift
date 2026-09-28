//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Re-applies the shield when a break ends, even if the Flutter app is
//  suspended or killed (the Dart Timer cannot fire in that state).
//
//  Kept intentionally tiny: DeviceActivityMonitor extensions run under a very
//  small memory budget, so no logging frameworks, no networking, no caching.
//

import DeviceActivity
import ManagedSettings
import FamilyControls
import Foundation

final class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    // MARK: - Shared contract with AppLockManager (keep in sync)

    private enum Contract {
        static let appGroupId = "group.com.presencelabsllp.focuskeyapp"
        static let breakActivityName = "focuskey.break_end"
        static let pendingModeKey = "break_pending_mode_id"
        static let pendingEndKey = "break_pending_end_epoch_ms"
        /// Ignore callbacks that arrive clearly BEFORE the break's real end
        /// (e.g. side effects of start/stopMonitoring). Being a few seconds
        /// early is harmless; being ignored is not.
        static let earlyToleranceMs: Double = 10_000

        static func selectionKey(_ modeId: String) -> String {
            "locked_apps_selection_\(modeId)"
        }
    }

    // MARK: - Callbacks

    /// Fires at (intervalEnd - warningTime). AppLockManager configures the
    /// schedule so this moment is exactly the break's end time.
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        reapplyShieldIfBreakEnded(for: activity)
    }

    /// Safety net: if the warning callback was missed, the interval end
    /// still re-locks (later, but never forgotten). Idempotent.
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        reapplyShieldIfBreakEnded(for: activity)
    }

    // MARK: - Core

    private func reapplyShieldIfBreakEnded(for activity: DeviceActivityName) {
        guard activity.rawValue == Contract.breakActivityName,
              let defaults = UserDefaults(suiteName: Contract.appGroupId),
              let modeId = defaults.string(forKey: Contract.pendingModeKey)
        else { return }

        // No pending break (already handled, cancelled, or user unlocked via
        // NFC) -> do nothing. This is what prevents re-locking a user who
        // legitimately unlocked mid-break.
        let endMs = defaults.double(forKey: Contract.pendingEndKey)
        guard endMs > 0 else { return }

        let nowMs = Date().timeIntervalSince1970 * 1000
        guard nowMs >= endMs - Contract.earlyToleranceMs else { return }

        guard let data = defaults.data(forKey: Contract.selectionKey(modeId)),
              let selection = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
        else { return }

        // Same logic as AppLockManager.applyShield(modeId:).
        // Default store: shared with the host app on iOS 16+.
        let store = ManagedSettingsStore()
        store.shield.applications = selection.applicationTokens.isEmpty
            ? nil
            : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)

        // Mark handled so later callbacks (e.g. the real intervalDidEnd
        // 15 min after start) are no-ops.
        defaults.removeObject(forKey: Contract.pendingModeKey)
        defaults.removeObject(forKey: Contract.pendingEndKey)
    }
}