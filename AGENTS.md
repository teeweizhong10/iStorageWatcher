# Repository Guidelines

## Project Structure & Module Organization
- `iStorageWatcher/`: Main SwiftUI app. Key folders: `HomeViews/` (views like `HomeView`, `StorageDetailView`), `Shared/` (models/managers such as `StorageInfo`, `BatteryHealthManager`), `Assets(.xcassets)/`.
- `iStorageWidgetiOS/` and `iStorageWidgetMacOS/`: Widget extension bundles and Info/entitlement files. Widget UI/components live in `iStorageWatcher/WidgetViews/`.
- `iStorageWatcherTests/`: Unit tests (XCTest).
- `iStorageWatcherUITests/`: UI tests (XCTest UI testing).
- Project file: `iStorageWatcher.xcodeproj` with shared schemes for app and widgets.

## Build, Test, and Development Commands
- Open in Xcode: `open iStorageWatcher.xcodeproj`
- Build (macOS app): `xcodebuild -scheme iStorageWatcher -destination 'platform=macOS' build`
- Run unit+UI tests (macOS): `xcodebuild -scheme iStorageWatcher -destination 'platform=macOS' test`
- Build iOS simulator: `xcodebuild -scheme iStorageWatcher -destination 'platform=iOS Simulator,name=iPhone 15' build`
- Build widgets: `xcodebuild -scheme iStorageWidgetiOSExtension -destination 'platform=iOS Simulator,name=iPhone 15' build` and `xcodebuild -scheme iStorageWidgetMacOSExtension -destination 'platform=macOS' build`
Notes: Use Xcode’s Product > Test to run tests interactively. Run `xcodebuild -list -project iStorageWatcher.xcodeproj` to discover schemes/destinations.

## Coding Style & Naming Conventions
- Swift 5+ with SwiftUI. Indentation: 2 spaces, no tabs. Use apple native UI elements as much as possible.
- Types: UpperCamelCase (`StorageInfo`); functions/vars: lowerCamelCase (`getStorageInfo`).
- File naming: one primary type per file, file name matches type when practical.
- Use Xcode’s built‑in formatter; keep imports minimal. Prefer clear, composable SwiftUI views under `HomeViews/` and shared logic under `Shared/`.

## Testing Guidelines
- Framework: XCTest. Place unit tests in `iStorageWatcherTests/` (e.g., `StorageInfoTests.swift`), UI tests in `iStorageWatcherUITests/`.
- Naming: files end with `Tests.swift`; test methods start with `test...` and assert a single behavior.
- Coverage focus: storage calculations (`StorageInfo`), widget timeline/provider logic, and key view logic. Run via Xcode or `xcodebuild test` (see commands above).

## Commit & Pull Request Guidelines
- Commits: short, imperative subject (max ~72 chars). Prefer topical tags seen in history (e.g., `ui-fixup: Adjust iOS layout`). Group related changes; avoid mixed concerns.
- PRs: include summary, screenshots for UI changes, steps to verify, and any linked issues. Ensure builds and tests pass for app and widget schemes.

## Security & Configuration Tips
- Do not commit secrets. Edit `Info.plist` and entitlement files thoughtfully. macOS battery info uses `ioreg`; avoid blocking calls—follow patterns in `BatteryHealthManager`.

