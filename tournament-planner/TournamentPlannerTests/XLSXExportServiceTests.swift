import XCTest
@testable import TournamentPlanner

final class XLSXExportServiceTests: XCTestCase {

    // UC-003 A1: XLSX-Export erzeugt ein gültiges Paket mit Kopfzeile, Standort und Signatur
    func testXLSXExportErzeugtGueltigesArbeitsblatt() throws {
        var turnier = Turnier(
            name: "Export",
            gruppen: ["A", "B", "C", "D"].enumerated().map { Gruppe(name: $0.element, reihenfolge: $0.offset) },
            sportarten: [Sportart(name: "Fussball", standort: "Halle 1", reihenfolge: 0)],
            zeitslots: ["09:00", "09:30"].enumerated().map { Zeitslot(startzeit: $0.element, reihenfolge: $0.offset) }
        )
        turnier.spielplan = PlanungsEngine().erstelleSpielplan(fuer: turnier)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).xlsx")
        defer { try? FileManager.default.removeItem(at: url) }

        try XLSXExportService().exportiere(turnier: turnier, nach: url)

        let daten = try Data(contentsOf: url)
        XCTAssertTrue(daten.starts(with: [0x50, 0x4B]), "XLSX muss ein ZIP-Archiv sein (PK-Header)")

        let unzip = Process()
        unzip.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        unzip.arguments = ["-p", url.path, "xl/worksheets/sheet1.xml"]
        let pipe = Pipe()
        unzip.standardOutput = pipe
        try unzip.run()
        let sheetDaten = pipe.fileHandleForReading.readDataToEndOfFile()
        unzip.waitUntilExit()
        let sheet = try XCTUnwrap(String(data: sheetDaten, encoding: .utf8))

        XCTAssertTrue(sheet.contains("Fussball (Halle 1)"), "Spaltenkopf muss Sportart mit Standort enthalten")
        XCTAssertTrue(sheet.contains("09:00"), "Zeilenkopf muss die Startzeit enthalten")
        XCTAssertTrue(sheet.contains("vs."), "Zellen müssen Paarungstexte enthalten")
        XCTAssertTrue(sheet.contains("contributed by Luc Rossier"), "Signatur muss enthalten sein")
    }

    // Sonderzeichen in Namen dürfen das XML nicht beschädigen
    func testXLSXExportEscaptSonderzeichen() throws {
        var turnier = Turnier(
            name: "Escape",
            gruppen: ["A & B", "<C>", "\"D\"", "E"].enumerated().map { Gruppe(name: $0.element, reihenfolge: $0.offset) },
            sportarten: [Sportart(name: "Fussball", reihenfolge: 0)],
            zeitslots: ["09:00", "09:30"].enumerated().map { Zeitslot(startzeit: $0.element, reihenfolge: $0.offset) }
        )
        turnier.spielplan = PlanungsEngine().erstelleSpielplan(fuer: turnier)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).xlsx")
        defer { try? FileManager.default.removeItem(at: url) }

        try XLSXExportService().exportiere(turnier: turnier, nach: url)

        let unzip = Process()
        unzip.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        unzip.arguments = ["-p", url.path, "xl/worksheets/sheet1.xml"]
        let pipe = Pipe()
        unzip.standardOutput = pipe
        try unzip.run()
        let sheetDaten = pipe.fileHandleForReading.readDataToEndOfFile()
        unzip.waitUntilExit()
        let sheet = try XCTUnwrap(String(data: sheetDaten, encoding: .utf8))

        XCTAssertFalse(sheet.contains("A & B<"), "Ampersand muss escaped sein")
        XCTAssertTrue(sheet.contains("&amp;") || !sheet.contains("A & B"), "Rohes & darf nicht im XML stehen")
        let parser = XMLParser(data: sheetDaten)
        XCTAssertTrue(parser.parse(), "sheet1.xml muss wohlgeformtes XML sein")
    }
}
