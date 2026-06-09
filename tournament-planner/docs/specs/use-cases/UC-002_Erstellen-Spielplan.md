---
template-version: 1.0.0
linkservice-id: "urn:pfch:git:01932a4b-8c9d-7e0f-5a1b-7c2d3e4f5a6i:req/v1?anchor=true"
type: Use Case
status: draft
completeness: Intermediate
responsible: "project-owner"
keywords: schedule, algorithm, priorities, sports, conflicts
ITAM-Application: TournamentPlanner
---

# [UC-002 – Erstellen-Spielplan](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-8c9d-7e0f-5a1b-7c2d3e4f5a6i:req/v1)

---

## Brief Description

> Der Turnierleiter möchte automatisch einen priorisierten Spielplan generieren, bei dem Zeitslot-Konflikte ausgeschlossen sind und jede Gruppe möglichst jede Sportart mindestens einmal spielt.

---

## Actors

| Actor | Type | Role |
|---|---|---|
| Turnierleiter | `Human` | Löst die Spielplanerstellung aus und prüft das Ergebnis |
| Planungs-Engine | `System` | Berechnet die Paarungen nach priorisierten Planungsregeln |

---

## Context & Background

> Der Spielplan ist ein zweidimensionales Raster: Die X-Achse zeigt die Sportarten, die Y-Achse die Zeitslots. Jede Zelle enthält eine Begegnung zweier Gruppen. Die Planungs-Engine optimiert den Spielplan nach einem zweiphasigen Verfahren gemäß [BR-005 – Spielplan-Priorisierung](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-4c5d-7e6f-1a2b-3c4d5e6f7a8n:req/v1): In Phase 1 wird die Sportarten-Abdeckung maximiert (jede Gruppe soll jede Sportart mindestens einmal spielen), in Phase 2 werden verbleibende Zellen aufgefüllt. Zeitslot-Konflikte sind in beiden Phasen verboten (BR-004).

---

## Preconditions

- Ein `Turnier`-Objekt mit mindestens 2 Gruppen, mindestens 1 Sportart und mindestens 1 Zeitslot ist im Applikationsspeicher vorhanden (Postcondition von UC-001).

---

## Trigger

> Der Turnierleiter klickt auf «Spielplan erstellen» im Setup-Screen oder «Neu berechnen» im Spielplan-Screen.

---

## Description

1. Die Planungs-Engine berechnet alle möglichen Gruppenpaarungen als Kandidaten.
2. Die Planungs-Engine verteilt Kandidaten auf die verfügbaren Zellen des Rasters (Sportart × Zeitslot) gemäß dem zweiphasigen Verfahren in [BR-005 – Spielplan-Priorisierung](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-4c5d-7e6f-1a2b-3c4d5e6f7a8n:req/v1); Zeitslot-Konflikte sind in beiden Phasen ausgeschlossen ([BR-004](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-2c3d-7e4f-9a5b-1c6d7e8f9a0m:req/v1)).
3. Die Applikation zeigt das befüllte Spielplanraster an: Spalten = Sportarten, Zeilen = Zeitslots, Zellinhalt = «Gruppe A vs. Gruppe B».
4. Freie Zellen (keine Paarung zugewiesen) werden als leer dargestellt.
5. Der Turnierleiter prüft den Spielplan visuell.
6. Der Turnierleiter kann einzelne Paarungen manuell in andere Zellen verschieben *(→ A1)*.
7. Der Turnierleiter bestätigt den Spielplan oder exportiert ihn *(→ UC-003)*.

---

## Alternative Flows

### A1 – Paarung manuell verschieben

> Entry point: Schritt 6 des Hauptflows

1. A1.1: Der Turnierleiter zieht eine Paarung per Drag-and-Drop in eine andere Zelle.
2. A1.2: Die Planungs-Engine prüft, ob die neue Position die Zeitslot-Regel verletzt oder die Zielzelle bereits belegt ist.
3. A1.3: Bei Regelverstoß wird die Zelle rot markiert und ein Tooltip zeigt den Konflikt an *(→ E2)*.
4. A1.4: Bei regelkonformer Position wird die Paarung in die neue Zelle übernommen.

### A2 – Spielplan neu berechnen

> Entry point: Schritt 5 des Hauptflows

1. A2.1: Der Turnierleiter klickt auf «Neu berechnen».
2. A2.2: Die Planungs-Engine generiert eine neue Paarungsverteilung (ggf. andere Reihenfolge).
3. A2.3: Das Raster wird aktualisiert.

---

## Error Scenarios

### E1 – Sportarten-Mindestabdeckung nicht vollständig möglich

> Entry point: Schritt 2

1. E1.1: Die Anzahl Gruppen oder Zeitslots erlaubt nicht, dass jede Gruppe jede Sportart mindestens einmal spielt.
2. E1.2: Die Applikation zeigt eine Warnung, z. B. «Nicht alle Teams können jede Sportart mindestens einmal spielen. Bitte mehr Zeitslots hinzufügen.»
3. E1.3: Der Plan wird mit der größtmöglichen Sportarten-Abdeckung angezeigt und füllt danach so viele weitere Felder wie möglich.

### E2 – Manueller Verschiebekonflikt

> Entry point: A1.3

1. E2.1: Die Zelle wird rot markiert.
2. E2.2: Ein Tooltip erklärt den Konflikt (z. B. «Gruppe A spielt in diesem Zeitslot bereits»).
3. E2.3: Die Paarung verbleibt an der ursprünglichen Position.

---

## Postconditions

### Success

- Ein `Spielplan`-Objekt ist im Applikationsspeicher vorhanden und wird auf dem Screen dargestellt.
- Der Spielplan entspricht [BR-005 – Spielplan-Priorisierung](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-4c5d-7e6f-1a2b-3c4d5e6f7a8n:req/v1): Phase 1 maximiert die Sportarten-Abdeckung, Phase 2 füllt verbleibende Zellen.
- Keine Gruppe ist im selben Zeitslot mehr als einmal eingeplant ([BR-004](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-2c3d-7e4f-9a5b-1c6d7e8f9a0m:req/v1)).
- Gegnerwiederholungen sind zulässig, werden aber minimiert.

### Failure / Abort

- Falls die Berechnung fehlschlägt, bleibt der zuletzt gültige Spielplan (falls vorhanden) erhalten; eine Fehlermeldung wird angezeigt.

---

## Acceptance Criteria

```gherkin
Scenario: Sportarten-Abdeckung für 4 Gruppen, 3 Sportarten, 4 Zeitslots
  Given ein Turnier mit 4 Gruppen, 3 Sportarten und 4 Zeitslots ist konfiguriert
  When der Turnierleiter auf «Spielplan erstellen» klickt
  Then zeigt die Applikation ein 3×4-Raster
  And jede Gruppe spielt jede Sportart mindestens einmal
  And keine Gruppe erscheint zweimal in derselben Zeile (Zeitslot)
  And danach werden möglichst viele weitere Felder gefüllt

Scenario: Warnung bei unvollständiger Sportarten-Abdeckung
  Given ein Turnier mit 5 Gruppen, 2 Sportarten und 2 Zeitslots ist konfiguriert
  When der Turnierleiter auf «Spielplan erstellen» klickt
  Then zeigt die Applikation eine Warnung zur unvollständigen Sportarten-Mindestabdeckung
  And erstellt den bestmöglichen Plan ohne Zeitslot-Konflikt

Scenario: Konflikt bei manuellem Verschieben
  Given ein vollständiger Spielplan wird angezeigt
  And Gruppe A spielt bereits in Zeitslot 1
  When der Turnierleiter eine andere Paarung mit Gruppe A in Zeitslot 1 zieht
  Then wird die Zielzelle rot markiert
  And ein Tooltip erklärt den Konflikt
  And die Paarung bleibt an der ursprünglichen Position
```

---

## Non-Functional Requirements

| Type | Requirement |
|---|---|
| Performance | Die Spielplanerstellung für bis zu 20 Gruppen erfolgt in unter 2 Sekunden |
| Correctness | Der Algorithmus garantiert, dass keine Gruppe im selben Zeitslot zweimal automatisch platziert wird |

---

## Dependencies & References

- **Affected Data Objects**: [DO-001 – Turnier](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-2c3d-7e4f-9a5b-1c6d7e8f9a0c:req/v1), [DO-005 – Spielplan](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-9c0d-7e1f-6a2b-8c3d4e5f6a7j:req/v1), [DO-006 – Paarung](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-0c1d-7e2f-7a3b-9c4d5e6f7a8k:req/v1)
- **Applied Business Rules**: [BR-003 – Sportarten-Abdeckung](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-1c2d-7e3f-8a4b-0c5d6e7f8a9l:req/v1), [BR-004 – Gruppe-Zeitslot-Konflikt](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-2c3d-7e4f-9a5b-1c6d7e8f9a0m:req/v1), [BR-005 – Spielplan-Priorisierung](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-4c5d-7e6f-1a2b-3c4d5e6f7a8n:req/v1)
- **Depends on**: [UC-001 – Erfassen-Turnierdaten](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-1c2d-7e3f-8a4b-0c5d6e7f8a9b:req/v1)
- **Included Use Cases**: [UC-003 – Exportieren-Spielplan](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-3c4d-7e5f-0a6b-2c7d8e9f0a1n:req/v1)
