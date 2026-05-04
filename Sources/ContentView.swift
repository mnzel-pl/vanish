import SwiftUI

struct ContentView: View {
    @ObservedObject var manager: HiddenFilesManager
    let dropPanel: DropPanelController

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            toggleSection
            Divider()
            dropZone
            Divider()
            recentSection
            Divider()
            supportSection
        }
        .padding(.vertical, 8)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Image(systemName: "eye.slash.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Vanish")
                .font(.headline)
            Spacer()
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Toggle

    private var toggleSection: some View {
        HStack {
            Image(systemName: manager.showingHiddenFiles ? "eye.fill" : "eye.slash")
                .foregroundStyle(manager.showingHiddenFiles ? .blue : .secondary)
                .frame(width: 20)
            Text("Hidden Files")
            Spacer()
            Toggle("", isOn: Binding(
                get: { manager.showingHiddenFiles },
                set: { _ in manager.toggleHiddenFiles() }
            ))
            .toggleStyle(.switch)
            .controlSize(.small)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Drop Zone

    private var dropZone: some View {
        VStack(spacing: 6) {
            Text("Drop Zone")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                dropPanel.show()
            } label: {
                Label("Open Drop Zone", systemImage: "arrow.down.doc.fill")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            .buttonStyle(.bordered)

            Text("Opens a floating window you can drag files onto")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Recent Items

    private var recentSection: some View {
        VStack(spacing: 6) {
            Text("Recently Hidden")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if manager.recentItems.isEmpty {
                Text("No recent items")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, minHeight: 32)
            } else {
                ForEach(manager.recentItems) { item in
                    HStack(spacing: 8) {
                        Image(systemName: "doc.fill")
                            .foregroundStyle(.secondary)
                            .frame(width: 16)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(item.name)
                                .font(.callout)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Text(item.path)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        Spacer()
                        Button("Unhide") {
                            manager.unhide(item)
                        }
                        .controlSize(.small)
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 2)
                }
            }

            if manager.allItems.count > 3 {
                Button {
                    HistoryWindowController.shared.show(manager: manager)
                } label: {
                    Text("Show All (\(manager.allItems.count))")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
                .padding(.top, 4)
            }

            if let error = manager.lastError {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Support

    private var supportSection: some View {
        VStack(spacing: 8) {
            Text("If this tool helps your workflow, consider supporting its development.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                if let url = URL(string: "https://example.com/support") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                Label("Support the Project", systemImage: "heart.fill")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
