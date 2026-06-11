import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: TurnierViewModel

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch viewModel.aktuelleAnsicht {
                case .setup:
                    SetupView()
                case .spielplan:
                    SpielplanView()
                }
            }
            .frame(maxHeight: .infinity)
            signatur
        }
        .alert("Hinweis", isPresented: alertBinding) {
            Button("OK") {
                viewModel.alertText = nil
            }
        } message: {
            Text(viewModel.alertText ?? "")
        }
    }

    private var signatur: some View {
        Text("contributed by Luc Rossier")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 3)
            .background(Color(nsColor: .windowBackgroundColor))
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertText != nil },
            set: { if !$0 { viewModel.alertText = nil } }
        )
    }
}
