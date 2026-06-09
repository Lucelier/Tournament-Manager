import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: TurnierViewModel

    var body: some View {
        Group {
            switch viewModel.aktuelleAnsicht {
            case .setup:
                SetupView()
            case .spielplan:
                SpielplanView()
            }
        }
        .alert("Hinweis", isPresented: alertBinding) {
            Button("OK") {
                viewModel.alertText = nil
            }
        } message: {
            Text(viewModel.alertText ?? "")
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertText != nil },
            set: { if !$0 { viewModel.alertText = nil } }
        )
    }
}
