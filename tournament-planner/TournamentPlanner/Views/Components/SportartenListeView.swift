import SwiftUI

struct SportartenListeView: View {
    @EnvironmentObject private var viewModel: TurnierViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            kopf
            ForEach($viewModel.turnier.sportarten) { $sportart in
                VStack(spacing: 6) {
                    HStack {
                        TextField("Sportart", text: $sportart.name)
                            .textFieldStyle(.roundedBorder)
                        Button {
                            viewModel.removeSportart(id: sportart.id)
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        .buttonStyle(.borderless)
                        .disabled(viewModel.turnier.sportarten.count <= 1)
                    }
                    TextField("Standort (optional)", text: Binding($sportart.standort, replacingNilWith: ""))
                        .textFieldStyle(.roundedBorder)
                }
                .onChange(of: sportart) { _, _ in
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
            Text("Sportarten")
                .font(.headline)
            Spacer()
            Button {
                viewModel.addSportart()
            } label: {
                Image(systemName: "plus.circle.fill")
            }
            .buttonStyle(.borderless)
        }
    }
}

private extension Binding where Value == String {
    init(_ source: Binding<String?>, replacingNilWith defaultValue: String) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }
}
