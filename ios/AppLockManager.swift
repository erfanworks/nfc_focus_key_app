import Foundation
import FamilyControls
import ManagedSettings
import SwiftUI
import UIKit

class AppLockManager {

    static let shared = AppLockManager()

    private let store = ManagedSettingsStore()
    private let appGroupId = "group.com.presencelabsllp.focuskeyapp"

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
            let selection = loadSelection(for: modeId)
            store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
            store.shield.applicationCategories = selection.categoryTokens.isEmpty
                ? nil
                : ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
            store.application.denyAppRemoval = true
        }

        func removeShield() {
            store.shield.applications = nil
            store.shield.applicationCategories = nil
            store.application.denyAppRemoval = false
        }

    func cacheReminderMessage(_ message: String) {
        defaults.set(message, forKey: "cached_reminder_message")
    }

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