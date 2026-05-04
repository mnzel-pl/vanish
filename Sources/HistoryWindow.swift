import AppKit
import SwiftUI

@MainActor
final class HistoryWindowController {
    static let shared = HistoryWindowController()
    private var window: NSWindow?

    func show(manager: HiddenFilesManager) {
        if let existing = window, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let view = HistoryView(manager: manager)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 500),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Vanish — Hidden Files"
        window.minSize = NSSize(width: 360, height: 300)
        window.contentView = NSHostingView(rootView: view)
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.window = window
    }
}

private struct HistoryView: View {
    @ObservedObject var manager: HiddenFilesManager
    @State private var search = ""
    @State private var selection = Set<UUID>()

    private var filtered: [HiddenItem] {
        if search.isEmpty { return manager.allItems }
        let query = search.lowercased()
        return manager.allItems.filter {
            $0.name.lowercased().contains(query) || $0.path.lowercased().contains(query)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            if filtered.isEmpty {
                ContentUnavailableView.search(text: search)
                    .frame(maxHeight: .infinity)
            } else {
                list
            }
        }
        .frame(minWidth: 360, minHeight: 300)
    }

    private var toolbar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search files...", text: $search)
                    .textFieldStyle(.plain)
                if !search.isEmpty {
                    Button {
                        search = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(6)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

            if !selection.isEmpty {
                Button("Unhide \(selection.count)") {
                    let items = manager.allItems.filter { selection.contains($0.id) }
                    for item in items {
                        manager.unhide(item)
                    }
                    selection.removeAll()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            Text("\(filtered.count) files")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
    }

    private var list: some View {
        List(filtered, selection: $selection) { item in
            HStack(spacing: 10) {
                Image(systemName: "doc.fill")
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.body)
                        .lineLimit(1)
                    Text(item.path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                Spacer()
                Text(item.date, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Button("Unhide") {
                    manager.unhide(item)
                    selection.remove(item.id)
                }
                .controlSize(.small)
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 2)
        }
    }
}
