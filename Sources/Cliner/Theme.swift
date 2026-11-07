import ClinerCore
import SwiftUI

enum Theme {
    static let accent = Color(red: 0.20, green: 0.44, blue: 0.96)
    static let teal = Color(red: 0.02, green: 0.62, blue: 0.60)
    static let warning = Color(red: 0.84, green: 0.46, blue: 0.08)
    static let success = Color(red: 0.12, green: 0.58, blue: 0.36)
    static let danger = Color(red: 0.82, green: 0.20, blue: 0.22)
}

extension LeftoverCategory {
    var symbolName: String {
        switch self {
        case .applicationSupport: "externaldrive"
        case .caches: "memorychip"
        case .preferences: "gearshape"
        case .logs: "doc.text"
        case .savedState: "clock.arrow.circlepath"
        case .containers: "shippingbox"
        case .groupContainers: "square.stack.3d.up"
        case .webData: "globe"
        case .launchAgents: "bolt"
        case .launchDaemons: "bolt.shield"
        case .scripts: "applescript"
        case .developer: "hammer"
        }
    }
}

func shortenedPath(_ path: String) -> String {
    let home = FileManager.default.homeDirectoryForCurrentUser.path
    if path.hasPrefix(home) {
        return "~" + path.dropFirst(home.count)
    }
    return path
}
