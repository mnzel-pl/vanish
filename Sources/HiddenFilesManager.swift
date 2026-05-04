import Foundation
import AppKit

struct HiddenItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let path: String
    let date: Date

    init(name: String, path: String) {
        self.id = UUID()
        self.name = name
        self.path = path
        self.date = Date()
    }
}

@MainActor
final class HiddenFilesManager: ObservableObject {
    @Published var showingHiddenFiles = false
    @Published var allItems: [HiddenItem] = []
    @Published var lastError: String?

    var recentItems: [HiddenItem] {
        Array(allItems.prefix(3))
    }

    private let storageKey = "Vanish.recentItems"

    init() {
        showingHiddenFiles = readCurrentFinderState()
        loadRecent()
    }

    // MARK: - Global Toggle

    func toggleHiddenFiles() {
        let newState = !showingHiddenFiles
        let script = """
            defaults write com.apple.finder AppleShowAllFiles -bool \(newState) && killall Finder
            """
        run(script) { [weak self] success in
            guard let self, success else { return }
            self.showingHiddenFiles = newState
        }
    }

    // MARK: - Hide / Unhide

    func hideItems(at urls: [URL]) {
        for url in urls {
            let path = url.path(percentEncoded: false)
            run("chflags hidden \(shellEscape(path))") { [weak self] success in
                guard let self else { return }
                if success {
                    let item = HiddenItem(name: url.lastPathComponent, path: path)
                    self.allItems.insert(item, at: 0)
                    self.saveRecent()
                    self.lastError = nil
                } else {
                    self.lastError = "Failed to hide \"\(url.lastPathComponent)\". Check Full Disk Access in System Settings > Privacy & Security."
                }
            }
        }
    }

    func unhide(_ item: HiddenItem) {
        run("chflags nohidden \(shellEscape(item.path))") { [weak self] success in
            guard let self else { return }
            if success {
                self.allItems.removeAll { $0.id == item.id }
                self.saveRecent()
                self.lastError = nil
            } else {
                self.lastError = "Failed to unhide \"\(item.name)\". The file may have been moved or deleted."
            }
        }
    }

    // MARK: - Helpers

    private func readCurrentFinderState() -> Bool {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        task.arguments = ["read", "com.apple.finder", "AppleShowAllFiles"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        try? task.run()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return output == "1" || output.lowercased() == "true"
    }

    private func run(_ command: String, completion: @escaping @MainActor (Bool) -> Void) {
        Task.detached {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/bin/zsh")
            task.arguments = ["-c", command]
            task.standardOutput = Pipe()
            task.standardError = Pipe()
            try? task.run()
            task.waitUntilExit()
            let success = task.terminationStatus == 0
            await completion(success)
        }
    }

    private func shellEscape(_ path: String) -> String {
        "'" + path.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    // MARK: - Persistence

    private func saveRecent() {
        if let data = try? JSONEncoder().encode(allItems) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadRecent() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let items = try? JSONDecoder().decode([HiddenItem].self, from: data) else { return }
        allItems = items
    }
}
