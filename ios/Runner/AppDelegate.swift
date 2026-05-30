import FirebaseMessaging
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register plugins eagerly so Firebase Messaging swizzle installs before any push tap.
    GeneratedPluginRegistrant.register(with: self)
    // Explicit APNs registration refreshes the FCM→APNs token mapping on every launch.
    application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Ensures SystemChrome.setPreferredOrientations works correctly on iPad.
  // FlutterAppDelegate stores the preferred mask; we just forward it.
  override func application(
    _ application: UIApplication,
    supportedInterfaceOrientationsFor window: UIWindow?
  ) -> UIInterfaceOrientationMask {
    return super.application(application, supportedInterfaceOrientationsFor: window)
  }
}
