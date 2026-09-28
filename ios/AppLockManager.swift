import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity   // [BREAK-END] added
import SwiftUI
import UIKit

class AppLockManager {

    static let shared = AppLockManager()

    private let store = ManagedSettingsStore()
    private let appGroupId = "group.com.presencelabsllp.focuskeyapp"

    // [BREAK-END] Contract shared with DeviceActivityMonitorExtension (keep in sync).
    private let breakActivityName = DeviceActivityName("focuskey.break_end")
    private let pendingBreakModeKey = "break_pending_mode_id"
    private let pendingBreakEndKey = "break_pending_end_epoch_ms"
    private let activityCenter = DeviceActivityCenter()
    /// Apple's minimum monitoring interval is 15 minutes (+5s safety margin so
    /// second-rounding can never trigger MonitoringError.intervalTooShort).
    private let minMonitoringInterval: TimeInterval = 15 * 60 + 5

    private func selectionKey(for modeId: String) -> String {
        "locked_apps_selection_\(modeId)"
    }

    private var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupId) ?? .standard
    }

    func requestAuthorization(completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                DispatchQueue.main.async { completion(true, nil) }
            } catch {
                DispatchQueue.main.async { completion(false, error.localizedDescription) }
            }
        }
    }

    func isAuthorized() -> Bool {
        AuthorizationCenter.shared.authorizationStatus == .approved
    }

    func presentAppPicker(modeId: String, from rootViewController: UIViewController, completion: @escaping (Int, Int) -> Void) {
        let existingSelection = loadSelection(for: modeId)

        var isDisposed = false

        let pickerView = AppPickerView(selection: existingSelection) { [weak self] newSelection in
            guard let self = self, !isDisposed else { return }
            isDisposed = true

            self.saveSelection(newSelection, for: modeId)

            // Return results immediately to Flutter so the loader stops
            completion(newSelection.applicationTokens.count, newSelection.categoryTokens.count)

            rootViewController.dismiss(animated: true)
        }

        let hostingController = UIHostingController(rootView: pickerView)
        rootViewController.present(hostingController, animated: true)
    }

    func getSelectedCounts(modeId: String) -> [String: Int] {
        let selection = loadSelection(for: modeId)
        return [
            "apps": selection.applicationTokens.count,
            "categories": selection.categoryTokens.count
        ]
    }

    func applyShield(modeId: String) {
        // [BREAK-END] An explicit shield change from Dart supersedes any pending break-end.
        clearBreakEnd()

        let selection = loadSelection(for: modeId)
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
        store.application.denyAppRemoval = true
    }

    func removeShield() {
        // [BREAK-END] Covers NFC unlock mid-break: the extension must never re-lock afterwards.
        clearBreakEnd()

        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.application.denyAppRemoval = false
    }

    func cacheReminderMessage(_ message: String) {
        defaults.set(message, forKey: "cached_reminder_message")
    }

    // MARK: - [BREAK-END] OS-level re-lock at break end

    /// Asks iOS (via DeviceActivityMonitor extension) to re-apply the shield at
    /// `endEpochMs`, independent of the Flutter process being alive.
    ///
    /// Apple enforces a 15-minute minimum schedule length, so a shorter break
    /// uses a >=15 min interval plus `warningTime`: the extension then receives
    /// `intervalWillEndWarning` exactly at the break's end.
    ///
    /// Best-effort by design: returns false (and leaves the existing Dart
    /// resume/timer logic as the only mechanism) if scheduling isn't possible.
    @discardableResult
    func scheduleBreakEnd(modeId: String, endEpochMs: Double) -> Bool {
        let now = Date()
        let breakEnd = Date(timeIntervalSince1970: endEpochMs / 1000)
        guard !modeId.isEmpty, breakEnd.timeIntervalSince(now) > 1 else { return false }

        // Cancel any previous pending break first (flags cleared before stop,
        // so a side-effect callback from stopMonitoring is a no-op).
        clearBreakEnd()

        let calendar = Calendar.current
        let intervalStart = now.addingTimeInterval(-1) // already in progress -> starts immediately
        let intervalEnd = max(breakEnd, now.addingTimeInterval(minMonitoringInterval))

        // Time-of-day (hour/minute/second) components cannot express an
        // interval that crosses midnight -> skip and rely on the Dart fallback.
        guard calendar.isDate(intervalStart, inSameDayAs: intervalEnd) else { return false }

        // warningTime is measured backwards from intervalEnd, so
        // (intervalEnd - warningTime) == breakEnd.
        let warningSeconds = Int(intervalEnd.timeIntervalSince(breakEnd).rounded())
        let warningTime: DateComponents? = warningSeconds > 0
            ? DateComponents(minute: warningSeconds / 60, second: warningSeconds % 60)
            : nil

        // Persist BEFORE scheduling so an immediate callback always finds it.
        defaults.set(modeId, forKey: pendingBreakModeKey)
        defaults.set(endEpochMs, forKey: pendingBreakEndKey)
        defaults.synchronize()

        let units: Set<Calendar.Component> = [.hour, .minute, .second]
        let schedule = DeviceActivitySchedule(
            intervalStart: calendar.dateComponents(units, from: intervalStart),
            intervalEnd: calendar.dateComponents(units, from: intervalEnd),
            repeats: false,
            warningTime: warningTime
        )

        do {
            try activityCenter.startMonitoring(breakActivityName, during: schedule)
            return true
        } catch {
            print("[BreakEnd] startMonitoring failed: \(error)")
            clearBreakEnd()
            return false
        }
    }

    /// Cancels a pending break-end re-lock (safe to call anytime).
    func clearBreakEnd() {
        defaults.removeObject(forKey: pendingBreakModeKey)
        defaults.removeObject(forKey: pendingBreakEndKey)
        activityCenter.stopMonitoring([breakActivityName])
    }

    // MARK: - Selection persistence

    private func saveSelection(_ selection: FamilyActivitySelection, for modeId: String) {
        if let data = try? PropertyListEncoder().encode(selection) {
            defaults.set(data, forKey: selectionKey(for: modeId))
            defaults.synchronize()
        }
    }

    private func loadSelection(for modeId: String) -> FamilyActivitySelection {
        if let data = defaults.data(forKey: selectionKey(for: modeId)),
           let decoded = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data) {
            return decoded
        }
        return FamilyActivitySelection()
    }
}
