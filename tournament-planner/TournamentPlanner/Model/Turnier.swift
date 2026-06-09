import Foundation

struct Turnier: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    let erstelltAm: Date
    var gruppen: [Gruppe]
    var sportarten: [Sportart]
    var zeitslots: [Zeitslot]
    var spielplan: Spielplan?

    init(
        id: UUID = UUID(),
        name: String = "",
        erstelltAm: Date = Date(),
        gruppen: [Gruppe] = [
            Gruppe(name: "A", reihenfolge: 0),
            Gruppe(name: "B", reihenfolge: 1)
        ],
        sportarten: [Sportart] = [Sportart(name: "Fussball", reihenfolge: 0)],
        zeitslots: [Zeitslot] = [Zeitslot(bezeichnung: "09:00", reihenfolge: 0)],
        spielplan: Spielplan? = nil
    ) {
        self.id = id
        self.name = name
        self.erstelltAm = erstelltAm
        self.gruppen = gruppen
        self.sportarten = sportarten
        self.zeitslots = zeitslots
        self.spielplan = spielplan
    }
}

struct Gruppe: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var reihenfolge: Int

    init(id: UUID = UUID(), name: String, reihenfolge: Int) {
        self.id = id
        self.name = name
        self.reihenfolge = reihenfolge
    }
}

struct Sportart: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var reihenfolge: Int

    init(id: UUID = UUID(), name: String, reihenfolge: Int) {
        self.id = id
        self.name = name
        self.reihenfolge = reihenfolge
    }
}

struct Zeitslot: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var bezeichnung: String
    var startzeit: String?
    var endzeit: String?
    var reihenfolge: Int

    init(
        id: UUID = UUID(),
        bezeichnung: String,
        startzeit: String? = nil,
        endzeit: String? = nil,
        reihenfolge: Int
    ) {
        self.id = id
        self.bezeichnung = bezeichnung
        self.startzeit = startzeit
        self.endzeit = endzeit
        self.reihenfolge = reihenfolge
    }

    var anzeigeText: String {
        let rawZeiten: [String?] = [startzeit, endzeit]
        let zeiten = rawZeiten.compactMap { value -> String? in
            guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
            return value
        }
        return zeiten.isEmpty ? bezeichnung : "\(bezeichnung) (\(zeiten.joined(separator: "-")))"
    }
}

struct Spielplan: Codable, Identifiable, Equatable {
    let id: UUID
    let erstelltAm: Date
    var paarungen: [Paarung]
    var nichtPlatziert: [Paarung]

    init(
        id: UUID = UUID(),
        erstelltAm: Date = Date(),
        paarungen: [Paarung] = [],
        nichtPlatziert: [Paarung] = []
    ) {
        self.id = id
        self.erstelltAm = erstelltAm
        self.paarungen = paarungen
        self.nichtPlatziert = nichtPlatziert
    }
}

struct Paarung: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    let gruppeAId: UUID
    let gruppeBId: UUID
    var sportartId: UUID?
    var zeitslotId: UUID?

    init(
        id: UUID = UUID(),
        gruppeAId: UUID,
        gruppeBId: UUID,
        sportartId: UUID? = nil,
        zeitslotId: UUID? = nil
    ) {
        self.id = id
        self.gruppeAId = gruppeAId
        self.gruppeBId = gruppeBId
        self.sportartId = sportartId
        self.zeitslotId = zeitslotId
    }

    func contains(gruppeId: UUID) -> Bool {
        gruppeAId == gruppeId || gruppeBId == gruppeId
    }

    var paarungsKey: Set<UUID> {
        [gruppeAId, gruppeBId]
    }
}

enum ExportFormat: String, Codable, CaseIterable, Identifiable {
    case xlsx = "XLSX"
    case pdf = "PDF"

    var id: String { rawValue }

    var dateiendung: String {
        switch self {
        case .xlsx: return "xlsx"
        case .pdf: return "pdf"
        }
    }
}

struct ExportKonfiguration: Codable, Equatable {
    let format: ExportFormat
    let dateipfad: String
    let dateiname: String
}
