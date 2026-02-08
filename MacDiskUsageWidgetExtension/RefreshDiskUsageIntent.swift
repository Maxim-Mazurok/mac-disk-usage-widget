import AppIntents
import WidgetKit

struct RefreshDiskUsageIntent: AppIntent {
    static let title: LocalizedStringResource = "Refresh Disk Usage"
    static let description = IntentDescription("Refreshes the Mac Disk Usage widget timeline.")

    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
