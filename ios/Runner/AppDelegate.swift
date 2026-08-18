import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  private let CHANNEL = "com.presencelabsllp.focuskeyapp/app_lock"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let methodChannel = FlutterMethodChannel(
      name: CHANNEL,
      binaryMessenger: engineBridge.pluginRegistry as! FlutterBinaryMessenger
    )

    methodChannel.setMethodCallHandler { [weak self] call, result in
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
        AppLockManager.shared.presentAppPicker(modeId: modeId, from: rootVC) { count in
          result(count)
        }

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

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}