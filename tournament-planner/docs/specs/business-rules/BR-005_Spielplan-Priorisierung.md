---

template-version: 1.0.0
linkservice-id: "urn:pfch:git:01932a4b-4c5d-7e6f-1a2b-3c4d5e6f7a8n:req/v1?anchor=true"
type: Business Rule
status: draft
completeness: Intermediate
responsible: "project-owner"
keywords: planning, priority, coverage, opponent-diversity, fill, algorithm
ITAM-Application: TournamentPlanner
-----------------------------------

# [BR-005 – Spielplan-Priorisierung](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-4c5d-7e6f-1a2b-3c4d5e6f7a8n:req/v1)

---

## Description

> Diese Regel legt die verbindliche Prioritätsreihenfolge fest, nach der die Planungs-Engine Paarungen auf die Zellen des Spielplanrasters (Sportart × Zeitslot) verteilt und bewertet.

---

## Rule

> Die Planungs-Engine optimiert den Spielplan nach einer festen Prioritätsreihenfolge. Eine niedrigere Priorität darf nur verbessert werden, wenn dadurch keine Lösung mit höherer Priorität verschlechtert wird. Die Prioritäten gelten für den Vergleich vollständiger Spielpläne (`PlanBewertung`); innerhalb der Planerstellung ist die Belegung aller regelkonform belegbaren Zellen verpflichtend (siehe Phase 2).

Dabei gilt BR-004 (Zeitslot-Konflikt) jederzeit als harte Bedingung und darf niemals verletzt werden.

### Prioritäten

| Priorität   | Ziel                                                             |
| ----------- | ---------------------------------------------------------------- |
| 1 (höchste) | Jede Gruppe soll jede Sportart mindestens einmal spielen         |
| 2           | Gegnerwiederholungen sollen minimiert werden                     |
| 3           | Möglichst viele Felder des Spielplanrasters sollen belegt werden |

### Phase 1 – Sportarten-Abdeckung

> Die Engine versucht zunächst, für jede Gruppe eine Teilnahme an jeder Sportart zu ermöglichen. Hierzu werden Paarungen bevorzugt, welche möglichst viele noch fehlende (Gruppe, Sportart)-Kombinationen gleichzeitig erfüllen.

Innerhalb von Phase 1 gelten folgende Unterprioritäten:

| Priorität | Kriterium                                                                                       |
| --------- | ----------------------------------------------------------------------------------------------- |
| 1         | Die Paarung schließt für beide beteiligten Gruppen eine fehlende (Gruppe, Sportart)-Kombination |
| 2         | Die Paarung schließt für genau eine Gruppe eine fehlende (Gruppe, Sportart)-Kombination         |
| 3         | Die Paarung verursacht möglichst wenige Gegnerwiederholungen                                    |

Phase 1 endet, wenn keine weitere Verbesserung der Sportarten-Abdeckung möglich ist.

### Phase 2 – Optimierung und Füllung

> Nach Abschluss von Phase 1 werden verbleibende freie Zellen belegt.

Innerhalb von Phase 2 gelten folgende Unterprioritäten:

| Priorität | Kriterium                                         |
| --------- | ------------------------------------------------- |
| 1         | Paarungen mit den geringsten Gegnerwiederholungen |
| 2         | Höchstmögliche Belegung freier Zellen             |

Sportartwiederholungen sind in dieser Phase zulässig.

Gegnerwiederholungen sind in dieser Phase ebenfalls zulässig: Jede regelkonform belegbare Zelle muss belegt werden; eine Zelle darf nicht leer bleiben, um eine Gegnerwiederholung zu vermeiden. Die dabei entstehenden Gegnerwiederholungen werden minimiert.

---

## Condition & Consequence

|          | Description                                                                                                       |
| -------- | ----------------------------------------------------------------------------------------------------------------- |
| **If**   | Die Planungs-Engine den Spielplan berechnet (UC-002, Schritt 2)                                                   |
| **Then** | Die Prioritäten werden in der definierten Reihenfolge angewendet; BR-004 darf zu keinem Zeitpunkt verletzt werden |
| **Else** | Kein gültiger Spielplan kann erzeugt werden; die Applikation zeigt eine Fehlermeldung                             |

---

## Notes

* Die Engine startet mehrere Läufe mit unterschiedlichen Zufalls-Seeds und wählt den Plan mit dem besten `PlanBewertung`-Score.
* `PlanBewertung` priorisiert:

  1. maximale Sportarten-Abdeckung pro Gruppe,
  2. minimale Gegnerwiederholungen,
  3. maximale Füllrate des Spielplans.
* Wenn die Eingabedaten eine vollständige Sportarten-Abdeckung strukturell nicht erlauben (z. B. zu wenige Zeitslots oder ungünstige Gruppenzahlen), wird die bestmögliche Abdeckung erzielt.
* Erst wenn mehrere Pläne hinsichtlich der Sportarten-Abdeckung gleichwertig sind, wird die Anzahl der Gegnerwiederholungen als Vergleichskriterium verwendet.
* Erst wenn auch die Gegnerwiederholungen gleichwertig sind, wird die Füllrate als Vergleichskriterium verwendet.
* Die Priorisierung ist strikt lexikographisch und bezieht sich auf den Vergleich vollständiger Pläne. Die Belegungspflicht in Phase 2 gilt dabei nicht als Verletzung: Innerhalb eines Plans werden stets alle belegbaren Zellen belegt; minimiert werden die dabei entstehenden Gegnerwiederholungen.
* Die Engine darf den fertigen Plan lokal verbessern (z. B. eine wiederholte Paarung durch eine noch ungespielte ersetzen), sofern Sportarten-Abdeckung und Füllrate dadurch nicht sinken.

---

## Affected Data Objects

* [DO-005 – Spielplan](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-9c0d-7e1f-6a2b-8c3d4e5f6a7j:req/v1)
* [DO-006 – Paarung](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-0c1d-7e2f-7a3b-9c4d5e6f7a8k:req/v1)

## Dependencies & References

* **Applied Business Rules**: [BR-003 – Sportarten-Abdeckung](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-1c2d-7e3f-8a4b-0c5d6e7f8a9l:req/v1), [BR-004 – Gruppe-Zeitslot-Konflikt](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-2c3d-7e4f-9a5b-1c6d7e8f9a0m:req/v1)
* **Referenced by**: [UC-002 – Erstellen-Spielplan](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-8c9d-7e0f-5a1b-7c2d3e4f5a6i:req/v1)
