---
template-version: 1.0.0
linkservice-id: "urn:pfch:git:01932a4b-1c2d-7e3f-8a4b-0c5d6e7f8a9b:req/v1?anchor=true"
type: Use Case
status: draft
completeness: Intermediate
responsible: "project-owner"
keywords: tournament, groups, sports, setup
ITAM-Application: TournamentPlanner
---

# [UC-001 – Erfassen-Turnierdaten](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-1c2d-7e3f-8a4b-0c5d6e7f8a9b:req/v1)

---

## Brief Description

> Der Turnierleiter möchte Gruppen, Sportarten und Zeitslots erfassen, um die Grunddaten für die automatische Spielplanerstellung bereitzustellen.

---

## Actors

| Actor | Type | Role |
|---|---|---|
| Turnierleiter | `Human` | Erstellt und verwaltet die Turnierkonfiguration |

---

## Context & Background

> Die Applikation benötigt vor der Spielplanerstellung vollständige Konfigurationsdaten: Anzahl und Namen der Gruppen, die verfügbaren Sportarten sowie die Zeitslots, in denen Spiele ausgetragen werden. Diese Daten bilden die Grundlage des Spielplanrasters (X-Achse: Sportarten, Y-Achse: Zeitslots). Die Erfassung erfolgt in einem Setup-Screen vor der eigentlichen Planung.

---

## Preconditions

- Die Applikation ist gestartet und befindet sich im Initialzustand (kein bestehender Spielplan geladen).

---

## Trigger

> Der Turnierleiter startet die Applikation oder wählt «Neues Turnier» im Hauptmenü.

---

## Description

1. Die Applikation zeigt den Setup-Screen mit drei Eingabebereichen: «Gruppen», «Sportarten» und «Zeitslots».
2. Der Turnierleiter gibt die Anzahl Gruppen ein (Mindestwert: 2).
3. Die Applikation generiert entsprechend viele benennbare Gruppenfelder.
4. Der Turnierleiter vergibt jeweils einen eindeutigen Namen pro Gruppe.
5. Der Turnierleiter fügt eine oder mehrere Sportarten hinzu (Name, optionaler Standort).
6. Der Turnierleiter fügt einen oder mehrere Zeitslots hinzu (Startzeitpunkt, optionaler Endzeitpunkt).
7. Der Turnierleiter klickt auf «Spielplan erstellen» *(→ UC-002)*.

---

## Alternative Flows

### A1 – Gruppe umbenennen

> Entry point: Schritt 4 des Hauptflows

1. A1.1: Der Turnierleiter klickt auf den Namen einer bestehenden Gruppe.
2. A1.2: Das Namensfeld wird editierbar.
3. A1.3: Der Turnierleiter ändert den Namen und bestätigt mit Enter oder Fokus-Verlust.
4. A1.4: Die Applikation übernimmt den neuen Namen und prüft Eindeutigkeit *(→ E1 bei Duplikat)*.

### A2 – Sportart oder Zeitslot löschen

> Entry point: Schritt 5 oder 6 des Hauptflows

1. A2.1: Der Turnierleiter klickt das Löschen-Symbol neben einer Sportart oder einem Zeitslot.
2. A2.2: Die Applikation entfernt den Eintrag aus der Liste.
3. A2.3: Der Flow kehrt zu Schritt 5 bzw. 6 zurück.

---

## Error Scenarios

### E1 – Doppelter Gruppenname

> Entry point: Schritt 4 oder A1.4

1. E1.1: Die Applikation erkennt, dass der eingegebene Name bereits einer anderen Gruppe zugewiesen ist.
2. E1.2: Das betroffene Feld wird rot hervorgehoben und eine Fehlermeldung «Gruppenname bereits vergeben» wird angezeigt.
3. E1.3: Der Turnierleiter muss den Namen korrigieren; die Schaltfläche «Spielplan erstellen» bleibt deaktiviert.

### E2 – Mindestanzahl unterschritten

> Entry point: Schritt 7

1. E2.1: Die Applikation stellt fest, dass weniger als 2 Gruppen, keine Sportart oder kein Zeitslot erfasst sind.
2. E2.2: Es wird eine Validierungsmeldung angezeigt, die die fehlenden Pflichtangaben benennt.
3. E2.3: Die Aktion «Spielplan erstellen» wird abgebrochen.

---

## Postconditions

### Success

- Ein vollständiges `Turnier`-Objekt mit mindestens 2 Gruppen, mindestens 1 Sportart und mindestens 1 Zeitslot ist im Applikationsspeicher vorhanden.
- Alle Gruppennamen sind eindeutig.

### Failure / Abort

- Es werden keine Daten persistiert; der Setup-Screen bleibt geöffnet.

---

## Acceptance Criteria

```gherkin
Scenario: Gültige Turnierdaten erfassen
  Given der Turnierleiter hat die Applikation gestartet
  When er 4 Gruppen mit eindeutigen Namen, 3 Sportarten und 4 Zeitslots eingibt
  And er auf «Spielplan erstellen» klickt
  Then öffnet die Applikation den Spielplan-Screen mit dem korrekt befüllten Raster

Scenario: Doppelter Gruppenname wird abgelehnt
  Given der Turnierleiter hat 2 Gruppen erfasst
  When er für eine weitere Gruppe denselben Namen wie Gruppe 1 eingibt
  Then wird das Namensfeld rot markiert
  And die Schaltfläche «Spielplan erstellen» ist deaktiviert

Scenario: Spielplan erstellen ohne Sportart nicht möglich
  Given der Turnierleiter hat 3 Gruppen und 2 Zeitslots erfasst, aber keine Sportart
  When er auf «Spielplan erstellen» klickt
  Then zeigt die Applikation die Meldung «Mindestens eine Sportart erforderlich»
```

---

## Non-Functional Requirements

| Type | Requirement |
|---|---|
| Usability | Eingaben müssen ohne Mausbedienung per Tab-Navigation vollständig möglich sein |
| Performance | Die Validierung nach jeder Eingabe erfolgt in unter 100 ms |

---

## Dependencies & References

- **Affected Data Objects**: [DO-001 – Turnier](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-2c3d-7e4f-9a5b-1c6d7e8f9a0c:req/v1), [DO-002 – Gruppe](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-3c4d-7e5f-0a6b-2c7d8e9f0a1d:req/v1), [DO-003 – Sportart](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-4c5d-7e6f-1a7b-3c8d9e0f1a2e:req/v1), [DO-004 – Zeitslot](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-5c6d-7e7f-2a8b-4c9d0e1f2a3f:req/v1)
- **Applied Business Rules**: [BR-001 – Gruppenname-Eindeutigkeit](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-6c7d-7e8f-3a9b-5c0d1e2f3a4g:req/v1), [BR-002 – Mindestanzahl-Turnierdaten](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-7c8d-7e9f-4a0b-6c1d2e3f4a5h:req/v1)
- **Included Use Cases**: [UC-002 – Erstellen-Spielplan](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-8c9d-7e0f-5a1b-7c2d3e4f5a6i:req/v1)
