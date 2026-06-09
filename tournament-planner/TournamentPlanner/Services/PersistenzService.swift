import Foundation

enum PersistenzFehler: LocalizedError {
    case applicationSupportNichtVerfuegbar

    var errorDescription: String? {
        switch self {
        case .applicationSupportNichtVerfuegbar:
            return "Application-Support-Verzeichnis ist nicht verfügbar."
        }
    }
}

struct PersistenzService {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    var speicherURL: URL {
        get throws {
            guard let basisURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                throw PersistenzFehler.applicationSupportNichtVerfuegbar
            }
            let ordner = basisURL.appendingPathComponent("TournamentPlanner", isDirectory: true)
            try fileManager.createDirectory(at: ordner, withIntermediateDirectories: true)
            return ordner.appendingPathComponent("turnier.json")
        }
    }

    func laden() throws -> Turnier? {
        let url = try speicherURL
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        let daten = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Turnier.self, from: daten)
    }

    func speichern(_ turnier: Turnier) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let daten = try encoder.encode(turnier)
        try daten.write(to: try speicherURL, options: .atomic)
    }
}
