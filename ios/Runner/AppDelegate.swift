import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  private let CHANNEL = "com.presencelabsllp.focuskeyapp/app_lock"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
        setupMethodChannel(messenger: controller.binaryMessenger)
    }

    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if let messenger = engineBridge.pluginRegistry as? FlutterBinaryMessenger {
        setupMethodChannel(messenger: messenger)
    }
  }

  private func setupMethodChannel(messenger: FlutterBinaryMessenger) {
    let methodChannel = FlutterMethodChannel(
      name: CHANNEL,
      binaryMessenger: messenger
    )

    methodChannel.setMethodCallHandler { call, result in
      guard let rootVC = UIApplication.shared.connectedScenes
        .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
        .first else {
        result(FlutterError(code: "NO_ROOT_VC", message: "Root view controller not found", details: nil))
        return
      }

      switch call.method {
      case "isAuthorized":
        result(AppLockManager.shared.isAuthorized())

      case "requestAuthorization":
        AppLockManager.shared.requestAuthorization { success, error in
          if success {
            result(true)
          } else {
            result(FlutterError(code: "AUTH_FAILED", message: error, details: nil))
          }
        }

      case "presentAppPicker":
        guard let args = call.arguments as? [String: Any],
              let modeId = args["modeId"] as? String else {
          result(FlutterError(code: "MISSING_ARG", message: "modeId required", details: nil))
          return
        }
        AppLockManager.shared.presentAppPicker(modeId: modeId, from: rootVC) { appsCount, categoriesCount in
          result([
            "apps": appsCount,
            "categories": categoriesCount
          ])
        }

      case "getSelectedCounts":
        guard let args = call.arguments as? [String: Any],
              let modeId = args["modeId"] as? String else {
          result(FlutterError(code: "MISSING_ARG", message: "modeId required", details: nil))
          return
        }
        result(AppLockManager.shared.getSelectedCounts(modeId: modeId))

      case "applyShield":
        guard let args = call.arguments as? [String: Any],
              let modeId = args["modeId"] as? String else {
          result(FlutterError(code: "MISSING_ARG", message: "modeId required", details: nil))
          return
        }
        AppLockManager.shared.applyShield(modeId: modeId)
        result(nil)

      case "removeShield":
        AppLockManager.shared.removeShield()
        result(nil)

      case "cacheReminderMessage":
        if let args = call.arguments as? [String: Any],
           let message = args["message"] as? String {
          AppLockManager.shared.cacheReminderMessage(message)
        }
        result(nil)

      case "scheduleBreakEnd":
        guard let args = call.arguments as? [String: Any],
              let modeId = args["modeId"] as? String,
              let endMs = (args["endEpochMs"] as? NSNumber)?.doubleValue else {
          result(FlutterError(code: "MISSING_ARG", message: "modeId/endEpochMs required", details: nil))
          return
        }
        result(AppLockManager.shared.scheduleBreakEnd(modeId: modeId, endEpochMs: endMs))

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
