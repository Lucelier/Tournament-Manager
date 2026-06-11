# TournamentPlanner

Native macOS-App (SwiftUI, macOS 14+) zur fairen Verteilung von Gruppen auf Sportspiele in einem Turnierplan.

## Features

- **Setup**: Gruppen, Sportarten (mit optionalem Standort) und Zeitslots (Start-/Endzeit) erfassen, mit Live-Validierung und Beispieldaten.
- **Automatische Spielplanerstellung** (BR-005): Jede Gruppe spielt jede Sportart mindestens einmal, Gegnerwiederholungen werden minimiert, das Raster wird möglichst vollständig gefüllt. Eine Gruppe spielt nie zweimal im selben Zeitslot (BR-004).
- **Manuelle Anpassung** per Drag-and-drop mit Konfliktprüfung.
- **Export**: PDF (A4 quer, mehrseitig, druckfertig) und XLSX.
- **Automatische Speicherung** lokal als JSON; vollständig offline.
- **Integrierte Benutzeranleitung** über den «Hilfe»-Knopf in der App.

## Bauen und Starten

Projekt in Xcode öffnen und mit **Cmd + R** starten (Ziel «My Mac», keine weiteren Schritte nötig):

```bash
open tournament-planner/TournamentPlanner.xcodeproj
```

Tests laufen mit **Cmd + U** oder:

```bash
cd tournament-planner
xcodebuild -project TournamentPlanner.xcodeproj -scheme TournamentPlanner test
```

Alternativ baut `tournament-planner/scripts/build_app.sh` ein App-Bundle nach `tournament-planner/dist/`.

## Projektstruktur

```text
tournament-planner/
├── TournamentPlanner/          # App-Quellcode (Model, ViewModel, Services, Views)
├── TournamentPlannerTests/     # Unit-Tests (Engine, PDF-/XLSX-Export)
├── TournamentPlanner.xcodeproj
└── docs/                       # Spezifikationen und Anleitungen
```

## Dokumentation

| Dokument | Beschreibung |
|---|---|
| [`docs/Benutzeranleitung.md`](tournament-planner/docs/Benutzeranleitung.md) | Benutzeranleitung (auch in der App über «Hilfe» abrufbar) |
| [`docs/specs/architecture/ARCH-001_Architektur.md`](tournament-planner/docs/specs/architecture/ARCH-001_Architektur.md) | Architektur, ERD, Testcoverage-Report, Security-Betrachtung |
| [`docs/specs/use-cases/`](tournament-planner/docs/specs/use-cases/) | Use Cases UC-001 bis UC-003 |
| [`docs/specs/business-rules/`](tournament-planner/docs/specs/business-rules/) | Geschäftsregeln BR-001 bis BR-005 |
| [`docs/specs/data-objects/`](tournament-planner/docs/specs/data-objects/) | Datenobjekte DO-001 bis DO-007 |
| [`docs/project-description.md`](tournament-planner/docs/project-description.md) | Vollständige Projektbeschreibung |
| [`docs/data-model.md`](tournament-planner/docs/data-model.md) | ER-Diagramm, Swift-Structs, Constraints |

---

*contributed by Luc Rossier*
