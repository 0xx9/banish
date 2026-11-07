import SwiftUI

struct ContentView: View {
    @Environment(LibraryModel.self) private var model
    @Environment(Preferences.self) private var preferences
    @Environment(\.copy) private var copy

    var body: some View {
        @Bindable var model = model
        @Bindable var preferences = preferences

        NavigationSplitView {
            SidebarView()
        } detail: {
            DetailView()
        }
        .navigationSplitViewStyle(.balanced)
        .navigationTitle(copy.appName)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                if model.isScanning {
                    ProgressView()
                        .controlSize(.small)
                        .help(copy.scanning)
                }
            }
            ToolbarItem {
                Menu {
                    Picker(copy.sort, selection: $model.sort) {
                        Text(copy.sortByName).tag(AppSort.name)
                        Text(copy.sortBySize).tag(AppSort.size)
                    }
                    .pickerStyle(.inline)
                    Divider()
                    Toggle(copy.hideSystemApps, isOn: $preferences.hideSystemApps)
                } label: {
                    Label(copy.viewOptions, systemImage: "line.3.horizontal.decrease.circle")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { await model.refresh() }
                } label: {
                    Label(copy.refresh, systemImage: "arrow.clockwise")
                }
                .disabled(model.isScanning)
            }
        }
        .task {
            guard !model.didStart else { return }
            model.didStart = true
            await model.refresh()
        }
        .task {
            await model.watchRunningApps()
        }
        .task(id: model.selectedID) {
            await model.loadLeftovers()
        }
        .task(id: model.notice) {
            guard case .success = model.notice else { return }
            try? await Task.sleep(for: .seconds(4))
            if case .success = model.notice {
                model.notice = nil
            }
        }
        .onChange(of: preferences.hideSystemApps) { _, hidden in
            guard hidden, let app = model.selectedApp, app.isProtected else { return }
            model.selectedID = model.applications.first { !$0.isProtected }?.id
        }
    }
}
