---
template-version: 1.0.0
linkservice-id: "urn:pfch:git:01932a4b-3c4d-7e5f-0a6b-2c7d8e9f0a1n:req/v1?anchor=true"
type: Use Case
status: draft
completeness: Intermediate
responsible: "project-owner"
keywords: export, xlsx, pdf, schedule
ITAM-Application: TournamentPlanner
---

# [UC-003 – Exportieren-Spielplan](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-3c4d-7e5f-0a6b-2c7d8e9f0a1n:req/v1)

---

## Brief Description

> Der Turnierleiter möchte den fertigen Spielplan als XLSX- oder PDF-Datei exportieren, um ihn ausdrucken oder digital teilen zu können.

---

## Actors

| Actor | Type | Role |
|---|---|---|
| Turnierleiter | `Human` | Löst den Export aus und wählt Format und Speicherort |
| Export-Engine | `System` | Erzeugt die Datei im gewählten Format |

---

## Context & Background

> Nach der Spielplanerstellung soll der Plan als druckbares oder weiterteilbares Dokument vorliegen. XLSX ermöglicht nachträgliche Bearbeitung in Tabellenkalkulationsprogrammen; PDF eignet sich für Druck und unveränderbare Weitergabe. Die Datei wird über den macOS-Standard-Speicherdialog am gewünschten Ort gespeichert.

---

## Preconditions

- Ein vollständiger `Spielplan` mit mindestens einer Paarung ist im Applikationsspeicher vorhanden (Postcondition von UC-002).

---

## Trigger

> Der Turnierleiter klickt auf «Exportieren» im Spielplan-Screen.

---

## Description

1. Die Applikation zeigt einen Export-Dialog mit der Formatauswahl «XLSX» und «PDF».
2. Der Turnierleiter wählt das gewünschte Format.
3. Der Turnierleiter klickt auf «Speichern».
4. Die Applikation öffnet den macOS-Standard-Speicherdialog (NSSavePanel) mit einem vorausgefüllten Dateinamen im Format `Spielplan_<Turniername>_<Datum>`.
5. Der Turnierleiter wählt den Speicherort und bestätigt.
6. Die Export-Engine erzeugt die Datei gemäss dem gewählten Format (→ A1 für XLSX, A2 für PDF).
7. Die Applikation zeigt eine Erfolgsmeldung «Datei erfolgreich gespeichert» mit einem «Im Finder öffnen»-Link.

---

## Alternative Flows

### A1 – XLSX-Export

> Entry point: Schritt 6, Formatwahl XLSX

1. A1.1: Die Export-Engine erstellt eine Arbeitsmappe mit einem Tabellenblatt «Spielplan».
2. A1.2: Die erste Zeile enthält die Sportartnamen als Spaltenköpfe; die erste Spalte enthält die Zeitslotbezeichnungen.
3. A1.3: Jede Zelle enthält den Paarungstext («Gruppe A vs. Gruppe B») oder bleibt leer.
4. A1.4: Kopfzeile und -spalte werden fett formatiert; Zellen mit Paarungen erhalten einen Rahmen.
5. A1.5: Die Datei wird unter dem gewählten Pfad gespeichert.

### A2 – PDF-Export

> Entry point: Schritt 6, Formatwahl PDF

1. A2.1: Die Export-Engine rendert das Spielplanraster als Tabelle mit identischer Struktur wie der Screen.
2. A2.2: Kopfzeile und Seitenrand enthalten den Turniernamen und das Exportdatum.
3. A2.3: Die Tabelle wird bei Bedarf auf das Papierformat (A4 Querformat) skaliert.
4. A2.4: Die PDF-Datei wird unter dem gewählten Pfad gespeichert.

---

## Error Scenarios

### E1 – Kein Schreibrecht am Speicherort

> Entry point: Schritt 6

1. E1.1: Das Dateisystem verweigert den Schreibzugriff.
2. E1.2: Die Applikation zeigt die Fehlermeldung «Datei konnte nicht gespeichert werden: Kein Schreibrecht» und öffnet den Speicherdialog erneut.

### E2 – Unbekannter Exportfehler

> Entry point: Schritt 6

1. E2.1: Die Export-Engine wirft einen unerwarteten Fehler.
2. E2.2: Die Applikation zeigt die Fehlermeldung «Export fehlgeschlagen» mit dem technischen Fehlertext.
3. E2.3: Der Spielplan auf dem Screen bleibt unverändert erhalten.

---

## Postconditions

### Success

- Eine lesbare Datei im gewählten Format existiert am vom Benutzer gewählten Pfad.
- Die Datei enthält das vollständige Spielplanraster mit allen Paarungen und Beschriftungen.

### Failure / Abort

- Es wird keine Datei erzeugt; der bestehende Spielplan im Applikationsspeicher bleibt unverändert.

---

## Acceptance Criteria

```gherkin
Scenario: Erfolgreicher XLSX-Export
  Given ein vollständiger Spielplan mit 3 Sportarten und 4 Zeitslots wird angezeigt
  When der Turnierleiter «XLSX» wählt und einen Speicherort bestätigt
  Then existiert eine .xlsx-Datei am gewählten Pfad
  And die Datei enthält ein Tabellenblatt mit 3 Datenspalten und 4 Datenzeilen
  And alle Paarungen sind in den korrekten Zellen eingetragen

Scenario: Erfolgreicher PDF-Export
  Given ein vollständiger Spielplan wird angezeigt
  When der Turnierleiter «PDF» wählt und einen Speicherort bestätigt
  Then existiert eine .pdf-Datei am gewählten Pfad
  And die Datei enthält den Turniernamen und das Exportdatum im Kopfbereich

Scenario: Export ohne Schreibrecht schlägt fehlerfrei ab
  Given der Turnierleiter wählt einen Pfad ohne Schreibberechtigung
  When er den Export bestätigt
  Then zeigt die Applikation die Meldung «Kein Schreibrecht»
  And der Spielplan-Screen bleibt geöffnet
```

---

## Non-Functional Requirements

| Type | Requirement |
|---|---|
| Performance | Die Datei wird in unter 3 Sekunden generiert (Spielplan bis 20 Gruppen) |
| Compatibility | XLSX-Dateien müssen in Microsoft Excel 2016+ und Apple Numbers fehlerfrei öffnen |
| Print quality | PDF wird in 300 dpi gerendert und ist auf A4 Querformat optimiert |

---

## Dependencies & References

- **Affected Data Objects**: [DO-005 – Spielplan](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-9c0d-7e1f-6a2b-8c3d4e5f6a7j:req/v1), [DO-007 – ExportKonfiguration](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-4c5d-7e6f-1a7b-3c8d9e0f1a2o:req/v1)
- **Depends on**: [UC-002 – Erstellen-Spielplan](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-8c9d-7e0f-5a1b-7c2d3e4f5a6i:req/v1)
