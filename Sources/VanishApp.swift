import SwiftUI

@main
struct VanishApp: App {
    @StateObject private var manager = HiddenFilesManager()

    var body: some Scene {
        MenuBarExtra {
            ContentView(manager: manager, dropPanel: DropPanelController(manager: manager))
                .frame(width: 300)
        } label: {
            Image(systemName: "eye.slash.fill")
        }
        .menuBarExtraStyle(.window)
    }
}
