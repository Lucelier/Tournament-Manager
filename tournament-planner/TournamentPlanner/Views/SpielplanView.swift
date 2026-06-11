import SwiftUI
import UniformTypeIdentifiers

struct SpielplanView: View {
    @EnvironmentObject private var viewModel: TurnierViewModel
    @State private var zeigtExport = false
    @State private var bestaetigeZurueck = false
    @State private var zeigtHilfe = false

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            ScrollView([.vertical, .horizontal]) {
                VStack(alignment: .leading, spacing: 18) {
                    if let warnung = viewModel.warnungZuWenigZellen {
                        Text(warnung)
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 4)
                    }
                    raster
                    nichtPlatziert
                }
                .padding(24)
            }
        }
        .sheet(isPresented: $zeigtExport) {
            ExportView()
                .environmentObject(viewModel)
        }
        .confirmationDialog("Aktuellen Spielplan verwerfen?", isPresented: $bestaetigeZurueck) {
            Button("Zurück zum Setup", role: .destructive) {
                viewModel.turnier.spielplan = nil
                viewModel.aktuelleAnsicht = .setup
                viewModel.speichernStill()
            }
            Button("Abbrechen", role: .cancel) {}
        }
    }

    private var toolbar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.turnier.name.isEmpty ? "Spielplan" : viewModel.turnier.name)
                    .font(.title2.bold())
                Text("\(viewModel.sortierteGruppen.count) Gruppen, \(viewModel.sortierteSportarten.count) Sportarten, \(viewModel.sortierteZeitslots.count) Zeitslots")
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
            Button("Zurück") {
                bestaetigeZurueck = true
            }
            Button("Neu berechnen") {
                viewModel.erstelleSpielplan()
            }
            Button("Exportieren") {
                zeigtExport = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(20)
    }

    private var raster: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                headerCell("")
                ForEach(viewModel.sortierteSportarten) { sportart in
                    headerCell(sportart.name, untertitel: sportart.standort)
                }
            }

            ForEach(viewModel.sortierteZeitslots) { zeitslot in
                GridRow {
                    headerCell(zeitslot.anzeigeText)
                    ForEach(viewModel.sortierteSportarten) { sportart in
                        PaarungsZelleView(sportart: sportart, zeitslot: zeitslot)
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.separator))
    }

    private func headerCell(_ text: String, untertitel: String? = nil) -> some View {
        VStack(spacing: 2) {
            Text(text)
                .font(.headline)
                .lineLimit(untertitel == nil ? 2 : 1)
            if let untertitel, !untertitel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(untertitel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(width: 170, height: 54, alignment: .center)
        .background(Color(nsColor: .controlBackgroundColor))
        .border(Color(nsColor: .separatorColor), width: 0.5)
    }

    @ViewBuilder
    private var nichtPlatziert: some View {
        if let nichtPlatziert = viewModel.turnier.spielplan?.nichtPlatziert, !nichtPlatziert.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Nicht eingeplant")
                    .font(.headline)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 8)], spacing: 8) {
                    ForEach(nichtPlatziert) { paarung in
                        Text(viewModel.paarungText(paarung))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .onDrag {
                                NSItemProvider(object: paarung.id.uuidString as NSString)
                            }
                    }
                }
            }
        }
    }
}
