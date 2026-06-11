import Foundation

struct PlanExportFormatter {
    let turnier: Turnier

    var sportarten: [Sportart] {
        turnier.sportarten.sorted { $0.reihenfolge < $1.reihenfolge }
    }

    var zeitslots: [Zeitslot] {
        turnier.zeitslots.sorted { $0.reihenfolge < $1.reihenfolge }
    }

    var gruppen: [UUID: Gruppe] {
        Dictionary(uniqueKeysWithValues: turnier.gruppen.map { ($0.id, $0) })
    }

    func spaltenTitel(fuer sportart: Sportart) -> String {
        guard let standort = sportart.standort?.trimmingCharacters(in: .whitespacesAndNewlines), !standort.isEmpty else {
            return sportart.name
        }
        return "\(sportart.name) (\(standort))"
    }

    func text(fuer paarung: Paarung) -> String {
        let gruppeA = gruppen[paarung.gruppeAId]?.name ?? "?"
        let gruppeB = gruppen[paarung.gruppeBId]?.name ?? "?"
        return "\(gruppeA) vs. \(gruppeB)"
    }

    func paarung(sportartId: UUID, zeitslotId: UUID) -> Paarung? {
        turnier.spielplan?.paarungen.first { $0.sportartId == sportartId && $0.zeitslotId == zeitslotId }
    }

    func zellenText(sportartId: UUID, zeitslotId: UUID) -> String {
        guard let paarung = paarung(sportartId: sportartId, zeitslotId: zeitslotId) else { return "" }
        return text(fuer: paarung)
    }

    func standardDateiname(format: ExportFormat, datum: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let name = turnier.name.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "/", with: "-")
        let basis = name.isEmpty ? "Turnier" : name
        return "Spielplan_\(basis)_\(formatter.string(from: datum)).\(format.dateiendung)"
    }
}
