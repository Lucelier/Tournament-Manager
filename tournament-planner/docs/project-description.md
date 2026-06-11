# TournamentPlanner – Projektbeschreibung für Codex

## Ziel

Erstelle eine native **macOS-Applikation** mit **SwiftUI** und dem **App-Lifecycle** (kein AppKit-Wrapper), die Turnierverantwortlichen erlaubt, Gruppen automatisch und fair auf Sportspiele zu verteilen. Die Applikation heisst **TournamentPlanner**.

---

## Planungsprioritäten

Die Planungs-Engine optimiert den Spielplan in dieser Reihenfolge:

1. **Zeitslot-Konflikt vermeiden:** Jede Gruppe darf im selben Zeitslot höchstens einmal eingeplant sein. Diese Regel ist hart und darf nie verletzt werden.
2. **Sportarten-Mindestabdeckung maximieren:** Jede Gruppe soll jede Sportart mindestens einmal spielen. Wenn die Eingabedaten das nicht vollständig erlauben, wird die größtmögliche Abdeckung erzeugt.
3. **Felder füllen:** Danach sollen möglichst viele Rasterzellen belegt werden, solange Priorität 1 und 2 nicht schlechter werden. Sportarten dürfen dafür wiederholt werden.
4. **Gegnerwiederholungen minimieren:** Erst zuletzt wird bevorzugt, dass zwei Gruppen höchstens einmal gegeneinander spielen. Wiederholte Gegner sind erlaubt, wenn sie für höhere Prioritäten nötig sind.

Der Spielplan ist ein **zweidimensionales Raster**:
- **X-Achse (Spalten):** Sportarten
- **Y-Achse (Zeilen):** Zeitslots
- **Zellinhalt:** «Gruppe A vs. Gruppe B» oder leer

---

## Technologie-Stack

| Schicht | Technologie |
|---|---|
| UI | SwiftUI (macOS 14+, Sonoma) |
| Sprache | Swift 5.10+ |
| Persistenz | JSON-Datei via `Codable` + `FileManager` (kein CoreData) |
| XLSX-Export | [xlsxwriter](https://github.com/jmcnamara/XlsxWriter) via Swift-Package **oder** `libxlsxwriter` via SPM-Wrapper |
| PDF-Export | `PDFKit` + `NSPrintOperation` oder `CGContext` |
| Paketmanager | Swift Package Manager (SPM) |
| Mindest-Deployment | macOS 14.0 |

---

## App-Struktur

```
TournamentPlanner/
├── TournamentPlannerApp.swift        // @main, WindowGroup
├── Model/
│   ├── Turnier.swift                 // Alle Codable-Structs (siehe Datenmodell)
│   └── PlanungsEngine.swift          // Priorisierte Planungsheuristik
├── ViewModel/
│   ├── TurnierViewModel.swift        // @ObservableObject, hält Turnier-State
│   └── SpielplanViewModel.swift      // Spielplan-State, Drag-and-Drop-Logik
├── Views/
│   ├── SetupView.swift               // UC-001: Gruppen/Sportarten/Zeitslots erfassen
│   ├── SpielplanView.swift           // UC-002: Spielplanraster anzeigen + editieren
│   ├── ExportView.swift              // UC-003: Export-Dialog
│   └── Components/
│       ├── GruppenListeView.swift
│       ├── SportartenListeView.swift
│       ├── ZeitslotListeView.swift
│       └── PaarungsZelleView.swift
├── Services/
│   ├── PersistenzService.swift       // JSON laden/speichern
│   ├── XLSXExportService.swift       // XLSX-Generierung
│   └── PDFExportService.swift        // PDF-Generierung
└── docs/
    └── specs/                        // Use Cases, Data Objects, Business Rules
```

---

## Use Cases (zusammengefasst)

### UC-001 – Turnierdaten erfassen

**Screen:** `SetupView`

Der Benutzer konfiguriert:
1. **Turniername** (Textfeld, Pflicht)
2. **Gruppen**: Dynamische Liste; «+»-Button fügt eine neue Gruppe hinzu; jede Gruppe hat ein Namensfeld; «-»-Button entfernt sie. Mindestens 2 Gruppen.
3. **Sportarten**: Dynamische Liste; «+»-Button fügt Sportart hinzu; jede Sportart hat ein Namensfeld und ein optionales Standortfeld. Mindestens 1.
4. **Zeitslots**: Dynamische Liste; jeder Zeitslot hat eine Startzeit (Pflicht) und eine optionale Endzeit (HH:mm). Mindestens 1.

**Validierung (live, während der Eingabe):**
- Gruppenname darf nicht doppelt vorkommen (case-insensitive) → rotes Feld + Fehlermeldung
- Schaltfläche «Spielplan erstellen» ist solange deaktiviert, bis alle Pflichtbedingungen erfüllt sind

**Schaltfläche «Spielplan erstellen»** → navigiert zu `SpielplanView` und löst PlanungsEngine aus

---

### UC-002 – Spielplan erstellen und anzeigen

**Screen:** `SpielplanView`

**Algorithmus (PlanungsEngine):**
1. Erzeuge Kandidaten aus allen möglichen Gruppenpaaren für jede Zelle.
2. Schließe Kandidaten aus, bei denen eine Gruppe im Zeitslot bereits spielt.
3. Bevorzuge Kandidaten, bei denen beide Gruppen die Sportart noch nicht gespielt haben.
4. Fülle danach möglichst viele Zellen, auch wenn Teams Sportarten dafür wiederholen.
5. Wähle bei gleicher Bewertung bevorzugt Paarungen, die noch nicht gegeneinander gespielt haben.

**Darstellung:**
- SwiftUI `Grid` oder `LazyVGrid` / `Table`
- Spaltenköpfe: Sportartnamen (fett), darunter klein der Standort (falls erfasst)
- Zeilenköpfe: Zeitangaben der Zeitslots (fett)
- Zellinhalt: «[Gruppe A] vs [Gruppe B]» oder Leerdarstellung
- Nicht platzierte Paarungen: separate Liste unterhalb des Rasters («Nicht eingeplant»)

**Manuelles Verschieben (Drag-and-Drop):**
- Paarung per Drag aus Quellzelle in Zielzelle ziehen
- Bei Regelverstoß gegen Zeitslot oder belegte Zelle: rote Hervorhebung der Zielzelle + Tooltip mit Konfliktbeschreibung; Paarung verbleibt in der Quellzelle
- Bei gültigem Ziel: Paarung wird verschoben; Quellzelle wird leer

**Schaltflächen:**
- «Neu berechnen» → PlanungsEngine wird erneut mit neuem Zufalls-Seed ausgeführt
- «Exportieren» → öffnet `ExportView`
- «Zurück» → kehrt zu SetupView zurück (mit Bestätigungsdialog, da Daten verloren gehen)

---

### UC-003 – Spielplan exportieren

**Sheet/Panel:** `ExportView` (als `.sheet` über `SpielplanView`)

1. Picker: «XLSX» / «PDF»
2. Schaltfläche «Speichern» → öffnet `NSSavePanel` mit vorausgefülltem Dateinamen `Spielplan_<Turniername>_<YYYY-MM-DD>`
3. Nach Bestätigung: Datei wird erzeugt

**XLSX-Format:**
- Tabellenblatt «Spielplan»
- Zeile 1: leere Zelle (A1) + Sportartnamen mit Standort in Klammern als Spaltenköpfe (B1, C1, …)
- Spalte A: Zeitangaben der Zeitslots (A2, A3, …)
- Inhalt: «Gruppe A vs. Gruppe B» oder leer
- Kopfzeile und Kopfspalte: fett; Zellen mit Paarungen: dünner Rahmen

**PDF-Format:**
- A4 Querformat
- Kopfzeile: Turniername + Exportdatum
- Tabelle: gleiche Struktur wie XLSX
- Schriftgrösse automatisch angepasst damit alles auf eine Seite passt (bis 20 Gruppen)

**Erfolgsmeldung:** Alert «Datei erfolgreich gespeichert» mit Pfadanzeige und «Im Finder zeigen»-Button

---

## Datenmodell (Swift Structs – Codable)

```swift
struct Turnier: Codable, Identifiable {
    let id: UUID
    var name: String
    let erstelltAm: Date
    var gruppen: [Gruppe]
    var sportarten: [Sportart]
    var zeitslots: [Zeitslot]
    var spielplan: Spielplan?
}

struct Gruppe: Codable, Identifiable {
    let id: UUID
    var name: String
    var reihenfolge: Int
}

struct Sportart: Codable, Identifiable {
    let id: UUID
    var name: String
    var reihenfolge: Int
}

struct Zeitslot: Codable, Identifiable {
    let id: UUID
    var bezeichnung: String
    var startzeit: String?  // HH:mm
    var endzeit: String?    // HH:mm
    var reihenfolge: Int
}

struct Spielplan: Codable, Identifiable {
    let id: UUID
    let erstelltAm: Date
    var paarungen: [Paarung]
    var nichtPlatziert: [Paarung]
}

struct Paarung: Codable, Identifiable {
    let id: UUID
    let gruppeAId: UUID
    let gruppeBId: UUID
    var sportartId: UUID?
    var zeitslotId: UUID?
}

enum ExportFormat: String, Codable, CaseIterable {
    case xlsx = "XLSX"
    case pdf  = "PDF"
}
```

---

## Business Rules (im Code zu enforzen)

| ID | Regel | Wo enforzen |
|---|---|---|
| BR-001 | Gruppenname eindeutig (case-insensitive) pro Turnier | `TurnierViewModel.validateGruppenNamen()` |
| BR-002 | Min. 2 Gruppen, 1 Sportart, 1 Zeitslot | `TurnierViewModel.isValid: Bool` (computed property) |
| BR-003 | Sportarten-Mindestabdeckung: Gruppe soll jede Sportart mindestens einmal spielen | `PlanungsEngine` |
| BR-004 | Gruppe max. einmal pro Zeitslot | `PlanungsEngine` + Drag-and-Drop-Validator |
| BR-005 | Paarung (A,B) möglichst nur einmal im Spielplan (A==B symmetrisch), aber nur als niedrigste Priorität | `PlanungsEngine` |

---

## Persistenz

- Beim Beenden der App: `Turnier`-Objekt als JSON in `~/Library/Application Support/TournamentPlanner/turnier.json` speichern
- Beim Start: falls Datei vorhanden → laden und in ViewModel übernehmen
- «Neues Turnier»: Bestätigungsdialog «Aktuellen Spielplan verwerfen?» → bei Bestätigung wird ViewModel zurückgesetzt

---

## Nicht im Scope (v1.0)

- Mehrere parallele Turniere (nur eines gleichzeitig)
- Netzwerk-/Cloud-Sync
- Ergebniserfassung oder Punktestand
- Undo/Redo (nice-to-have, nicht gefordert)
- Lokalisierung in mehrere Sprachen (nur Deutsch für v1.0)

---

## Akzeptanzkriterien (Smoke-Test)

1. **Setup:** 4 Gruppen («A», «B», «C», «D»), 3 Sportarten («Fussball», «Volleyball», «Unihockey»), 4 Zeitslots («09:00», «09:30», «10:00», «10:30») erfassen → «Spielplan erstellen» ist aktiv.
2. **Spielplan:** Nach Klick zeigt die App ein 3×4-Raster. Jede der 4 Gruppen spielt jede der 3 Sportarten mindestens einmal. Keine Gruppe erscheint zweimal in derselben Zeile. Danach werden so viele weitere Felder wie möglich gefüllt.
3. **XLSX-Export:** Datei öffnet fehlerfrei in Numbers und enthält das korrekte Raster.
4. **PDF-Export:** Datei öffnet in Preview; Turniername und Datum sind im Kopf sichtbar; Tabelle ist vollständig.
5. **Validierung:** Zweiter identischer Gruppenname → Feld rot, Button inaktiv.
6. **Drag-and-Drop-Konflikt:** Paarung in Zelle ziehen, die Zeitslot- oder Sportarten-Regeln verletzt → Zelle rot, Tooltip sichtbar, Paarung bleibt.
