import ClinerCore
import SwiftUI

struct DetailView: View {
    @Environment(LibraryModel.self) private var model
    @Environment(\.copy) private var copy

    var body: some View {
        @Bindable var model = model

        Group {
            if let app = model.selectedApp {
                appDetail(app)
            } else {
                ContentUnavailableView {
                    Label(copy.chooseTitle, systemImage: "square.grid.2x2")
                } description: {
                    Text(copy.chooseDetail)
                        .frame(maxWidth: 420)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $model.askToConfirm) {
            if let app = model.selectedApp, !app.isProtected {
                ConfirmTrashSheet(app: app)
            }
        }
    }

    private func appDetail(_ app: InstalledApp) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let notice = model.notice, !model.askToConfirm {
                    NoticeBanner(notice: notice) {
                        model.notice = nil
                    }
                }
                DetailHeader(app: app, isRunning: model.isRunning(app))
                if !model.permissionBannerDismissed && !model.accessDenied.isEmpty && !app.isProtected {
                    PermissionBanner {
                        SystemSettingsLink.openFullDiskAccess()
                    } onDismiss: {
                        model.permissionBannerDismissed = true
                    }
                }
                stats(app)
                if app.isProtected {
                    protectedCard
                } else {
                    BundleToggle(app: app)
                    if model.isLoadingLeftovers && model.leftoverRows.isEmpty {
                        HStack(spacing: 8) {
                            ProgressView().controlSize(.small)
                            Text(copy.scanningRelated)
                                .foregroundStyle(.secondary)
                        }
                    }
                    leftoverSections
                }
            }
            .padding(24)
            .frame(maxWidth: 920, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(headerWash)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ActionBar(app: app)
        }
    }

    private func stats(_ app: InstalledApp) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: copy.appSize, value: copy.bytes(app.sizeBytes), systemImage: "macwindow")
            StatCard(title: copy.relatedSize, value: copy.bytes(model.relatedBytes()), systemImage: "externaldrive")
            StatCard(title: copy.selectedSpace, value: copy.bytes(model.selectedBytes()), systemImage: "trash")
        }
    }

    @ViewBuilder
    private var leftoverSections: some View {
        let strong = model.leftoverRows.filter { $0.match.reason.isStrong }
        let weak = model.leftoverRows.filter { !$0.match.reason.isStrong }
        if !strong.isEmpty {
            LeftoverSection(
                title: copy.relatedTitle,
                detail: nil,
                rows: strong,
                onSelectAll: { model.setStrongSelection(true) },
                onSelectNone: { model.setStrongSelection(false) }
            )
        }
        if !weak.isEmpty {
            LeftoverSection(
                title: copy.reviewTitle,
                detail: copy.reviewDetail,
                rows: weak,
                onSelectAll: { model.setWeakSelection(true) },
                onSelectNone: { model.setWeakSelection(false) }
            )
        }
        if !model.isLoadingLeftovers && strong.isEmpty && weak.isEmpty {
            Text(copy.noLeftovers)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var protectedCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.title3)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 4) {
                Text(copy.protectedTitle)
                    .font(.headline)
                Text(copy.protectedDetail)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    private var headerWash: some View {
        LinearGradient(
            colors: [Theme.accent.opacity(0.10), Theme.teal.opacity(0.04), Color.clear],
            startPoint: .topLeading,
            endPoint: .center
        )
        .ignoresSafeArea()
    }
}

private struct DetailHeader: View {
    var app: InstalledApp
    var isRunning: Bool
    @Environment(\.copy) private var copy

    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            AppIconView(path: app.path, size: 76)
                .shadow(color: .black.opacity(0.16), radius: 10, y: 4)
            VStack(alignment: .leading, spacing: 8) {
                Text(app.name)
                    .font(.system(size: 30, weight: .semibold))
                    .lineLimit(2)
                HStack(spacing: 8) {
                    if !app.version.isEmpty {
                        CapsuleBadge(text: app.version)
                    }
                    if app.isAppleApp {
                        CapsuleBadge(text: copy.appleBadge)
                    }
                    if app.isProtected {
                        CapsuleBadge(text: copy.systemBadge, tint: .secondary)
                    }
                    if isRunning {
                        HStack(spacing: 6) {
                            Circle().fill(Color.green).frame(width: 7, height: 7)
                            Text(copy.running)
                                .font(.caption.weight(.medium))
                        }
                    }
                }
                if !app.bundleIdentifier.isEmpty {
                    Text(app.bundleIdentifier)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
                Button(copy.showInFinder) {
                    SystemSettingsLink.reveal(app.path)
                }
                .buttonStyle(.link)
            }
            Spacer(minLength: 0)
        }
    }
}

private struct BundleToggle: View {
    var app: InstalledApp
    @Environment(LibraryModel.self) private var model
    @Environment(\.copy) private var copy

    var body: some View {
        @Bindable var model = model
        Toggle(isOn: $model.removeBundle) {
            HStack(spacing: 12) {
                Image(systemName: "macwindow")
                    .foregroundStyle(Theme.accent)
                    .frame(width: 22)
                VStack(alignment: .leading, spacing: 2) {
                    Text(copy.appBundle)
                    Text(shortenedPath(app.path))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                Spacer(minLength: 8)
                Text(copy.bytes(app.sizeBytes))
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .toggleStyle(.checkbox)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
}

private struct LeftoverSection: View {
    var title: String
    var detail: String?
    var rows: [LeftoverRow]
    var onSelectAll: () -> Void
    var onSelectNone: () -> Void
    @Environment(LibraryModel.self) private var model
    @Environment(\.copy) private var copy

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    if let detail {
                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 12)
                Button(copy.selectAll, action: onSelectAll)
                    .buttonStyle(.link)
                Button(copy.selectNone, action: onSelectNone)
                    .buttonStyle(.link)
            }
            VStack(spacing: 4) {
                ForEach(rows) { row in
                    LeftoverToggle(row: row)
                }
            }
        }
    }
}

private struct LeftoverToggle: View {
    var row: LeftoverRow
    @Environment(LibraryModel.self) private var model
    @Environment(\.copy) private var copy

    var body: some View {
        let selected = Binding(
            get: { model.leftoverRows.first { $0.id == row.id }?.isSelected ?? false },
            set: { model.setLeftoverSelected(row.id, $0) }
        )
        Toggle(isOn: selected) {
            HStack(spacing: 12) {
                Image(systemName: row.match.category.symbolName)
                    .foregroundStyle(row.match.reason.isStrong ? Theme.accent : .secondary)
                    .frame(width: 22)
                VStack(alignment: .leading, spacing: 2) {
                    Text(row.match.name)
                        .lineLimit(1)
                    Text(shortenedPath(row.match.path))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text(copy.categoryTitle(row.match.category))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                Spacer(minLength: 8)
                Text(copy.bytes(row.match.sizeBytes))
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .toggleStyle(.checkbox)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .help(row.match.path)
    }
}

private struct ActionBar: View {
    var app: InstalledApp
    @Environment(LibraryModel.self) private var model
    @Environment(\.copy) private var copy

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(alignment: .center, spacing: 16) {
                if app.isProtected {
                    Label(copy.protectedDetail, systemImage: "lock.fill")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    Spacer()
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(copy.selectionSummary(count: model.selectedCount, bytes: selectedSize))
                            .font(.headline.monospacedDigit())
                        Text(copy.trashFootnote)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        model.requestTrashConfirmation()
                    } label: {
                        Label(copy.moveToTrash, systemImage: "trash")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.danger)
                    .controlSize(.large)
                    .disabled(!model.canTrash)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(.bar)
    }

    private var selectedSize: String? {
        guard let bytes = model.selectedBytes() else { return nil }
        return copy.bytes(bytes)
    }
}

private extension LibraryModel {
    var selectedCount: Int { itemsToTrash.count }
}
