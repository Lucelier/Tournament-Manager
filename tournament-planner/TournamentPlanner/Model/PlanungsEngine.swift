import Foundation

enum PlanungsKonflikt: LocalizedError, Equatable {
    case zelleBelegt
    case gruppeBereitsImZeitslot(String)
    case gleicheGruppe

    var errorDescription: String? {
        switch self {
        case .zelleBelegt:
            return "Die Zielzelle ist bereits belegt."
        case .gruppeBereitsImZeitslot(let gruppe):
            return "\(gruppe) spielt in diesem Zeitslot bereits."
        case .gleicheGruppe:
            return "Eine Gruppe kann nicht gegen sich selbst spielen."
        }
    }
}

struct PlanungsEngine {
    func erstelleSpielplan(fuer turnier: Turnier) -> Spielplan {
        let gruppen = turnier.gruppen.sorted { $0.reihenfolge < $1.reihenfolge }
        let sportarten = turnier.sportarten.sorted { $0.reihenfolge < $1.reihenfolge }
        let zeitslots = turnier.zeitslots.sorted { $0.reihenfolge < $1.reihenfolge }

        guard gruppen.count >= 2, !sportarten.isEmpty, !zeitslots.isEmpty else {
            return Spielplan()
        }

        let versuche = max(80, min(500, gruppen.count * sportarten.count * zeitslots.count * 4))
        var besterPlan = bauePlan(gruppen: gruppen, sportarten: sportarten, zeitslots: zeitslots, zufaellig: false)
        var besteBewertung = bewertung(besterPlan)

        for _ in 0..<versuche {
            let plan = bauePlan(gruppen: gruppen, sportarten: sportarten, zeitslots: zeitslots, zufaellig: true)
            let planBewertung = bewertung(plan)
            if planBewertung > besteBewertung {
                besterPlan = plan
                besteBewertung = planBewertung
            }
        }

        return Spielplan(paarungen: besterPlan, nichtPlatziert: [])
    }

    func allePaarungen(gruppen: [Gruppe]) -> [Paarung] {
        guard gruppen.count >= 2 else { return [] }
        var paarungen: [Paarung] = []

        for indexA in gruppen.indices {
            for indexB in gruppen.index(after: indexA)..<gruppen.endIndex {
                paarungen.append(Paarung(gruppeAId: gruppen[indexA].id, gruppeBId: gruppen[indexB].id))
            }
        }

        return paarungen
    }

    func sportartenAbdeckung(in spielplan: Spielplan, gruppen: [Gruppe], sportarten: [Sportart]) -> [TeamSportKey] {
        let gespielt = Set(spielplan.paarungen.compactMap { paarung -> [TeamSportKey]? in
            guard let sportartId = paarung.sportartId else { return nil }
            return [
                TeamSportKey(gruppeId: paarung.gruppeAId, sportartId: sportartId),
                TeamSportKey(gruppeId: paarung.gruppeBId, sportartId: sportartId)
            ]
        }.flatMap { $0 })

        return gruppen.flatMap { gruppe in
            sportarten.map { sportart in TeamSportKey(gruppeId: gruppe.id, sportartId: sportart.id) }
        }.filter { gespielt.contains($0) }
    }

    func fehlendeSportarten(in spielplan: Spielplan, gruppen: [Gruppe], sportarten: [Sportart]) -> [TeamSportKey] {
        let gespielt = Set(sportartenAbdeckung(in: spielplan, gruppen: gruppen, sportarten: sportarten))
        return gruppen.flatMap { gruppe in
            sportarten.map { sportart in TeamSportKey(gruppeId: gruppe.id, sportartId: sportart.id) }
        }.filter { !gespielt.contains($0) }
    }

    func konflikt(
        fuer paarung: Paarung,
        sportartId: UUID,
        zeitslotId: UUID,
        in platziertePaarungen: [Paarung],
        gruppen: [Gruppe],
        ignorePaarungId: UUID?
    ) -> PlanungsKonflikt? {
        guard paarung.gruppeAId != paarung.gruppeBId else { return .gleicheGruppe }

        let relevantePaarungen = platziertePaarungen.filter { $0.id != ignorePaarungId }

        if relevantePaarungen.contains(where: { $0.sportartId == sportartId && $0.zeitslotId == zeitslotId }) {
            return .zelleBelegt
        }

        if let konfliktPaarung = relevantePaarungen.first(where: { andere in
            andere.zeitslotId == zeitslotId &&
            (andere.contains(gruppeId: paarung.gruppeAId) || andere.contains(gruppeId: paarung.gruppeBId))
        }) {
            let konfliktGruppeId = konfliktPaarung.contains(gruppeId: paarung.gruppeAId)
                ? paarung.gruppeAId
                : paarung.gruppeBId
            let name = gruppen.first(where: { $0.id == konfliktGruppeId })?.name ?? "Diese Gruppe"
            return .gruppeBereitsImZeitslot(name)
        }

        return nil
    }

    func verschiebe(
        paarungId: UUID,
        nachSportartId sportartId: UUID,
        zeitslotId: UUID,
        in spielplan: inout Spielplan,
        gruppen: [Gruppe]
    ) -> PlanungsKonflikt? {
        if let index = spielplan.paarungen.firstIndex(where: { $0.id == paarungId }) {
            var paarung = spielplan.paarungen[index]
            if let konflikt = konflikt(
                fuer: paarung,
                sportartId: sportartId,
                zeitslotId: zeitslotId,
                in: spielplan.paarungen,
                gruppen: gruppen,
                ignorePaarungId: paarung.id
            ) {
                return konflikt
            }

            paarung.sportartId = sportartId
            paarung.zeitslotId = zeitslotId
            spielplan.paarungen[index] = paarung
            return nil
        }

        if let index = spielplan.nichtPlatziert.firstIndex(where: { $0.id == paarungId }) {
            var paarung = spielplan.nichtPlatziert[index]
            if let konflikt = konflikt(
                fuer: paarung,
                sportartId: sportartId,
                zeitslotId: zeitslotId,
                in: spielplan.paarungen,
                gruppen: gruppen,
                ignorePaarungId: nil
            ) {
                return konflikt
            }

            paarung.sportartId = sportartId
            paarung.zeitslotId = zeitslotId
            spielplan.nichtPlatziert.remove(at: index)
            spielplan.paarungen.append(paarung)
        }

        return nil
    }

    // BR-005: Zweiphasiger Algorithmus.
    // Phase 1 – Abdeckung: fehlende (Gruppe, Sportart)-Kombinationen schliessen.
    // Phase 2 – Füllung: verbleibende leere Zellen mit minimalen Gegnerwiederholungen füllen.
    // Anschliessend Verbesserungs-Pass: wiederholte Paarungen werden durch ungespielte ersetzt,
    // sofern Abdeckung und Füllrate gleich bleiben.
    private func bauePlan(
        gruppen: [Gruppe],
        sportarten: [Sportart],
        zeitslots: [Zeitslot],
        zufaellig: Bool
    ) -> [Paarung] {
        var platziert: [Paarung] = []
        var teamsProZeitslot: [UUID: Set<UUID>] = [:]
        var teamSportZaehler: [TeamSportKey: Int] = [:]
        var belegteZellen: Set<ZellenSchluessel> = []
        var paarungZaehler: [PaarungsKey: Int] = [:]
        var gruppenSpiele: [UUID: Int] = [:]

        let alleGruppenPaarungen = allePaarungen(gruppen: zufaellig ? gruppen.shuffled() : gruppen)

        func istPlatzierbar(_ paarung: Paarung, sportartId: UUID, zeitslotId: UUID) -> Bool {
            let teamsInSlot = teamsProZeitslot[zeitslotId, default: []]
            return !teamsInSlot.contains(paarung.gruppeAId)
                && !teamsInSlot.contains(paarung.gruppeBId)
                && !belegteZellen.contains(ZellenSchluessel(sportartId: sportartId, zeitslotId: zeitslotId))
        }

        func platziere(_ paarung: Paarung, sportartId: UUID, zeitslotId: UUID) {
            // Frische ID, damit Wiederholungs-Platzierungen derselben Paarung eindeutig bleiben.
            let p = Paarung(
                gruppeAId: paarung.gruppeAId,
                gruppeBId: paarung.gruppeBId,
                sportartId: sportartId,
                zeitslotId: zeitslotId
            )
            platziert.append(p)
            teamsProZeitslot[zeitslotId, default: []].insert(p.gruppeAId)
            teamsProZeitslot[zeitslotId, default: []].insert(p.gruppeBId)
            teamSportZaehler[TeamSportKey(gruppeId: p.gruppeAId, sportartId: sportartId), default: 0] += 1
            teamSportZaehler[TeamSportKey(gruppeId: p.gruppeBId, sportartId: sportartId), default: 0] += 1
            belegteZellen.insert(ZellenSchluessel(sportartId: sportartId, zeitslotId: zeitslotId))
            paarungZaehler[PaarungsKey(p), default: 0] += 1
            gruppenSpiele[p.gruppeAId, default: 0] += 1
            gruppenSpiele[p.gruppeBId, default: 0] += 1
        }

        // Phase 1 – Abdeckung (BR-005)
        var abdeckungsLuecken = gruppen.flatMap { gruppe in
            sportarten.map { sportart in TeamSportKey(gruppeId: gruppe.id, sportartId: sportart.id) }
        }
        if zufaellig { abdeckungsLuecken.shuffle() }

        let verfuegbareZeitslots = zufaellig ? zeitslots.shuffled() : zeitslots

        for luecke in abdeckungsLuecken {
            guard teamSportZaehler[luecke, default: 0] == 0 else { continue }

            var besteOption: (paarung: Paarung, zeitslotId: UUID, synergie: Int, wiederholungen: Int)?

            outerLoop: for zeitslot in verfuegbareZeitslots {
                for paarung in alleGruppenPaarungen where paarung.contains(gruppeId: luecke.gruppeId) {
                    guard istPlatzierbar(paarung, sportartId: luecke.sportartId, zeitslotId: zeitslot.id) else { continue }
                    let synergie = [
                        TeamSportKey(gruppeId: paarung.gruppeAId, sportartId: luecke.sportartId),
                        TeamSportKey(gruppeId: paarung.gruppeBId, sportartId: luecke.sportartId)
                    ].filter { teamSportZaehler[$0, default: 0] == 0 }.count
                    let wiederholungen = paarungZaehler[PaarungsKey(paarung), default: 0]
                    let istBesser = besteOption == nil
                        || synergie > besteOption!.synergie
                        || (synergie == besteOption!.synergie && wiederholungen < besteOption!.wiederholungen)
                    if istBesser {
                        besteOption = (paarung, zeitslot.id, synergie, wiederholungen)
                    }
                    if synergie == 2 && wiederholungen == 0 { break outerLoop }
                }
            }

            if let option = besteOption {
                platziere(option.paarung, sportartId: luecke.sportartId, zeitslotId: option.zeitslotId)
            }
        }

        // Phase 2 – Füllung (BR-005): am stärksten eingeschränkte Zellen zuerst,
        // Kandidaten nach wenigsten Gegnerwiederholungen, dann geringster Gesamtspielzahl.
        var offeneZellen: [(sportartId: UUID, zeitslotId: UUID)] = {
            let basis = zeitslots.flatMap { z in sportarten.map { s in (sportartId: s.id, zeitslotId: z.id) } }
            let frei = basis.filter { !belegteZellen.contains(ZellenSchluessel(sportartId: $0.sportartId, zeitslotId: $0.zeitslotId)) }
            return zufaellig ? frei.shuffled() : frei
        }()

        while !offeneZellen.isEmpty {
            var besteWahl: (zellenIndex: Int, kandidaten: [Paarung])?
            var unbelegbareIndizes: [Int] = []

            for (index, zelle) in offeneZellen.enumerated() {
                let kandidaten = alleGruppenPaarungen.filter {
                    istPlatzierbar($0, sportartId: zelle.sportartId, zeitslotId: zelle.zeitslotId)
                }
                if kandidaten.isEmpty {
                    unbelegbareIndizes.append(index)
                } else if besteWahl == nil || kandidaten.count < besteWahl!.kandidaten.count {
                    besteWahl = (index, kandidaten)
                }
            }

            guard let wahl = besteWahl else { break }
            let zelle = offeneZellen[wahl.zellenIndex]
            let kandidat = wahl.kandidaten.min { links, rechts in
                let wiederholungenLinks = paarungZaehler[PaarungsKey(links), default: 0]
                let wiederholungenRechts = paarungZaehler[PaarungsKey(rechts), default: 0]
                if wiederholungenLinks != wiederholungenRechts {
                    return wiederholungenLinks < wiederholungenRechts
                }
                let spieleLinks = gruppenSpiele[links.gruppeAId, default: 0] + gruppenSpiele[links.gruppeBId, default: 0]
                let spieleRechts = gruppenSpiele[rechts.gruppeAId, default: 0] + gruppenSpiele[rechts.gruppeBId, default: 0]
                return spieleLinks < spieleRechts
            }!
            platziere(kandidat, sportartId: zelle.sportartId, zeitslotId: zelle.zeitslotId)

            // Belegte und dauerhaft unbelegbare Zellen entfernen (Constraints wachsen nur monoton).
            for index in (unbelegbareIndizes + [wahl.zellenIndex]).sorted(by: >) {
                offeneZellen.remove(at: index)
            }
        }

        // Verbesserungs-Pass (BR-005): wiederholte Paarungen durch noch ungespielte ersetzen,
        // sofern Sportarten-Abdeckung und Füllrate unverändert bleiben.
        var verbessert = true
        while verbessert {
            verbessert = false

            for index in platziert.indices {
                let bisherige = platziert[index]
                guard paarungZaehler[PaarungsKey(bisherige), default: 0] >= 2,
                      let sportartId = bisherige.sportartId,
                      let zeitslotId = bisherige.zeitslotId else { continue }

                let teamsInSlot = teamsProZeitslot[zeitslotId, default: []]

                let ersatz = alleGruppenPaarungen.first { kandidat in
                    guard paarungZaehler[PaarungsKey(kandidat), default: 0] == 0 else { return false }
                    let istFrei = { (gruppeId: UUID) -> Bool in
                        gruppeId == bisherige.gruppeAId
                            || gruppeId == bisherige.gruppeBId
                            || !teamsInSlot.contains(gruppeId)
                    }
                    guard istFrei(kandidat.gruppeAId), istFrei(kandidat.gruppeBId) else { return false }

                    // Abdeckung darf nicht sinken (Priorität 1 vor Priorität 2).
                    var delta: [TeamSportKey: Int] = [:]
                    delta[TeamSportKey(gruppeId: bisherige.gruppeAId, sportartId: sportartId), default: 0] -= 1
                    delta[TeamSportKey(gruppeId: bisherige.gruppeBId, sportartId: sportartId), default: 0] -= 1
                    delta[TeamSportKey(gruppeId: kandidat.gruppeAId, sportartId: sportartId), default: 0] += 1
                    delta[TeamSportKey(gruppeId: kandidat.gruppeBId, sportartId: sportartId), default: 0] += 1
                    return !delta.contains { schluessel, differenz in
                        let bisher = teamSportZaehler[schluessel, default: 0]
                        return bisher > 0 && bisher + differenz == 0
                    }
                }

                guard let neu = ersatz else { continue }

                paarungZaehler[PaarungsKey(bisherige), default: 0] -= 1
                gruppenSpiele[bisherige.gruppeAId, default: 0] -= 1
                gruppenSpiele[bisherige.gruppeBId, default: 0] -= 1
                teamsProZeitslot[zeitslotId, default: []].subtract([bisherige.gruppeAId, bisherige.gruppeBId])
                teamSportZaehler[TeamSportKey(gruppeId: bisherige.gruppeAId, sportartId: sportartId), default: 0] -= 1
                teamSportZaehler[TeamSportKey(gruppeId: bisherige.gruppeBId, sportartId: sportartId), default: 0] -= 1

                let ersatzPaarung = Paarung(
                    gruppeAId: neu.gruppeAId,
                    gruppeBId: neu.gruppeBId,
                    sportartId: sportartId,
                    zeitslotId: zeitslotId
                )
                platziert[index] = ersatzPaarung
                paarungZaehler[PaarungsKey(ersatzPaarung), default: 0] += 1
                gruppenSpiele[ersatzPaarung.gruppeAId, default: 0] += 1
                gruppenSpiele[ersatzPaarung.gruppeBId, default: 0] += 1
                teamsProZeitslot[zeitslotId, default: []].formUnion([ersatzPaarung.gruppeAId, ersatzPaarung.gruppeBId])
                teamSportZaehler[TeamSportKey(gruppeId: ersatzPaarung.gruppeAId, sportartId: sportartId), default: 0] += 1
                teamSportZaehler[TeamSportKey(gruppeId: ersatzPaarung.gruppeBId, sportartId: sportartId), default: 0] += 1

                verbessert = true
            }
        }

        return platziert.sorted { links, rechts in
            let zeitslotLinks = zeitslots.firstIndex(where: { $0.id == links.zeitslotId }) ?? 0
            let zeitslotRechts = zeitslots.firstIndex(where: { $0.id == rechts.zeitslotId }) ?? 0
            if zeitslotLinks != zeitslotRechts {
                return zeitslotLinks < zeitslotRechts
            }
            let sportLinks = sportarten.firstIndex(where: { $0.id == links.sportartId }) ?? 0
            let sportRechts = sportarten.firstIndex(where: { $0.id == rechts.sportartId }) ?? 0
            return sportLinks < sportRechts
        }
    }

    private func bewertung(_ paarungen: [Paarung]) -> PlanBewertung {
        var teamSportGespielt: Set<TeamSportKey> = []
        var paarungZaehler: [PaarungsKey: Int] = [:]

        for paarung in paarungen {
            if let sportartId = paarung.sportartId {
                teamSportGespielt.insert(TeamSportKey(gruppeId: paarung.gruppeAId, sportartId: sportartId))
                teamSportGespielt.insert(TeamSportKey(gruppeId: paarung.gruppeBId, sportartId: sportartId))
            }
            paarungZaehler[PaarungsKey(paarung), default: 0] += 1
        }

        let gegnerWiederholungen = paarungZaehler.values.reduce(0) { summe, anzahl in
            summe + max(0, anzahl - 1)
        }

        return PlanBewertung(
            teamSportAbdeckung: teamSportGespielt.count,
            gefuellteSlots: paarungen.count,
            gegnerWiederholungen: gegnerWiederholungen
        )
    }
}

struct TeamSportKey: Codable, Hashable {
    let gruppeId: UUID
    let sportartId: UUID
}

private struct ZellenSchluessel: Hashable {
    let sportartId: UUID
    let zeitslotId: UUID
}

private struct PaarungsKey: Hashable {
    let first: UUID
    let second: UUID

    init(_ paarung: Paarung) {
        let sortiert = [paarung.gruppeAId.uuidString, paarung.gruppeBId.uuidString].sorted()
        first = UUID(uuidString: sortiert[0]) ?? paarung.gruppeAId
        second = UUID(uuidString: sortiert[1]) ?? paarung.gruppeBId
    }
}

private struct PlanBewertung: Comparable {
    let teamSportAbdeckung: Int
    let gefuellteSlots: Int
    let gegnerWiederholungen: Int

    static func < (links: PlanBewertung, rechts: PlanBewertung) -> Bool {
        if links.teamSportAbdeckung != rechts.teamSportAbdeckung {
            return links.teamSportAbdeckung < rechts.teamSportAbdeckung
        }
        if links.gegnerWiederholungen != rechts.gegnerWiederholungen {
            return links.gegnerWiederholungen > rechts.gegnerWiederholungen
        }
        return links.gefuellteSlots < rechts.gefuellteSlots
    }
}
