import AppKit
import SwiftUI

final class DropPanelController {
    private var panel: NSPanel?
    private let manager: HiddenFilesManager

    init(manager: HiddenFilesManager) {
        self.manager = manager
    }

    @MainActor
    func show() {
        if let existing = panel, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 200),
            styleMask: [.titled, .closable, .nonactivatingPanel, .hudWindow],
            backing: .buffered,
            defer: false
        )
        panel.title = "Vanish — Drop to Hide"
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = true
        panel.hidesOnDeactivate = false
        panel.becomesKeyOnlyIfNeeded = true
        panel.center()

        let dropView = DropPanelView(manager: manager) {
            panel.close()
        }
        panel.contentView = NSHostingView(rootView: dropView)

        panel.makeKeyAndOrderFront(nil)
        self.panel = panel
    }
}

private struct DropPanelView: View {
    let manager: HiddenFilesManager
    let onDone: () -> Void
    @State private var isTargeted = false
    @State private var message: String?

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2.5, dash: [10, 5]))
                    .foregroundStyle(isTargeted ? Color.blue : Color.gray.opacity(0.4))
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isTargeted ? Color.blue.opacity(0.1) : Color.clear)
                    )

                VStack(spacing: 8) {
                    Image(systemName: "arrow.down.doc.fill")
                        .font(.largeTitle)
                        .foregroundStyle(isTargeted ? .blue : .secondary)
                    Text("Drop files here to hide them")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
                handleDrop(providers)
            }

            if let message {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.green)
                    .transition(.opacity)
            }
        }
        .padding(16)
        .frame(width: 280, height: 200)
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        guard !providers.isEmpty else { return false }
        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { data, _ in
                guard let data = data as? Data,
                      let urlString = String(data: data, encoding: .utf8),
                      let url = URL(string: urlString) else { return }
                Task { @MainActor in
                    manager.hideItems(at: [url])
                    message = "Hidden!"
                    try? await Task.sleep(for: .seconds(1))
                    onDone()
                }
            }
        }
        return true
    }
}
