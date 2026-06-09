import AppKit
import Foundation
import UniformTypeIdentifiers

@MainActor
final class TurnierViewModel: ObservableObject {
    @Published var turnier: Turnier
    @Published var aktuelleAnsicht: Ansicht = .setup
    @Published var alertText: String?
    @Published var konfliktZelle: ZellenPosition?
    @Published var konfliktText: String?

    private let persistenzService: PersistenzService
    private let planungsEngine: PlanungsEngine
    private let xlsxExportService: XLSXExportService
    private let pdfExportService: PDFExportService

    enum Ansicht {
        case setup
        case spielplan
    }

    init(
        persistenzService: PersistenzService = PersistenzService(),
        planungsEngine: PlanungsEngine = PlanungsEngine(),
        xlsxExportService: XLSXExportService = XLSXExportService(),
        pdfExportService: PDFExportService = PDFExportService()
    ) {
        self.persistenzService = persistenzService
        self.planungsEngine = planungsEngine
        self.xlsxExportService = xlsxExportService
        self.pdfExportService = pdfExportService

        do {
            self.turnier = try persistenzService.laden() ?? Turnier()
            self.aktuelleAnsicht = self.turnier.spielplan == nil ? .setup : .spielplan
        } catch {
            self.turnier = Turnier()
            self.alertText = error.localizedDescription
        }
    }

    var gruppenValidierungsfehler: [UUID: String] {
        var fehler: [UUID: String] = [:]
        let gruppen = turnier.gruppen

        for gruppe in gruppen {
            let name = normalisiert(gruppe.name)
            if name.isEmpty {
                fehler[gruppe.id] = "Gruppenname erforderlich"
                continue
            }

            let vorkommen = gruppen.filter { normalisiert($0.name) == name }
            if vorkommen.count > 1 {
                fehler[gruppe.id] = "Gruppenname bereits vergeben"
            }
        }

        return fehler
    }

    var validierungsMeldungen: [String] {
        var meldungen: [String] = []
        if turnier.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            meldungen.append("Turniername erforderlich")
        }
        if turnier.gruppen.count < 2 {
            meldungen.append("Mindestens zwei Gruppen erforderlich")
        }
        if turnier.sportarten.isEmpty {
            meldungen.append("Mindestens eine Sportart erforderlich")
        }
        if turnier.zeitslots.isEmpty {
            meldungen.append("Mindestens ein Zeitslot erforderlich")
        }
        if turnier.gruppen.contains(where: { $0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            meldungen.append("Alle Gruppen benötigen einen Namen")
        }
        if turnier.sportarten.contains(where: { $0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            meldungen.append("Alle Sportarten benötigen einen Namen")
        }
        if turnier.zeitslots.contains(where: { $0.bezeichnung.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            meldungen.append("Alle Zeitslots benötigen eine Bezeichnung")
        }
        meldungen.append(contentsOf: Array(Set(gruppenValidierungsfehler.values)).sorted())
        return meldungen
    }

    var isValid: Bool {
        validierungsMeldungen.isEmpty
    }

    var warnungZuWenigZellen: String? {
        let gruppen = turnier.gruppen.count
        guard gruppen >= 2, !turnier.sportarten.isEmpty, !turnier.zeitslots.isEmpty else { return nil }

        if gruppen.isMultiple(of: 2) && turnier.zeitslots.count < gruppen / 2 {
            return "Nicht alle Teams können jede Sportart mindestens einmal spielen. Bitte mehr Zeitslots hinzufügen."
        }

        if !gruppen.isMultiple(of: 2) {
            return "Bei ungerader Gruppenzahl kann pro Sportart mindestens ein Team nicht spielen."
        }

        return nil
    }

    var sortierteGruppen: [Gruppe] {
        turnier.gruppen.sorted { $0.reihenfolge < $1.reihenfolge }
    }

    var sortierteSportarten: [Sportart] {
        turnier.sportarten.sorted { $0.reihenfolge < $1.reihenfolge }
    }

    var sortierteZeitslots: [Zeitslot] {
        turnier.zeitslots.sorted { $0.reihenfolge < $1.reihenfolge }
    }

    func gruppeName(id: UUID) -> String {
        turnier.gruppen.first(where: { $0.id == id })?.name ?? "?"
    }

    func paarungText(_ paarung: Paarung) -> String {
        "\(gruppeName(id: paarung.gruppeAId)) vs. \(gruppeName(id: paarung.gruppeBId))"
    }

    func paarung(sportartId: UUID, zeitslotId: UUID) -> Paarung? {
        turnier.spielplan?.paarungen.first { $0.sportartId == sportartId && $0.zeitslotId == zeitslotId }
    }

    func addGruppe() {
        turnier.gruppen.append(Gruppe(name: "", reihenfolge: turnier.gruppen.count))
        speichernStill()
    }

    func removeGruppe(id: UUID) {
        guard turnier.gruppen.count > 2 else { return }
        turnier.gruppen.removeAll { $0.id == id }
        normalisiereReihenfolgen()
        turnier.spielplan = nil
        speichernStill()
    }

    func addSportart() {
        turnier.sportarten.append(Sportart(name: "", reihenfolge: turnier.sportarten.count))
        speichernStill()
    }

    func removeSportart(id: UUID) {
        guard turnier.sportarten.count > 1 else { return }
        turnier.sportarten.removeAll { $0.id == id }
        normalisiereReihenfolgen()
        turnier.spielplan = nil
        speichernStill()
    }

    func addZeitslot() {
        turnier.zeitslots.append(Zeitslot(bezeichnung: "", reihenfolge: turnier.zeitslots.count))
        speichernStill()
    }

    func removeZeitslot(id: UUID) {
        guard turnier.zeitslots.count > 1 else { return }
        turnier.zeitslots.removeAll { $0.id == id }
        normalisiereReihenfolgen()
        turnier.spielplan = nil
        speichernStill()
    }

    func erstelleSpielplan() {
        guard isValid else { return }
        turnier.spielplan = planungsEngine.erstelleSpielplan(fuer: turnier)
        aktuelleAnsicht = .spielplan
        speichernStill()
    }

    func neuesTurnier() {
        turnier = Turnier()
        aktuelleAnsicht = .setup
        speichernStill()
    }

    func speichernStill() {
        do {
            try persistenzService.speichern(turnier)
        } catch {
            alertText = error.localizedDescription
        }
    }

    func verschiebe(paarungId: UUID, nach position: ZellenPosition) {
        guard var spielplan = turnier.spielplan else { return }
        if let konflikt = planungsEngine.verschiebe(
            paarungId: paarungId,
            nachSportartId: position.sportartId,
            zeitslotId: position.zeitslotId,
            in: &spielplan,
            gruppen: turnier.gruppen
        ) {
            konfliktZelle = position
            konfliktText = konflikt.localizedDescription
            return
        }

        konfliktZelle = nil
        konfliktText = nil
        turnier.spielplan = spielplan
        speichernStill()
    }

    func exportiere(format: ExportFormat) {
        guard turnier.spielplan != nil else { return }

        let formatter = PlanExportFormatter(turnier: turnier)
        let panel = NSSavePanel()
        panel.allowedContentTypes = [format == .xlsx ? .spreadsheet : .pdf]
        panel.nameFieldStringValue = formatter.standardDateiname(format: format)
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            switch format {
            case .xlsx:
                try xlsxExportService.exportiere(turnier: turnier, nach: url)
            case .pdf:
                try pdfExportService.exportiere(turnier: turnier, nach: url)
            }
            alertText = "Datei erfolgreich gespeichert:\n\(url.path)"
            NSWorkspace.shared.activateFileViewerSelecting([url])
        } catch {
            alertText = "Export fehlgeschlagen: \(error.localizedDescription)"
        }
    }

    private func normalisiereReihenfolgen() {
        for index in turnier.gruppen.indices {
            turnier.gruppen[index].reihenfolge = index
        }
        for index in turnier.sportarten.indices {
            turnier.sportarten[index].reihenfolge = index
        }
        for index in turnier.zeitslots.indices {
            turnier.zeitslots[index].reihenfolge = index
        }
    }

    private func normalisiert(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

struct ZellenPosition: Codable, Hashable {
    let sportartId: UUID
    let zeitslotId: UUID
}

extension UTType {
    static var spreadsheet: UTType {
        UTType(filenameExtension: "xlsx") ?? .data
    }
}
