import ClinerCore
import SwiftUI

struct ConfirmTrashSheet: View {
    var app: InstalledApp
    @Environment(LibraryModel.self) private var model
    @Environment(\.copy) private var copy
    @Environment(\.dismiss) private var dismiss
    @State private var items: [TrashItem] = []
    @State private var sizeText = ""
    @State private var working = false
    @State private var errorText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 14) {
                AppIconView(path: app.path, size: 56)
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(copy.confirmTitle)
                        .font(.title3.weight(.semibold))
                    Text(app.name)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Text(copy.confirmSummary(count: items.count, size: sizeText))
            Text(copy.confirmSafe)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if model.isRunning(app) {
                Label(copy.confirmQuit, systemImage: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundStyle(Theme.warning)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if app.path.hasPrefix("/Applications/") {
                Label(copy.passwordHint, systemImage: "lock.fill")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if app.isAppleApp {
                Label(copy.confirmApple, systemImage: "apple.logo")
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(items.prefix(10), id: \.path) { item in
                        Text(shortenedPath(item.path))
                            .font(.system(.caption, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .help(item.path)
                    }
                    if items.count > 10 {
                        Text(copy.andMore(items.count - 10))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 180)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.primary.opacity(0.04))
            )

            if let errorText {
                Text(errorText)
                    .font(.callout)
                    .foregroundStyle(Theme.danger)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack {
                Spacer()
                Button(copy.cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                    .disabled(working)
                Button {
                    Task { await confirm() }
                } label: {
                    if working {
                        ProgressView().controlSize(.small)
                    } else {
                        Text(copy.moveToTrash)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.danger)
                .disabled(working || items.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 520)
        .onAppear {
            items = model.itemsToTrash
            if let bytes = model.selectedBytes() {
                sizeText = copy.bytes(bytes)
            } else {
                sizeText = copy.calculating
            }
        }
    }

    private func confirm() async {
        working = true
        let succeeded = await model.performTrash(adminPrompt: copy.adminPrompt)
        working = false
        if succeeded {
            dismiss()
        } else if let notice = model.notice {
            errorText = copy.noticeText(notice)
        } else {
            errorText = copy.confirmFailed
        }
    }
}
