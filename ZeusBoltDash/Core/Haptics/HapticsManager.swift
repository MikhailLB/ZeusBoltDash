import UIKit

enum HapticsManager {
    private static let light  = UIImpactFeedbackGenerator(style: .light)
    private static let medium = UIImpactFeedbackGenerator(style: .medium)
    private static let heavy  = UIImpactFeedbackGenerator(style: .heavy)
    private static let notif  = UINotificationFeedbackGenerator()

    static var enabled = true

    static func parry() {
        guard enabled else { return }
        medium.impactOccurred(intensity: 0.7)
    }

    static func perfectParry() {
        guard enabled else { return }
        heavy.impactOccurred(intensity: 1.0)
    }

    static func hit() {
        guard enabled else { return }
        notif.notificationOccurred(.warning)
    }

    static func gameOver() {
        guard enabled else { return }
        notif.notificationOccurred(.error)
    }

    static func blessingCollect() {
        guard enabled else { return }
        light.impactOccurred(intensity: 0.5)
    }

    static func ultimateActivate() {
        guard enabled else { return }
        heavy.impactOccurred(intensity: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            heavy.impactOccurred(intensity: 0.8)
        }
    }
}
