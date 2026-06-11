import XCTest
@testable import TournamentPlanner

final class PlanungsEngineTests: XCTestCase {

    // BR-004 + BR-003 + BR-005: Smoke-Test gemäss Akzeptanzkriterium in UC-002
    func testVierGruppenSpielenJedeSportartMindestensEinmalOhneZeitslotKonflikt() {
        let turnier = Turnier(
            name: "Smoke",
            gruppen: ["A", "B", "C", "D"].enumerated().map { Gruppe(name: $0.element, reihenfolge: $0.offset) },
            sportarten: ["Fussball", "Volleyball", "Unihockey"].enumerated().map { Sportart(name: $0.element, reihenfolge: $0.offset) },
            zeitslots: ["09:00", "09:30", "10:00", "10:30"].enumerated().map { Zeitslot(startzeit: $0.element, reihenfolge: $0.offset) }
        )

        let spielplan = PlanungsEngine().erstelleSpielplan(fuer: turnier)

        XCTAssertEqual(spielplan.paarungen.count, 8)
        XCTAssertTrue(spielplan.nichtPlatziert.isEmpty)

        for zeitslot in turnier.zeitslots {
            let gruppenInZeile = spielplan.paarungen
                .filter { $0.zeitslotId == zeitslot.id }
                .flatMap { [$0.gruppeAId, $0.gruppeBId] }
            XCTAssertEqual(gruppenInZeile.count, Set(gruppenInZeile).count, "Zeitslot-Konflikt in \(zeitslot.anzeigeText)")
        }

        for gruppe in turnier.gruppen {
            for sportart in turnier.sportarten {
                let anzahl = spielplan.paarungen.filter { paarung in
                    paarung.sportartId == sportart.id && paarung.contains(gruppeId: gruppe.id)
                }.count
                XCTAssertGreaterThanOrEqual(anzahl, 1, "Gruppe \(gruppe.name) hat \(sportart.name) nicht gespielt")
            }
        }
    }

    // BR-005 Phase 2: Füllung hat Priorität nach Phase-1-Abdeckung
    func testPhase2FuelltZellenNachAbgeschlossenerAbdeckung() {
        let turnier = Turnier(
            name: "Fuellung",
            gruppen: ["A", "B", "C", "D"].enumerated().map { Gruppe(name: $0.element, reihenfolge: $0.offset) },
            sportarten: ["Fussball", "Volleyball"].enumerated().map { Sportart(name: $0.element, reihenfolge: $0.offset) },
            zeitslots: ["09:00", "09:30", "10:00", "10:30"].enumerated().map { Zeitslot(startzeit: $0.element, reihenfolge: $0.offset) }
        )

        let spielplan = PlanungsEngine().erstelleSpielplan(fuer: turnier)

        XCTAssertEqual(spielplan.paarungen.count, 8)

        // Phase 2 muss Sportart-Wiederholungen erzeugt haben (mehr Spiele als nötig für Abdeckung)
        let wiederholteTeamSportarten = turnier.gruppen.flatMap { gruppe in
            turnier.sportarten.map { sportart in
                spielplan.paarungen.filter { paarung in
                    paarung.sportartId == sportart.id && paarung.contains(gruppeId: gruppe.id)
                }.count
            }
        }
        XCTAssertTrue(wiederholteTeamSportarten.contains { $0 > 1 }, "Phase 2 hätte Sportart-Wiederholungen erzeugen müssen")
    }

    // BR-005 Phase 1 Synergie: Bei geradzahliger Gruppe maximiert Phase 1 den Synergie-Faktor (beide Gruppen profitieren)
    func testPhase1MaximiertSynergieBeiGeradzahligenGruppen() {
        // 4 Gruppen, 2 Sportarten, 2 Zeitslots → exakt 4 Zellen.
        // Phase 1 muss alle 8 (Gruppe, Sportart)-Paare abdecken (Synergie = 2 pro Platzierung).
        // Phase 2 hat danach keine freien Zellen mehr.
        let turnier = Turnier(
            name: "Synergie",
            gruppen: ["A", "B", "C", "D"].enumerated().map { Gruppe(name: $0.element, reihenfolge: $0.offset) },
            sportarten: ["Fussball", "Volleyball"].enumerated().map { Sportart(name: $0.element, reihenfolge: $0.offset) },
            zeitslots: ["09:00", "09:30"].enumerated().map { Zeitslot(startzeit: $0.element, reihenfolge: $0.offset) }
        )

        let spielplan = PlanungsEngine().erstelleSpielplan(fuer: turnier)

        XCTAssertEqual(spielplan.paarungen.count, 4)

        for zeitslot in turnier.zeitslots {
            let gruppenInZeile = spielplan.paarungen
                .filter { $0.zeitslotId == zeitslot.id }
                .flatMap { [$0.gruppeAId, $0.gruppeBId] }
            XCTAssertEqual(gruppenInZeile.count, Set(gruppenInZeile).count, "Zeitslot-Konflikt in \(zeitslot.anzeigeText)")
        }

        // Vollständige Abdeckung: Phase 1 hat alle Lücken über Synergie-2-Platzierungen geschlossen
        for gruppe in turnier.gruppen {
            for sportart in turnier.sportarten {
                XCTAssertGreaterThanOrEqual(
                    spielplan.paarungen.filter { $0.sportartId == sportart.id && $0.contains(gruppeId: gruppe.id) }.count,
                    1,
                    "Gruppe \(gruppe.name) hat \(sportart.name) nicht gespielt"
                )
            }
        }
    }

    // BR-003 + BR-005: Ungerade Gruppenzahl — Phase 1 maximiert erreichbare Abdeckung
    func testUngeradeGruppenzahlMaximiertSportartenAbdeckung() {
        let turnier = Turnier(
            name: "Knapp",
            gruppen: ["A", "B", "C", "D", "E"].enumerated().map { Gruppe(name: $0.element, reihenfolge: $0.offset) },
            sportarten: ["Fussball", "Volleyball"].enumerated().map { Sportart(name: $0.element, reihenfolge: $0.offset) },
            zeitslots: ["09:00", "09:30"].enumerated().map { Zeitslot(startzeit: $0.element, reihenfolge: $0.offset) }
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

    // BR-005 Priorität 2: Gegnerwiederholungen werden minimiert.
    // 6 Gruppen, 2 Sportarten, 5 Zeitslots → 10 Spiele bei 15 möglichen Paarungen:
    // ein Plan ohne jede Gegnerwiederholung ist erreichbar.
    func testGegnerwiederholungenWerdenMinimiert() {
        let turnier = Turnier(
            name: "Verteilung",
            gruppen: ["A", "B", "C", "D", "E", "F"].enumerated().map { Gruppe(name: $0.element, reihenfolge: $0.offset) },
            sportarten: ["Fussball", "Volleyball"].enumerated().map { Sportart(name: $0.element, reihenfolge: $0.offset) },
            zeitslots: ["09:00", "09:30", "10:00", "10:30", "11:00"].enumerated().map { Zeitslot(startzeit: $0.element, reihenfolge: $0.offset) }
        )

        let spielplan = PlanungsEngine().erstelleSpielplan(fuer: turnier)

        XCTAssertEqual(spielplan.paarungen.count, 10, "Alle 10 Zellen müssen belegt sein")
        XCTAssertEqual(
            Set(spielplan.paarungen.map(\.paarungsKey)).count,
            spielplan.paarungen.count,
            "Keine Paarung darf sich wiederholen, solange ungespielte Paarungen verfügbar sind"
        )
    }

    // BR-004: Manuelles Verschieben lehnt belegte Zellen und Zeitslot-Konflikte ab
    func testVerschiebenMeldetKonflikte() {
        let gruppen = ["A", "B", "C"].enumerated().map { Gruppe(name: $0.element, reihenfolge: $0.offset) }
        let fussball = Sportart(name: "Fussball", reihenfolge: 0)
        let volleyball = Sportart(name: "Volleyball", reihenfolge: 1)
        let zeitslots = ["09:00", "09:30"].enumerated().map { Zeitslot(startzeit: $0.element, reihenfolge: $0.offset) }

        // Gültiger Ausgangsplan: AB in (Fussball, Slot 1), AC in (Fussball, Slot 2)
        let paarungAB = Paarung(gruppeAId: gruppen[0].id, gruppeBId: gruppen[1].id, sportartId: fussball.id, zeitslotId: zeitslots[0].id)
        let paarungAC = Paarung(gruppeAId: gruppen[0].id, gruppeBId: gruppen[2].id, sportartId: fussball.id, zeitslotId: zeitslots[1].id)
        var spielplan = Spielplan(paarungen: [paarungAB, paarungAC])
        let engine = PlanungsEngine()

        // Zielzelle belegt
        XCTAssertEqual(
            engine.verschiebe(paarungId: paarungAC.id, nachSportartId: fussball.id, zeitslotId: zeitslots[0].id, in: &spielplan, gruppen: gruppen),
            .zelleBelegt
        )

        // Gruppe A spielt im Ziel-Zeitslot bereits (freie Zelle Volleyball/Slot 1)
        XCTAssertEqual(
            engine.verschiebe(paarungId: paarungAC.id, nachSportartId: volleyball.id, zeitslotId: zeitslots[0].id, in: &spielplan, gruppen: gruppen),
            .gruppeBereitsImZeitslot("A")
        )

        // Verschieben auf die eigene Position ist erlaubt (ignorePaarungId)
        XCTAssertNil(
            engine.verschiebe(paarungId: paarungAB.id, nachSportartId: fussball.id, zeitslotId: zeitslots[0].id, in: &spielplan, gruppen: gruppen)
        )

        // Gültiges Verschieben in freie, konfliktfreie Zelle
        XCTAssertNil(
            engine.verschiebe(paarungId: paarungAC.id, nachSportartId: volleyball.id, zeitslotId: zeitslots[1].id, in: &spielplan, gruppen: gruppen)
        )
        XCTAssertEqual(spielplan.paarungen.first(where: { $0.id == paarungAC.id })?.sportartId, volleyball.id)
    }

    // BR-005: Gegnerwiederholungen sind erlaubt, wenn Phase 1 (Abdeckung) es erfordert
    func testGegnerDuerfenSichWiederholenWennSportartenPrioritaetDasErfordert() {
        let turnier = Turnier(
            name: "Wiederholung",
            gruppen: ["A", "B"].enumerated().map { Gruppe(name: $0.element, reihenfolge: $0.offset) },
            sportarten: ["Fussball", "Volleyball", "Unihockey"].enumerated().map { Sportart(name: $0.element, reihenfolge: $0.offset) },
            zeitslots: ["09:00", "09:30", "10:00"].enumerated().map { Zeitslot(startzeit: $0.element, reihenfolge: $0.offset) }
        )

        let spielplan = PlanungsEngine().erstelleSpielplan(fuer: turnier)

        XCTAssertEqual(spielplan.paarungen.count, 3)
        XCTAssertEqual(Set(spielplan.paarungen.map(\.paarungsKey)).count, 1, "Mit 2 Gruppen ist nur eine Paarung möglich")

        for gruppe in turnier.gruppen {
            for sportart in turnier.sportarten {
                let anzahl = spielplan.paarungen.filter { paarung in
                    paarung.sportartId == sportart.id && paarung.contains(gruppeId: gruppe.id)
                }.count
                XCTAssertGreaterThanOrEqual(anzahl, 1, "Gruppe \(gruppe.name) hat \(sportart.name) nicht gespielt")
            }
        }
    }
}
