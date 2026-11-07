import SwiftUI

struct SettingsView: View {
    @Environment(LibraryModel.self) private var model
    @Environment(Preferences.self) private var preferences
    @Environment(\.copy) private var copy

    var body: some View {
        @Bindable var preferences = preferences

        Form {
            Picker(copy.languageTitle, selection: $preferences.language) {
                Text(copy.systemLanguage).tag(LanguageChoice.system)
                Text(copy.arabic).tag(LanguageChoice.arabic)
                Text(copy.english).tag(LanguageChoice.english)
            }
            Toggle(copy.hideSystemApps, isOn: $preferences.hideSystemApps)
            Section(copy.about) {
                HStack(alignment: .top, spacing: 12) {
                    BrandMark(size: 36)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(copy.tagline)
                            .font(.headline)
                        Text(copy.settingsSafety)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(versionText)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                Button(copy.refresh) {
                    Task { await model.refresh() }
                }
                .disabled(model.isScanning)
            }
        }
        .formStyle(.grouped)
        .frame(width: 540)
        .padding(.vertical, 8)
    }

    private var versionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        return "\(copy.appName) \(version)"
    }
}
