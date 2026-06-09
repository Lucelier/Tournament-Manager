import XCTest
@testable import TournamentPlanner

final class PlanungsEngineTests: XCTestCase {
    func testVierGruppenSpielenJedeSportartMindestensEinmalOhneZeitslotKonflikt() {
        let turnier = Turnier(
            name: "Smoke",
            gruppen: ["A", "B", "C", "D"].enumerated().map { Gruppe(name: $0.element, reihenfolge: $0.offset) },
            sportarten: ["Fussball", "Volleyball", "Unihockey"].enumerated().map { Sportart(name: $0.element, reihenfolge: $0.offset) },
            zeitslots: ["09:00", "09:30", "10:00", "10:30"].enumerated().map { Zeitslot(bezeichnung: $0.element, reihenfolge: $0.offset) }
        )

        let spielplan = PlanungsEngine().erstelleSpielplan(fuer: turnier)

        XCTAssertEqual(spielplan.paarungen.count, 8)
        XCTAssertTrue(spielplan.nichtPlatziert.isEmpty)

        for zeitslot in turnier.zeitslots {
            let gruppenInZeile = spielplan.paarungen
                .filter { $0.zeitslotId == zeitslot.id }
                .flatMap { [$0.gruppeAId, $0.gruppeBId] }
            XCTAssertEqual(gruppenInZeile.count, Set(gruppenInZeile).count)
        }

        for gruppe in turnier.gruppen {
            for sportart in turnier.sportarten {
                let anzahl = spielplan.paarungen.filter { paarung in
                    paarung.sportartId == sportart.id && paarung.contains(gruppeId: gruppe.id)
                }.count
                XCTAssertGreaterThanOrEqual(anzahl, 1)
            }
        }
    }

    func testFuellungHatPrioritaetNachSportartenMindestabdeckung() {
        let turnier = Turnier(
            name: "Fuellung",
            gruppen: ["A", "B", "C", "D"].enumerated().map { Gruppe(name: $0.element, reihenfolge: $0.offset) },
            sportarten: ["Fussball", "Volleyball"].enumerated().map { Sportart(name: $0.element, reihenfolge: $0.offset) },
            zeitslots: ["09:00", "09:30", "10:00", "10:30"].enumerated().map { Zeitslot(bezeichnung: $0.element, reihenfolge: $0.offset) }
        )

        let spielplan = PlanungsEngine().erstelleSpielplan(fuer: turnier)

        XCTAssertEqual(spielplan.paarungen.count, 8)

        let wiederholteTeamSportarten = turnier.gruppen.flatMap { gruppe in
            turnier.sportarten.map { sportart in
                spielplan.paarungen.filter { paarung in
                    paarung.sportartId == sportart.id && paarung.contains(gruppeId: gruppe.id)
                }.count
            }
        }
        XCTAssertTrue(wiederholteTeamSportarten.contains { $0 > 1 })
    }

    func testUngeradeGruppenzahlMaximiertSportartenAbdeckung() {
        let turnier = Turnier(
            name: "Knapp",
            gruppen: ["A", "B", "C", "D", "E"].enumerated().map { Gruppe(name: $0.element, reihenfolge: $0.offset) },
            sportarten: ["Fussball", "Volleyball"].enumerated().map { Sportart(name: $0.element, reihenfolge: $0.offset) },
            zeitslots: ["09:00", "09:30"].enumerated().map { Zeitslot(bezeichnung: $0.element, reihenfolge: $0.offset) }
        )

        let spielplan = PlanungsEngine().erstelleSpielplan(fuer: turnier)

        XCTAssertEqual(spielplan.paarungen.count, 4)
        XCTAssertTrue(spielplan.nichtPlatziert.isEmpty)

        let abdeckung = PlanungsEngine().sportartenAbdeckung(
            in: spielplan,
            gruppen: turnier.gruppen,
            sportarten: turnier.sportarten
        )
        XCTAssertEqual(abdeckung.count, 8)
    }

    func testGegnerDuerfenSichWiederholenWennSportartenPrioritaetDasErfordert() {
        let turnier = Turnier(
            name: "Wiederholung",
            gruppen: ["A", "B"].enumerated().map { Gruppe(name: $0.element, reihenfolge: $0.offset) },
            sportarten: ["Fussball", "Volleyball", "Unihockey"].enumerated().map { Sportart(name: $0.element, reihenfolge: $0.offset) },
            zeitslots: ["09:00", "09:30", "10:00"].enumerated().map { Zeitslot(bezeichnung: $0.element, reihenfolge: $0.offset) }
        )

        let spielplan = PlanungsEngine().erstelleSpielplan(fuer: turnier)

        XCTAssertEqual(spielplan.paarungen.count, 3)
        XCTAssertEqual(Set(spielplan.paarungen.map(\.paarungsKey)).count, 1)

        for gruppe in turnier.gruppen {
            for sportart in turnier.sportarten {
                let anzahl = spielplan.paarungen.filter { paarung in
                    paarung.sportartId == sportart.id && paarung.contains(gruppeId: gruppe.id)
                }.count
                XCTAssertGreaterThanOrEqual(anzahl, 1)
            }
        }
    }
}
