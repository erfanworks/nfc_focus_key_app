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

    func presentAppPicker(modeId: String, from rootViewController: UIViewController, completion: @escaping (Int) -> Void) {
        let existingSelection = loadSelection(for: modeId)
        let pickerView = AppPickerView(selection: existingSelection) { [weak self] newSelection in
            guard let self = self else { return }
            self.saveSelection(newSelection, for: modeId)
            rootViewController.dismiss(animated: true) {
                completion(newSelection.applicationTokens.count + newSelection.categoryTokens.count)
            }
        }
        let hostingController = UIHostingController(rootView: pickerView)
        rootViewController.present(hostingController, animated: true)
    }

    func applyShield(modeId: String) {
        let selection = loadSelection(for: modeId)
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
    }

    func removeShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }

    private func saveSelection(_ selection: FamilyActivitySelection, for modeId: String) {
        let defaults = UserDefaults(suiteName: appGroupId)
        if let data = try? PropertyListEncoder().encode(selection) {
            defaults?.set(data, forKey: selectionKey(for: modeId))
        }
    }

    private func loadSelection(for modeId: String) -> FamilyActivitySelection {
        let defaults = UserDefaults(suiteName: appGroupId)
        if let data = defaults?.data(forKey: selectionKey(for: modeId)),
           let decoded = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data) {
            return decoded
        }
        return FamilyActivitySelection()
    }
}