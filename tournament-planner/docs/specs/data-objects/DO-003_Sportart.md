---
template-version: 1.0.0
linkservice-id: "urn:pfch:git:01932a4b-4c5d-7e6f-1a7b-3c8d9e0f1a2e:req/v1?anchor=true"
type: Data Object
status: draft
completeness: Intermediate
responsible: "project-owner"
keywords: sport, discipline, column
ITAM-Application: TournamentPlanner
---

# [DO-003 – Sportart](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-4c5d-7e6f-1a7b-3c8d9e0f1a2e:req/v1)

---

## Description

> Eine Sportart definiert eine Disziplin, die im Turnier gespielt wird. Sie bildet eine Spalte (X-Achse) im Spielplanraster.

---

## Attributes

| Attribute | Type | Required | Description |
|---|---|---|---|
| id | `String` | `yes` | Eindeutige UUID der Sportart (UUIDv4) |
| name | `String` | `yes` | Bezeichnung der Sportart, z. B. «Fussball», «Volleyball» |
| reihenfolge | `Integer` | `yes` | Spaltenposition im Spielplanraster (1-basiert) |

---

## Value Ranges & Constraints

- **name**: 1–50 Zeichen; muss innerhalb eines Turniers eindeutig sein
- **reihenfolge**: ≥ 1; eindeutig innerhalb eines Turniers

---

## Relationships

- **References**: [DO-001 – Turnier](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-2c3d-7e4f-9a5b-1c6d7e8f9a0c:req/v1)
