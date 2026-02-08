import SwiftUI

@main
struct MacDiskUsageWidgetApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = DiskUsageViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .onAppear {
                    viewModel.start()
                }
        }
        .windowResizability(.contentSize)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.handleAppDidBecomeActive()
            }
        }
    }
}
