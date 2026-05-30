import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    _setupOrientationChannel()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ── Orientation channel ───────────────────────────────────────────────────
  // Flutter calls "setPortrait" / "setAll" to force rotation on iPad iOS 16+.
  private func _setupOrientationChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController
    else { return }

    let channel = FlutterMethodChannel(
      name: "zbd/orientation",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "setPortrait":
        self?._requestPortrait()
        result(nil)
      case "setAll":
        self?._requestAll()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func _requestPortrait() {
    if #available(iOS 16.0, *) {
      let scene = UIApplication.shared.connectedScenes
        .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
      scene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
      scene?.keyWindow?.rootViewController?
        .setNeedsUpdateOfSupportedInterfaceOrientations()
    } else {
      UIDevice.current.setValue(
        UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
      UIViewController.attemptRotationToDeviceOrientation()
    }
  }

  private func _requestAll() {
    if #available(iOS 16.0, *) {
      let scene = UIApplication.shared.connectedScenes
        .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
      scene?.requestGeometryUpdate(
        .iOS(interfaceOrientations: [.portrait, .landscapeLeft, .landscapeRight]))
      scene?.keyWindow?.rootViewController?
        .setNeedsUpdateOfSupportedInterfaceOrientations()
    }
    // Below iOS 16 — SystemChrome.setPreferredOrientations is enough.
  }

  // Ensures SystemChrome.setPreferredOrientations works on iPad.
  override func application(
    _ application: UIApplication,
    supportedInterfaceOrientationsFor window: UIWindow?
  ) -> UIInterfaceOrientationMask {
    return super.application(application, supportedInterfaceOrientationsFor: window)
  }
}
