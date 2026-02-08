# Contributing

Thanks for helping improve Mac Disk Usage Widget.

## Prerequisites
- macOS 14+
- Xcode 26.2+
- XcodeGen (only needed if you regenerate the project from `project.yml`)

## Local setup
1. Clone the repo.
2. Optional: regenerate the Xcode project.
   ```bash
   xcodegen generate
   ```
3. Build the app.
   ```bash
   xcodebuild -project MacDiskUsageWidget.xcodeproj -scheme MacDiskUsageWidget -configuration Debug -destination 'platform=macOS' build
   ```
4. Run tests.
   ```bash
   xcodebuild -project MacDiskUsageWidget.xcodeproj -scheme MacDiskUsageWidget -destination 'platform=macOS' test
   ```

## Development notes
- Keep UI native and minimal.
- Do not introduce network features or analytics.
- Use native macOS APIs for disk statistics.

## Seeing widget changes reliably
WidgetKit and desktop widgets can cache timelines and rendering. After UI changes, use this sequence:
1. Build and run the app target once.
2. Use the widget's refresh button.
3. If the widget still looks stale, remove and re-add the widget.
4. If still stale, restart widget hosts:
   ```bash
   killall NotificationCenter
   killall Dock
   ```
5. If cache/state is still stuck, do a full macOS reboot.

## Xcode previews
To use SwiftUI previews for widget UI work:
1. Open `MacDiskUsageWidget/App/DiskUsageWidgetCanvasPreview.swift`.
2. Enable Canvas with `Option + Command + Return`.
3. Click `Resume` if needed.

This file includes:
- View previews for `.fullColor` and `.accented` rendering modes via `previewRenderingModeOverride`.
- Widget-style sizing via `previewFamilyOverride` and fixed preview frames.

If you see this error in Canvas:
- `UnknownProcessType: This platform does not support previewing widgets`
- `No plugin is registered to launch the process type widgetExtension`
then avoid previewing from widget extension files directly on this platform/toolchain. Use `MacDiskUsageWidget/App/DiskUsageWidgetCanvasPreview.swift` as the preview host file instead.

If previews fail to appear:
1. Confirm target membership includes `MacDiskUsageWidget`.
2. Clean build folder (`Shift + Command + K`).
3. Restart Xcode.
4. If needed, clear DerivedData for this project and reopen Xcode:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/MacDiskUsageWidget-*
   ```

## Release artifacts
A GitHub Actions workflow runs on published releases and creates a zipped macOS app artifact.

## Pull requests
- Keep changes focused.
- Include tests for logic changes.
- Update docs if user-visible behavior changes.
