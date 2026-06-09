---
template-version: 1.0.0
linkservice-id: "urn:pfch:git:01932a4b-4c5d-7e6f-1a7b-3c8d9e0f1a2o:req/v1?anchor=true"
type: Data Object
status: draft
completeness: Intermediate
responsible: "project-owner"
keywords: export, format, pdf, xlsx
ITAM-Application: TournamentPlanner
---

# [DO-007 – ExportKonfiguration](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-4c5d-7e6f-1a7b-3c8d9e0f1a2o:req/v1)

---

## Description

> Die ExportKonfiguration hält die vom Turnierleiter getroffenen Einstellungen für einen einzelnen Exportvorgang: gewähltes Format und Zieldateipfad.

---

## Attributes

| Attribute | Type | Required | Description |
|---|---|---|---|
| format | `Enum` | `yes` | Gewähltes Exportformat: `XLSX` oder `PDF` |
| dateipfad | `String` | `yes` | Absoluter Dateipfad inkl. Dateiname, wie vom NSSavePanel zurückgegeben |
| dateiname | `String` | `yes` | Vorausgefüllter Vorschlagsname im Format `Spielplan_<Turniername>_<YYYY-MM-DD>` |

---

## Value Ranges & Constraints

- **format**: Enum-Werte: `XLSX`, `PDF`
- **dateipfad**: gültiger absoluter macOS-Pfad; darf nicht leer sein
- **dateiname**: Enthält keine Sonderzeichen ausser Unterstrich und Bindestrich; max. 200 Zeichen

---

## Relationships

- **References**: [DO-005 – Spielplan](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-9c0d-7e1f-6a2b-8c3d4e5f6a7j:req/v1)
