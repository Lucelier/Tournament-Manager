import SwiftUI

struct GruppenListeView: View {
    @EnvironmentObject private var viewModel: TurnierViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            kopf
            ForEach($viewModel.turnier.gruppen) { $gruppe in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        TextField("Gruppe", text: $gruppe.name)
                            .textFieldStyle(.roundedBorder)
                            .overlay {
                                if viewModel.gruppenValidierungsfehler[gruppe.id] != nil {
                                    RoundedRectangle(cornerRadius: 5).stroke(.red, lineWidth: 1)
                                }
                            }
                        Button {
                            viewModel.removeGruppe(id: gruppe.id)
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        .buttonStyle(.borderless)
                        .disabled(viewModel.turnier.gruppen.count <= 2)
                    }
                    if let fehler = viewModel.gruppenValidierungsfehler[gruppe.id] {
                        Text(fehler)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .onChange(of: gruppe.name) { _, _ in
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
            Text("Gruppen")
                .font(.headline)
            Spacer()
            Button {
                viewModel.addGruppe()
            } label: {
                Image(systemName: "plus.circle.fill")
            }
            .buttonStyle(.borderless)
        }
    }
}
