---
template-version: 1.0.0
linkservice-id: "urn:pfch:git:01932a4b-7c8d-7e9f-4a0b-6c1d2e3f4a5h:req/v1?anchor=true"
type: Business Rule
status: draft
completeness: Intermediate
responsible: "project-owner"
keywords: minimum, validation, groups, sports, timeslots
ITAM-Application: TournamentPlanner
---

# [BR-002 – Mindestanzahl-Turnierdaten](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-7c8d-7e9f-4a0b-6c1d2e3f4a5h:req/v1)

---

## Description

> Diese Regel definiert die Mindestanforderungen an ein Turnier, bevor eine Spielplanerstellung ausgelöst werden darf.

---

## Rule

> Ein Turnier muss mindestens 2 Gruppen, mindestens 1 Sportart und mindestens 1 Zeitslot enthalten, bevor der Spielplan erstellt werden kann.

---

## Condition & Consequence

| | Description |
|---|---|
| **If** | Die Anzahl der erfassten Gruppen < 2, oder keine Sportart erfasst, oder kein Zeitslot erfasst |
| **Then** | Die Schaltfläche «Spielplan erstellen» ist deaktiviert und eine kontextspezifische Validierungsmeldung wird angezeigt |
| **Else** | Die Schaltfläche «Spielplan erstellen» ist aktiv |

---

## Affected Data Objects

- [DO-001 – Turnier](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-2c3d-7e4f-9a5b-1c6d7e8f9a0c:req/v1)
- [DO-002 – Gruppe](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-3c4d-7e5f-0a6b-2c7d8e9f0a1d:req/v1)
- [DO-003 – Sportart](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-4c5d-7e6f-1a7b-3c8d9e0f1a2e:req/v1)
- [DO-004 – Zeitslot](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-5c6d-7e7f-2a8b-4c9d0e1f2a3f:req/v1)
