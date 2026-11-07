import Foundation
import Observation

enum LanguageChoice: String, CaseIterable, Identifiable, Hashable, Sendable {
    case system
    case arabic
    case english

    var id: String { rawValue }
}

@MainActor
@Observable
final class Preferences {
    var hideSystemApps: Bool {
        didSet { UserDefaults.standard.set(hideSystemApps, forKey: Key.hideSystemApps) }
    }

    var language: LanguageChoice {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Key.language) }
    }

    init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Key.hideSystemApps) == nil {
            hideSystemApps = true
        } else {
            hideSystemApps = defaults.bool(forKey: Key.hideSystemApps)
        }
        language = LanguageChoice(rawValue: defaults.string(forKey: Key.language) ?? "") ?? .system
    }

    private enum Key {
        static let hideSystemApps = "hideSystemApps"
        static let language = "language"
    }
}
