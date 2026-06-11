import SwiftUI

struct SetupView: View {
    @EnvironmentObject private var viewModel: TurnierViewModel
    @State private var zeigtHilfe = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    turnierName
                    HStack(alignment: .top, spacing: 18) {
                        GruppenListeView()
                        SportartenListeView()
                        ZeitslotListeView()
                    }
                    validierung
                }
                .padding(24)
            }
            Divider()
            footer
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("TournamentPlanner")
                    .font(.title2.bold())
                Text("Turnierdaten erfassen")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                zeigtHilfe = true
            } label: {
                Label("Hilfe", systemImage: "questionmark.circle")
            }
            .sheet(isPresented: $zeigtHilfe) {
                HilfeView()
            }
            Button("Beispieldaten") {
                viewModel.turnier.name = "Sommerturnier"
                viewModel.turnier.gruppen = ["A", "B", "C", "D"].enumerated().map { Gruppe(name: $0.element, reihenfolge: $0.offset) }
                viewModel.turnier.sportarten = [("Fussball", "Rasenplatz"), ("Volleyball", "Halle 1"), ("Unihockey", "Halle 2")].enumerated().map { Sportart(name: $0.element.0, standort: $0.element.1, reihenfolge: $0.offset) }
                viewModel.turnier.zeitslots = [("09:00", "09:25"), ("09:30", "09:55"), ("10:00", "10:25"), ("10:30", "10:55")].enumerated().map { Zeitslot(startzeit: $0.element.0, endzeit: $0.element.1, reihenfolge: $0.offset) }
                viewModel.turnier.spielplan = nil
                viewModel.speichernStill()
            }
        }
        .padding(24)
    }

    private var turnierName: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Turniername")
                .font(.headline)
            TextField("Name", text: $viewModel.turnier.name)
                .textFieldStyle(.roundedBorder)
                .onChange(of: viewModel.turnier.name) { _, _ in
                    viewModel.speichernStill()
                }
        }
    }

    @ViewBuilder
    private var validierung: some View {
        if !viewModel.validierungsMeldungen.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(viewModel.validierungsMeldungen, id: \.self) { meldung in
                    Text(meldung)
                        .font(.callout)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private var footer: some View {
        HStack {
            if let warnung = viewModel.warnungZuWenigZellen {
                Text(warnung)
                    .font(.callout)
                    .foregroundStyle(.orange)
            }
            Spacer()
            Button("Spielplan erstellen") {
                viewModel.erstelleSpielplan()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.isValid)
        }
        .padding(18)
    }
}
