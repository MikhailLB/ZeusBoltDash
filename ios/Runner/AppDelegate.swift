import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Called after the scene connects and the FlutterViewController is ready.
  func setupOrientationChannel(with controller: FlutterViewController) {
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
  }
}
