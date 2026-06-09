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

    private func bauePlan(
        gruppen: [Gruppe],
        sportarten: [Sportart],
        zeitslots: [Zeitslot],
        zufaellig: Bool
    ) -> [Paarung] {
        var platziert: [Paarung] = []
        var teamsProZeitslot: [UUID: Set<UUID>] = [:]
        var teamSportGespielt: Set<TeamSportKey> = []
        var paarungZaehler: [PaarungsKey: Int] = [:]

        let basisZellen = zeitslots.flatMap { zeitslot in
            sportarten.map { sportart in Zelle(sportart: sportart, zeitslot: zeitslot) }
        }
        let zellen = zufaellig ? basisZellen.shuffled() : basisZellen

        for zelle in zellen {
            let kandidaten = allePaarungen(gruppen: zufaellig ? gruppen.shuffled() : gruppen).enumerated().compactMap { index, paarung -> BewerteterKandidat? in
                let teamsInSlot = teamsProZeitslot[zelle.zeitslot.id, default: []]
                guard !teamsInSlot.contains(paarung.gruppeAId), !teamsInSlot.contains(paarung.gruppeBId) else {
                    return nil
                }

                let sportA = TeamSportKey(gruppeId: paarung.gruppeAId, sportartId: zelle.sportart.id)
                let sportB = TeamSportKey(gruppeId: paarung.gruppeBId, sportartId: zelle.sportart.id)
                let neueSportarten = [sportA, sportB].filter { !teamSportGespielt.contains($0) }.count
                let wiederholungen = paarungZaehler[PaarungsKey(paarung), default: 0]
                return BewerteterKandidat(
                    paarung: paarung,
                    neueSportarten: neueSportarten,
                    wiederholungen: wiederholungen,
                    reihenfolge: index
                )
            }

            guard let kandidat = kandidaten.min(by: { links, rechts in
                if links.neueSportarten != rechts.neueSportarten {
                    return links.neueSportarten > rechts.neueSportarten
                }
                if links.wiederholungen != rechts.wiederholungen {
                    return links.wiederholungen < rechts.wiederholungen
                }
                return links.reihenfolge < rechts.reihenfolge
            }) else {
                continue
            }

            var paarung = kandidat.paarung
            paarung.sportartId = zelle.sportart.id
            paarung.zeitslotId = zelle.zeitslot.id
            platziert.append(paarung)

            teamsProZeitslot[zelle.zeitslot.id, default: []].insert(paarung.gruppeAId)
            teamsProZeitslot[zelle.zeitslot.id, default: []].insert(paarung.gruppeBId)
            teamSportGespielt.insert(TeamSportKey(gruppeId: paarung.gruppeAId, sportartId: zelle.sportart.id))
            teamSportGespielt.insert(TeamSportKey(gruppeId: paarung.gruppeBId, sportartId: zelle.sportart.id))
            paarungZaehler[PaarungsKey(paarung), default: 0] += 1
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

private struct PaarungsKey: Hashable {
    let first: UUID
    let second: UUID

    init(_ paarung: Paarung) {
        let sortiert = [paarung.gruppeAId.uuidString, paarung.gruppeBId.uuidString].sorted()
        first = UUID(uuidString: sortiert[0]) ?? paarung.gruppeAId
        second = UUID(uuidString: sortiert[1]) ?? paarung.gruppeBId
    }
}

private struct Zelle {
    let sportart: Sportart
    let zeitslot: Zeitslot
}

private struct BewerteterKandidat {
    let paarung: Paarung
    let neueSportarten: Int
    let wiederholungen: Int
    let reihenfolge: Int
}

private struct PlanBewertung: Comparable {
    let teamSportAbdeckung: Int
    let gefuellteSlots: Int
    let gegnerWiederholungen: Int

    static func < (links: PlanBewertung, rechts: PlanBewertung) -> Bool {
        if links.teamSportAbdeckung != rechts.teamSportAbdeckung {
            return links.teamSportAbdeckung < rechts.teamSportAbdeckung
        }
        if links.gefuellteSlots != rechts.gefuellteSlots {
            return links.gefuellteSlots < rechts.gefuellteSlots
        }
        return links.gegnerWiederholungen > rechts.gegnerWiederholungen
    }
}
