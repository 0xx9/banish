import ClinerCore
import SwiftUI

struct SidebarView: View {
    @Environment(LibraryModel.self) private var model
    @Environment(Preferences.self) private var preferences
    @Environment(\.copy) private var copy

    var body: some View {
        @Bindable var model = model

        Group {
            if model.isScanning && model.applications.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                    Text(copy.scanning)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if visibleApps.isEmpty {
                ContentUnavailableView {
                    Label(copy.noResults, systemImage: "magnifyingglass")
                } description: {
                    Text(model.unreadableApplicationDirectories.isEmpty ? copy.noResultsDetail : copy.applicationsUnreadable)
                }
            } else {
                List(visibleApps, selection: $model.selectedID) { app in
                    AppRow(app: app, isRunning: model.isRunning(app))
                        .tag(app.id)
                        .contextMenu {
                            Button(copy.showInFinder) {
                                SystemSettingsLink.reveal(app.path)
                            }
                            if !app.isProtected {
                                Button(copy.moveToTrash) {
                                    model.selectedID = app.id
                                    model.requestTrashConfirmation()
                                }
                            }
                        }
                }
                .listStyle(.sidebar)
            }
        }
        .navigationSplitViewColumnWidth(min: 280, ideal: 330, max: 420)
        .searchable(text: $model.query, placement: .sidebar, prompt: copy.searchPrompt)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 8) {
                BrandMark(size: 18)
                Text(copy.appsFooter(visibleApps.count))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
    }

    private var visibleApps: [InstalledApp] {
        let query = model.query.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = model.applications.filter { app in
            if preferences.hideSystemApps && app.isProtected {
                return false
            }
            guard !query.isEmpty else { return true }
            if app.name.localizedCaseInsensitiveContains(query) || app.bundleIdentifier.localizedCaseInsensitiveContains(query) {
                return true
            }
            return app.matchNames.contains { $0.localizedCaseInsensitiveContains(query) }
        }
        switch model.sort {
        case .name:
            return filtered.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .size:
            return filtered.sorted { ($0.sizeBytes ?? -1) > ($1.sizeBytes ?? -1) }
        }
    }
}

private struct AppRow: View {
    var app: InstalledApp
    var isRunning: Bool
    @Environment(\.copy) private var copy

    var body: some View {
        HStack(spacing: 10) {
            AppIconView(path: app.path, size: 32)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(app.name)
                        .lineLimit(1)
                    if isRunning {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                            .accessibilityLabel(copy.running)
                    }
                    if app.isProtected {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            Text(copy.bytes(app.sizeBytes))
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private var subtitle: String {
        if app.isProtected { return copy.systemBadge }
        if !app.version.isEmpty { return app.version }
        return app.bundleIdentifier
    }
}
