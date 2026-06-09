# TournamentPlanner

Native macOS-Applikation zur fairen Verteilung von Gruppen auf Sportspiele in einem Turnierplan.

## Status

Dieses Verzeichnis enthält jetzt ein vollständiges Xcode-Projekt:

- `TournamentPlanner.xcodeproj`
- SwiftUI-App-Target `TournamentPlanner`
- XCTest-Target `TournamentPlannerTests`
- Build-Skript `scripts/build_app.sh`

Die App implementiert die in `docs/` beschriebenen Use-Cases: Setup, automatische Spielplanerstellung, manuelle Verschiebung per Drag-and-Drop, JSON-Persistenz sowie XLSX-/PDF-Export.

## Bauen und Installieren

Voraussetzung: vollständiges Xcode oder die Apple Command Line Tools mit Swift-Compiler. Wenn Xcode fehlt, baut das Skript ein App-Bundle direkt mit `swiftc`.

```bash
cd Documents/tournament-planner
./scripts/build_app.sh
```

Danach liegt die installierbare App hier:

```text
dist/TournamentPlanner.app
```

Zum Installieren die App nach `/Applications` kopieren.

## Dokumentation

| Dokument | Beschreibung |
|---|---|
| [`docs/project-description.md`](docs/project-description.md) | **Hauptdokument für Codex** – vollständige Projektbeschreibung, Tech-Stack, Datenmodell, Business Rules, Akzeptanzkriterien |
| [`docs/data-model.md`](docs/data-model.md) | ER-Diagramm + Swift-Structs + Constraints-Übersicht |
| [`docs/specs/use-cases/UC-001_Erfassen-Turnierdaten.md`](docs/specs/use-cases/UC-001_Erfassen-Turnierdaten.md) | Use Case: Turnierdaten erfassen (Setup-Screen) |
| [`docs/specs/use-cases/UC-002_Erstellen-Spielplan.md`](docs/specs/use-cases/UC-002_Erstellen-Spielplan.md) | Use Case: Spielplan automatisch erstellen und manuell anpassen |
| [`docs/specs/use-cases/UC-003_Exportieren-Spielplan.md`](docs/specs/use-cases/UC-003_Exportieren-Spielplan.md) | Use Case: Spielplan als XLSX oder PDF exportieren |
| [`docs/specs/data-objects/`](docs/specs/data-objects/) | Alle Datenobjekte (DO-001 bis DO-007) |
| [`docs/specs/business-rules/`](docs/specs/business-rules/) | Alle Geschäftsregeln (BR-001 bis BR-004) |

## Schnellstart für Codex

1. Lies zuerst [`docs/project-description.md`](docs/project-description.md) vollständig.
2. Lies [`docs/data-model.md`](docs/data-model.md) für die Swift-Datenstrukturen.
3. Erstelle das Xcode-Projekt als **macOS App** mit SwiftUI, Deployment Target macOS 14.0.
4. Implementiere die Schichten in dieser Reihenfolge:
   - `Model/` (Structs + PlanungsEngine)
   - `ViewModel/` (ObservableObject)
   - `Services/` (Persistenz, dann Export)
   - `Views/` (SetupView → SpielplanView → ExportView)
5. Verifiziere mit den 6 Akzeptanzkriterien in `project-description.md`.
