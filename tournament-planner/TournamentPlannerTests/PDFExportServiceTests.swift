import PDFKit
import XCTest
@testable import TournamentPlanner

final class PDFExportServiceTests: XCTestCase {

    private func testTurnier(zeitslotAnzahl: Int) -> Turnier {
        var turnier = Turnier(
            name: "Export",
            gruppen: ["A", "B", "C", "D"].enumerated().map { Gruppe(name: $0.element, reihenfolge: $0.offset) },
            sportarten: [("Fussball", "Rasenplatz"), ("Volleyball", "Halle 1")].enumerated().map {
                Sportart(name: $0.element.0, standort: $0.element.1, reihenfolge: $0.offset)
            },
            zeitslots: (0..<zeitslotAnzahl).map {
                Zeitslot(startzeit: String(format: "%02d:%02d", 8 + $0 / 4, ($0 % 4) * 15), reihenfolge: $0)
            }
        )
        turnier.spielplan = PlanungsEngine().erstelleSpielplan(fuer: turnier)
        return turnier
    }

    private func exportiere(_ turnier: Turnier) throws -> PDFDocument {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).pdf")
        defer { try? FileManager.default.removeItem(at: url) }
        try PDFExportService().exportiere(turnier: turnier, nach: url)
        return try XCTUnwrap(PDFDocument(url: url), "PDF konnte nicht gelesen werden")
    }

    // UC-003: Das PDF muss im Querformat erzeugt werden
    func testPDFExportErzeugtQuerformat() throws {
        let dokument = try exportiere(testTurnier(zeitslotAnzahl: 4))

        XCTAssertEqual(dokument.pageCount, 1)
        let seite = try XCTUnwrap(dokument.page(at: 0))
        let groesse = seite.bounds(for: .mediaBox)
        XCTAssertGreaterThan(groesse.width, groesse.height, "PDF muss im Querformat sein")
    }

    // UC-003: Bei vielen Zeitslots wird die Tabelle auf mehrere Seiten verteilt statt abgeschnitten
    func testPDFExportVerteiltVieleZeitslotsAufMehrereSeiten() throws {
        let zeilenProSeite = PDFExportService().zeilenProSeite
        let dokument = try exportiere(testTurnier(zeitslotAnzahl: zeilenProSeite + 3))

        XCTAssertEqual(dokument.pageCount, 2, "Überzählige Zeitslots müssen auf einer zweiten Seite erscheinen")
    }
}
