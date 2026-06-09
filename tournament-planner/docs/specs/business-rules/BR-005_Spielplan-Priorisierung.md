---
template-version: 1.0.0
linkservice-id: "urn:pfch:git:01932a4b-4c5d-7e6f-1a2b-3c4d5e6f7a8n:req/v1?anchor=true"
type: Business Rule
status: draft
completeness: Intermediate
responsible: "project-owner"
keywords: planning, priority, two-phase, coverage, fill, algorithm
ITAM-Application: TournamentPlanner
---

# [BR-005 – Spielplan-Priorisierung](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-4c5d-7e6f-1a2b-3c4d5e6f7a8n:req/v1)

---

## Description

> Diese Regel legt die verbindliche Prioritätsreihenfolge und den zweiphasigen Algorithmus fest, nach dem die Planungs-Engine Paarungen auf die Zellen des Spielplanrasters (Sportart × Zeitslot) verteilt.

---

## Rule

> Die Planungs-Engine arbeitet in zwei sequenziellen Phasen. Phase 1 hat Vorrang vor Phase 2; innerhalb jeder Phase gilt BR-004 (Zeitslot-Konflikt) als harte Bedingung, die niemals verletzt werden darf.

### Phase 1 – Abdeckung

> Für jede fehlende (Gruppe, Sportart)-Kombination sucht die Engine die beste verfügbare Zelle und platziert dort eine Paarung, die diese Gruppe enthält.

Innerhalb von Phase 1 gelten folgende Unterprioritäten:

| Priorität | Kriterium |
|---|---|
| 1 (höchste) | Die Paarung schließt für **beide** beteiligten Gruppen eine fehlende (Gruppe, Sportart)-Kombination (Synergie-Faktor = 2) |
| 2 | Die Paarung schließt nur für **eine** der beiden Gruppen eine fehlende Kombination (Synergie-Faktor = 1) |

Phase 1 endet, wenn alle erreichbaren (Gruppe, Sportart)-Kombinationen abgedeckt sind oder keine gültige Zelle mehr verfügbar ist.

### Phase 2 – Füllung

> Nach Abschluss von Phase 1 füllt die Engine verbleibende leere Zellen. Sportartwiederholungen sind dabei erlaubt.

Innerhalb von Phase 2 gilt:

| Priorität | Kriterium |
|---|---|
| 1 (höchste) | Paarungen mit weniger bisherigen Wiederholungen werden bevorzugt |

---

## Condition & Consequence

| | Description |
|---|---|
| **If** | Die Planungs-Engine den Spielplan berechnet (UC-002, Schritt 2) |
| **Then** | Phase 1 wird vollständig ausgeführt, bevor Phase 2 beginnt; BR-004 darf in keiner Phase verletzt werden |
| **Else** | Kein gültiger Spielplan kann erzeugt werden; die Applikation zeigt eine Fehlermeldung |

---

## Notes

- Die Engine startet mehrere Läufe mit unterschiedlichen Zufalls-Seeds und wählt den Plan mit dem besten `PlanBewertung`-Score.
- `PlanBewertung` priorisiert: (1) maximale Sportarten-Abdeckung, (2) maximale Füllrate, (3) minimale Gegnerwiederholungen.
- Wenn die Eingabedaten eine vollständige Abdeckung strukturell nicht erlauben (z. B. ungerade Gruppenzahl, zu wenige Zeitslots), wird die größtmögliche Abdeckung erzielt. BR-003 und UC-002 E1 beschreiben diesen Fehlerfall.

---

## Affected Data Objects

- [DO-005 – Spielplan](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-9c0d-7e1f-6a2b-8c3d4e5f6a7j:req/v1)
- [DO-006 – Paarung](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-0c1d-7e2f-7a3b-9c4d5e6f7a8k:req/v1)

## Dependencies & References

- **Applied Business Rules**: [BR-003 – Sportarten-Abdeckung](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-1c2d-7e3f-8a4b-0c5d6e7f8a9l:req/v1), [BR-004 – Gruppe-Zeitslot-Konflikt](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-2c3d-7e4f-9a5b-1c6d7e8f9a0m:req/v1)
- **Referenced by**: [UC-002 – Erstellen-Spielplan](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-8c9d-7e0f-5a1b-7c2d3e4f5a6i:req/v1)
