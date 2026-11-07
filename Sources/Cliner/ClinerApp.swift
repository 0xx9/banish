import SwiftUI

@main
struct ClinerApp: App {
    @State private var model = LibraryModel()
    @State private var preferences = Preferences()

    var body: some Scene {
        let copy = Copy(language: preferences.language)

        WindowGroup {
            ContentView()
                .environment(model)
                .clinerChrome(preferences)
                .frame(minWidth: 980, minHeight: 660)
        }
        .defaultSize(width: 1180, height: 760)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandMenu(copy.appName) {
                Button(copy.refresh) {
                    Task { await model.refresh() }
                }
                .keyboardShortcut("r", modifiers: .command)
                .disabled(model.isScanning)
                Button(copy.moveToTrash) {
                    model.requestTrashConfirmation()
                }
                .keyboardShortcut(.delete, modifiers: .command)
                .disabled(!model.canTrash)
            }
        }

        Settings {
            SettingsView()
                .environment(model)
                .clinerChrome(preferences)
        }
    }
}
