---
template-version: 1.0.0
linkservice-id: "urn:pfch:git:01932a4b-0c1d-7e2f-7a3b-9c4d5e6f7a8k:req/v1?anchor=true"
type: Data Object
status: draft
completeness: Intermediate
responsible: "project-owner"
keywords: match, pairing, cell
ITAM-Application: TournamentPlanner
---

# [DO-006 – Paarung](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-0c1d-7e2f-7a3b-9c4d5e6f7a8k:req/v1)

---

## Description

> Eine Paarung beschreibt eine geplante Begegnung zwischen zwei Gruppen, zugewiesen zu einer Sportart und einem Zeitslot. Sie besetzt genau eine Zelle im Spielplanraster.

---

## Attributes

| Attribute | Type | Required | Description |
|---|---|---|---|
| id | `String` | `yes` | Eindeutige UUID der Paarung (UUIDv4) |
| gruppeA | `String` | `yes` | Referenz auf die ID der ersten Gruppe (→ DO-002) |
| gruppeB | `String` | `yes` | Referenz auf die ID der zweiten Gruppe (→ DO-002) |
| sportartId | `String` | `no` | Referenz auf die ID der Sportart (→ DO-003); null wenn nicht platziert |
| zeitslotId | `String` | `no` | Referenz auf die ID des Zeitslots (→ DO-004); null wenn nicht platziert |

---

## Value Ranges & Constraints

- **gruppeA ≠ gruppeB**: Eine Gruppe darf nicht gegen sich selbst spielen
- **Kombination (Gruppe, sportartId)**: Jede beteiligte Gruppe soll jede Sportart mindestens einmal spielen; Wiederholungen sind erlaubt, nachdem die Mindestabdeckung maximiert wurde (→ BR-003)
- **Kombination (sportartId, zeitslotId)**: Innerhalb eines Spielplans maximal einmal belegt
- **Kombination (gruppeA, gruppeB)**: Gegnerwiederholungen sind zulässig, werden von der Planungs-Engine aber als niedrigste Priorität minimiert
- Wenn **sportartId** und **zeitslotId** beide null sind, gilt die Paarung als nicht platziert

---

## Relationships

- **References**: [DO-002 – Gruppe](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-3c4d-7e5f-0a6b-2c7d8e9f0a1d:req/v1)
- **References**: [DO-003 – Sportart](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-4c5d-7e6f-1a7b-3c8d9e0f1a2e:req/v1)
- **References**: [DO-004 – Zeitslot](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-5c6d-7e7f-2a8b-4c9d0e1f2a3f:req/v1)
- **References**: [DO-005 – Spielplan](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-9c0d-7e1f-6a2b-8c3d4e5f6a7j:req/v1)
