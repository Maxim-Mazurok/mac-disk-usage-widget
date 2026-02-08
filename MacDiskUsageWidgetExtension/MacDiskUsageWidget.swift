import SwiftUI
import WidgetKit

@main
struct MacDiskUsageWidgetBundle: WidgetBundle {
    var body: some Widget {
        MacDiskUsageWidget()
    }
}

struct MacDiskUsageWidget: Widget {
    private let kind = "MacDiskUsageWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DiskUsageTimelineProvider()) { entry in
            DiskUsageWidgetView(entry: entry)
        }
        .configurationDisplayName("Mac Disk Usage")
        .description("Shows total, used, free, and percentage used for the main system volume.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
