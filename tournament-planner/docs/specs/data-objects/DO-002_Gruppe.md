---
template-version: 1.0.0
linkservice-id: "urn:pfch:git:01932a4b-3c4d-7e5f-0a6b-2c7d8e9f0a1d:req/v1?anchor=true"
type: Data Object
status: draft
completeness: Intermediate
responsible: "project-owner"
keywords: group, team, participant
ITAM-Application: TournamentPlanner
---

# [DO-002 – Gruppe](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-3c4d-7e5f-0a6b-2c7d8e9f0a1d:req/v1)

---

## Description

> Eine Gruppe repräsentiert ein Team oder eine Mannschaft, die am Turnier teilnimmt und gegen andere Gruppen antritt.

---

## Attributes

| Attribute | Type | Required | Description |
|---|---|---|---|
| id | `String` | `yes` | Eindeutige UUID der Gruppe (UUIDv4) |
| name | `String` | `yes` | Anzeigename der Gruppe, z. B. «Gruppe A», «Team Rot» |
| reihenfolge | `Integer` | `yes` | Sortierungsposition innerhalb des Turniers (1-basiert) |

---

## Value Ranges & Constraints

- **name**: 1–50 Zeichen; muss innerhalb eines Turniers eindeutig sein (→ BR-001)
- **reihenfolge**: ≥ 1; eindeutig innerhalb eines Turniers

---

## Relationships

- **References**: [DO-001 – Turnier](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-2c3d-7e4f-9a5b-1c6d7e8f9a0c:req/v1)
