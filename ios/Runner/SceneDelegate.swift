import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    // Register the orientation channel now that FlutterViewController is ready.
    if let windowScene = scene as? UIWindowScene,
       let controller = windowScene.windows.first?.rootViewController as? FlutterViewController,
       let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      appDelegate.setupOrientationChannel(with: controller)
    }
  }
}
