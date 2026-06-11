import SwiftUI

struct ZeitslotListeView: View {
    @EnvironmentObject private var viewModel: TurnierViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            kopf
            ForEach($viewModel.turnier.zeitslots) { $zeitslot in
                ZeitslotRowView(
                    zeitslot: $zeitslot,
                    canRemove: viewModel.turnier.zeitslots.count > 1,
                    remove: { viewModel.removeZeitslot(id: zeitslot.id) }
                )
                .onChange(of: zeitslot) { _, _ in
                    viewModel.speichernStill()
                }
            }
        }
        .padding(14)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.separator))
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var kopf: some View {
        HStack {
            Text("Zeitslots")
                .font(.headline)
            Spacer()
            Button {
                viewModel.addZeitslot()
            } label: {
                Image(systemName: "plus.circle.fill")
            }
            .buttonStyle(.borderless)
        }
    }
}

private struct ZeitslotRowView: View {
    @Binding var zeitslot: Zeitslot
    let canRemove: Bool
    let remove: () -> Void

    var body: some View {
        HStack {
            TextField("Start", text: $zeitslot.startzeit)
                .textFieldStyle(.roundedBorder)
            TextField("Ende", text: $zeitslot.endzeit)
                .textFieldStyle(.roundedBorder)
            Button {
                remove()
            } label: {
                Image(systemName: "minus.circle")
            }
            .buttonStyle(.borderless)
            .disabled(!canRemove)
        }
    }
}
