import SwiftUI

@main
struct TournamentPlannerApp: App {
    @StateObject private var viewModel = TurnierViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .frame(minWidth: 980, minHeight: 680)
                .onDisappear {
                    viewModel.speichernStill()
                }
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Neues Turnier") {
                    viewModel.neuesTurnier()
                }
                .keyboardShortcut("n")
            }
        }
    }
}
