---
template-version: 1.0.0
linkservice-id: "urn:pfch:git:01932a4b-5c6d-7e7f-2a8b-4c9d0e1f2a3f:req/v1?anchor=true"
type: Data Object
status: draft
completeness: Intermediate
responsible: "project-owner"
keywords: timeslot, row, schedule
ITAM-Application: TournamentPlanner
---

# [DO-004 – Zeitslot](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-5c6d-7e7f-2a8b-4c9d0e1f2a3f:req/v1)

---

## Description

> Ein Zeitslot definiert einen Spielzeitraum und bildet eine Zeile (Y-Achse) im Spielplanraster. Mehrere Spiele können parallel im selben Zeitslot stattfinden, sofern sie verschiedene Gruppen betreffen.

---

## Attributes

| Attribute | Type | Required | Description |
|---|---|---|---|
| id | `String` | `yes` | Eindeutige UUID des Zeitslots (UUIDv4) |
| bezeichnung | `String` | `yes` | Anzeigename, z. B. «09:00–09:30», «Runde 1» |
| startzeit | `String` | `no` | Optionaler Startzeitpunkt im Format HH:mm |
| endzeit | `String` | `no` | Optionaler Endzeitpunkt im Format HH:mm |
| reihenfolge | `Integer` | `yes` | Zeilenposition im Spielplanraster (1-basiert) |

---

## Value Ranges & Constraints

- **bezeichnung**: 1–50 Zeichen; muss innerhalb eines Turniers eindeutig sein
- **startzeit / endzeit**: Format HH:mm (24h); wenn beide angegeben, muss endzeit > startzeit sein
- **reihenfolge**: ≥ 1; eindeutig innerhalb eines Turniers

---

## Relationships

- **References**: [DO-001 – Turnier](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-2c3d-7e4f-9a5b-1c6d7e8f9a0c:req/v1)
