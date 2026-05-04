# Vanish 🫥

Vanish is a lightweight macOS menu bar utility designed to give you total control over hidden files. It combines a global toggle for Finder visibility with a "Drop Zone" that allows you to hide specific files and folders instantly.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS%2014.0+-lightgrey.svg)
![Swift](https://img.shields.io/badge/swift-5.9+-orange.svg)

## Features

- **Global Toggle:** Instantly show or hide all system-hidden files in Finder with a single click.
- **File-Specific Hiding:** Use the `chflags` system to make specific files or folders invisible, even when Finder visibility is toggled off.
- **Drop Zone:** A floating, always-on-top window. Just drag and drop any file to "vanish" it.
- **History & Search:** A dedicated history window tracks everything you've hidden, allowing you to search and unhide items later.
- **Menu Bar Native:** Lives in your menu bar for quick, non-intrusive access.

## How it Works

Vanish uses standard macOS system flags and defaults:
- **Global Toggle:** Modifies `com.apple.finder AppleShowAllFiles` and restarts Finder.
- **Specific Hiding:** Applies the `hidden` flag to files using `chflags`, which is the macOS native way to mark files as invisible to the UI.

## Requirements

- macOS 14.0 (Sonoma) or later.
- **Full Disk Access:** To hide/unhide files in protected system directories or external drives, Vanish requires Full Disk Access (Settings > Privacy & Security > Full Disk Access).

## Installation

### Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/vanish.git
   cd vanish
   ```

2. Build using Swift Package Manager:
   ```bash
   swift build -c release
   ```

3. Alternatively, use the included build script to create a universal binary:
   ```bash
   chmod +x build_universal.sh
   ./build_universal.sh
   ```

## Development

Vanish is built using **SwiftUI** and **AppKit**.

- **Sources/VanishApp.swift**: Main entry point and MenuBarExtra configuration.
- **Sources/HiddenFilesManager.swift**: The core engine handling shell commands and persistence.
- **Sources/DropPanelController.swift**: Logic for the HUD-style floating drop window.
- **Sources/HistoryWindow.swift**: Management of the searchable hidden items list.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If Vanish helps your workflow, consider starring the repo or supporting the project.

Support or buy me a coffee at [ko-fi.com/mnzel1](https://ko-fi.com/mnzel1)
