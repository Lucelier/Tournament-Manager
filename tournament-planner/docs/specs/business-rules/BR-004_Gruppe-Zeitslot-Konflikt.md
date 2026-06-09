---
template-version: 1.0.0
linkservice-id: "urn:pfch:git:01932a4b-2c3d-7e4f-9a5b-1c6d7e8f9a0m:req/v1?anchor=true"
type: Business Rule
status: draft
completeness: Intermediate
responsible: "project-owner"
keywords: timeslot, conflict, parallel, group
ITAM-Application: TournamentPlanner
---

# [BR-004 – Gruppe-Zeitslot-Konflikt](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-2c3d-7e4f-9a5b-1c6d7e8f9a0m:req/v1)

---

## Description

> Diese Regel verhindert, dass eine Gruppe im selben Zeitslot in mehr als einer Paarung eingeplant wird, da eine Gruppe nicht gleichzeitig an zwei Orten spielen kann.

---

## Rule

> Eine Gruppe darf innerhalb desselben Zeitslots in höchstens einer platzierten Paarung vorkommen.

---

## Condition & Consequence

| | Description |
|---|---|
| **If** | Die Planungs-Engine oder der Turnierleiter versucht, eine Paarung in einen Zeitslot zu platzieren, in dem eine der beiden beteiligten Gruppen bereits in einer anderen Paarung vorkommt |
| **Then** | Die Platzierung wird abgelehnt; bei manuellem Verschieben wird die Zielzelle rot markiert mit dem Tooltip «[Gruppenname] spielt in diesem Zeitslot bereits» |
| **Else** | Die Paarung wird in den Zeitslot platziert |

---

## Affected Data Objects

- [DO-006 – Paarung](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-0c1d-7e2f-7a3b-9c4d5e6f7a8k:req/v1)
- [DO-004 – Zeitslot](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-5c6d-7e7f-2a8b-4c9d0e1f2a3f:req/v1)
- [DO-002 – Gruppe](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-3c4d-7e5f-0a6b-2c7d8e9f0a1d:req/v1)
