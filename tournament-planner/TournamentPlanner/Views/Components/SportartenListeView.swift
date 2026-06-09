import SwiftUI

struct SportartenListeView: View {
    @EnvironmentObject private var viewModel: TurnierViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            kopf
            ForEach($viewModel.turnier.sportarten) { $sportart in
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
                .onChange(of: sportart.name) { _, _ in
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
