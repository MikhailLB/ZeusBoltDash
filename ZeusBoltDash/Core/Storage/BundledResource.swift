import UIKit

/// Xcode's "Copy Bundle Resources" phase flattens files into the bundle root,
/// so resources must be looked up by name (the original `Resources/...` folder
/// structure is not preserved). We still probe known subdirectories as a
/// fallback in case the project is ever switched to folder references.
enum Res {
    private static let subdirs = [
        "Resources/sprites/heroes",
        "Resources/sprites/arenas",
        "Resources/sprites/threats",
        "Resources/sprites/pickups",
        "Resources/branding",
        "Resources/splash",
        "Resources/typography",
    ]

    static func url(_ name: String, _ ext: String) -> URL? {
        if let u = Bundle.main.url(forResource: name, withExtension: ext) { return u }
        for sub in subdirs {
            if let u = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: sub) {
                return u
            }
        }
        return nil
    }

    static func image(_ name: String) -> UIImage? {
        guard let u = url(name, "webp"), let data = try? Data(contentsOf: u) else { return nil }
        return UIImage(data: data)
    }
}
