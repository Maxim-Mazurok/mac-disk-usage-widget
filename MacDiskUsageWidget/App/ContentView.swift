import AppKit
import Combine
import OSLog
import SwiftUI
import WidgetKit

final class DiskUsageViewModel: ObservableObject {
    @Published private(set) var snapshot: DiskUsageSnapshot = .unavailable()
    @Published private(set) var severity: UsageSeverity = .normal
    @Published private(set) var lastErrorMessage: String?

    private let service: DiskUsageService
    private let refreshInterval: TimeInterval
    private let logger = Logger(subsystem: "com.max.MacDiskUsageWidget", category: "DiskUsage")

    private var timerCancellable: AnyCancellable?
    private var workspaceObservers: [NSObjectProtocol] = []
    private var hasStarted = false

    init(service: DiskUsageService = SystemVolumeDiskUsageService(), refreshInterval: TimeInterval = 30) {
        self.service = service
        self.refreshInterval = refreshInterval
    }

    deinit {
        timerCancellable?.cancel()

        let notificationCenter = NSWorkspace.shared.notificationCenter
        for observer in workspaceObservers {
            notificationCenter.removeObserver(observer)
        }
    }

    func start() {
        guard !hasStarted else {
            return
        }

        hasStarted = true
        observeVolumeChanges()
        refresh(reason: "initial", shouldReloadWidget: false)
        startTimer()
    }

    func handleAppDidBecomeActive() {
        refresh(reason: "app active", shouldReloadWidget: true)
    }

    func manualRefresh() {
        refresh(reason: "manual", shouldReloadWidget: true)
    }

    func reloadWidgetTimelines() {
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refresh(reason: "timer", shouldReloadWidget: true)
            }
    }

    private func observeVolumeChanges() {
        let notificationCenter = NSWorkspace.shared.notificationCenter
        let notifications: [Notification.Name] = [
            NSWorkspace.didMountNotification,
            NSWorkspace.didUnmountNotification,
            NSWorkspace.didRenameVolumeNotification
        ]

        for name in notifications {
            let observer = notificationCenter.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                self?.refresh(reason: "volume event", shouldReloadWidget: true)
            }

            workspaceObservers.append(observer)
        }
    }

    private func refresh(reason: String, shouldReloadWidget: Bool) {
        do {
            let latestSnapshot = try service.fetchSystemVolumeUsage()
            snapshot = latestSnapshot
            severity = UsageSeverity(fraction: latestSnapshot.usedFraction)
            lastErrorMessage = nil
            logger.debug("Disk usage refreshed [\(reason, privacy: .public)]")
        } catch {
            let fallback = DiskUsageSnapshot.unavailable(timestamp: Date())
            snapshot = fallback
            severity = UsageSeverity(fraction: fallback.usedFraction)
            lastErrorMessage = error.localizedDescription
            logger.error("Disk usage refresh failed [\(reason, privacy: .public)]: \(error.localizedDescription, privacy: .public)")
        }

        if shouldReloadWidget {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: DiskUsageViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            statsCard
            instructionsCard
            footer
        }
        .padding(20)
        .frame(minWidth: 460, minHeight: 360)
        .background(
            LinearGradient(
                colors: [Color(nsColor: .windowBackgroundColor), Color(nsColor: .underPageBackgroundColor)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Disk Usage")
                    .font(.system(size: 28, weight: .semibold))

                Text(viewModel.snapshot.volumeName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if viewModel.snapshot.isAvailable {
                Text(DiskUsageFormatter.percentageString(for: viewModel.snapshot.usedFraction))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(viewModel.severity.color)
            }
        }
    }

    private var statsCard: some View {
        Group {
            if viewModel.snapshot.isAvailable {
                VStack(alignment: .leading, spacing: 14) {
                    Gauge(value: viewModel.snapshot.usedFraction, in: 0...1) {
                        Text("Used")
                    } currentValueLabel: {
                        Text(DiskUsageFormatter.percentageString(for: viewModel.snapshot.usedFraction))
                    }
                    .tint(viewModel.severity.color)
                    .gaugeStyle(.accessoryLinearCapacity)

                    Divider()

                    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
                        GridRow {
                            metricLabel("Total")
                            metricValue(DiskUsageFormatter.storageString(for: viewModel.snapshot.totalBytes))
                        }
                        GridRow {
                            metricLabel("Used")
                            metricValue(DiskUsageFormatter.storageString(for: viewModel.snapshot.usedBytes))
                        }
                        GridRow {
                            metricLabel("Free")
                            metricValue(DiskUsageFormatter.storageString(for: viewModel.snapshot.freeBytes))
                        }
                        GridRow {
                            metricLabel("Percent Used")
                            metricValue(DiskUsageFormatter.percentageString(for: viewModel.snapshot.usedFraction))
                        }
                    }
                }
                .padding(16)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Disk information is currently unavailable")
                        .font(.headline)
                    Text(viewModel.lastErrorMessage ?? "Retry in a moment.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Add Widget")
                .font(.headline)
            Text("Control-click the desktop, choose Edit Widgets, then add Mac Disk Usage in small, medium, or large size.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var footer: some View {
        HStack {
            Button("Refresh Now") {
                viewModel.manualRefresh()
            }

            Button("Reload Widget") {
                viewModel.reloadWidgetTimelines()
            }

            Spacer()

            Text("Updated \(DiskUsageFormatter.updatedTimeString(from: viewModel.snapshot.timestamp))")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func metricLabel(_ title: String) -> some View {
        Text(title)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

    private func metricValue(_ value: String) -> some View {
        Text(value)
            .font(.body.weight(.medium))
    }
}

private extension UsageSeverity {
    var color: Color {
        switch self {
        case .normal:
            return .green
        case .warning:
            return .yellow
        case .critical:
            return .red
        }
    }
}
