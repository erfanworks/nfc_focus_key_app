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
        AppLockManager.shared.presentAppPicker(from: rootVC) { count in
          result(count)
        }

      case "applyShield":
        AppLockManager.shared.applyShield()
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