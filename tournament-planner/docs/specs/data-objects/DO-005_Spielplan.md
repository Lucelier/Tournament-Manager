---
template-version: 1.0.0
linkservice-id: "urn:pfch:git:01932a4b-9c0d-7e1f-6a2b-8c3d4e5f6a7j:req/v1?anchor=true"
type: Data Object
status: draft
completeness: Intermediate
responsible: "project-owner"
keywords: schedule, grid, plan
ITAM-Application: TournamentPlanner
---

# [DO-005 – Spielplan](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-9c0d-7e1f-6a2b-8c3d4e5f6a7j:req/v1)

---

## Description

> Der Spielplan hält alle berechneten Paarungen als zweidimensionales Raster (Sportart × Zeitslot). Er ist das zentrale Ausgabeobjekt der Planungs-Engine und Grundlage des Exports.

---

## Attributes

| Attribute | Type | Required | Description |
|---|---|---|---|
| id | `String` | `yes` | Eindeutige UUID des Spielplans (UUIDv4) |
| erstelltAm | `Date` | `yes` | Timestamp der letzten Berechnung (ISO-8601) |
| paarungen | `Object` | `yes` | Liste aller platzierten Paarungen (→ DO-006) |
| nichtPlatziert | `Object` | `no` | Liste nicht platzierter Paarungen aus manuellen Alt-/Importfällen; der Generator lässt bei Prioritätskonflikten Zellen leer (→ DO-006) |

---

## Value Ranges & Constraints

- **paarungen**: kann leer sein (wenn keine Gruppen konfiguriert), aber nicht null
- **nichtPlatziert**: niemals null; bei automatisch generierten Plänen normalerweise leer

---

## Relationships

- **References**: [DO-001 – Turnier](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-2c3d-7e4f-9a5b-1c6d7e8f9a0c:req/v1)
- **Contains**: [DO-006 – Paarung](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-0c1d-7e2f-7a3b-9c4d5e6f7a8k:req/v1)
