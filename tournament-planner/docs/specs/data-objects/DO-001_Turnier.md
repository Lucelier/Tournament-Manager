---
template-version: 1.0.0
linkservice-id: "urn:pfch:git:01932a4b-2c3d-7e4f-9a5b-1c6d7e8f9a0c:req/v1?anchor=true"
type: Data Object
status: draft
completeness: Intermediate
responsible: "project-owner"
keywords: tournament, root, configuration
ITAM-Application: TournamentPlanner
---

# [DO-001 – Turnier](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-2c3d-7e4f-9a5b-1c6d7e8f9a0c:req/v1)

---

## Description

> Das Turnier-Objekt ist das Wurzelelement der Applikation. Es fasst alle Konfigurationsdaten (Gruppen, Sportarten, Zeitslots) und den daraus erzeugten Spielplan zusammen.

---

## Attributes

| Attribute | Type | Required | Description |
|---|---|---|---|
| id | `String` | `yes` | Eindeutige UUID des Turniers (UUIDv4, clientseitig generiert) |
| name | `String` | `yes` | Frei wählbarer Turniername, max. 100 Zeichen |
| erstelltAm | `Date` | `yes` | Timestamp der Erstellung (ISO-8601) |
| gruppen | `Object` | `yes` | Geordnete Liste der Gruppen (→ DO-002) |
| sportarten | `Object` | `yes` | Geordnete Liste der Sportarten (→ DO-003) |
| zeitslots | `Object` | `yes` | Geordnete Liste der Zeitslots (→ DO-004) |
| spielplan | `Object` | `no` | Zugehöriger Spielplan; null, solange noch nicht berechnet (→ DO-005) |

---

## Value Ranges & Constraints

- **name**: 1–100 Zeichen; darf nicht leer sein
- **gruppen**: min. 2 Einträge (→ BR-002)
- **sportarten**: min. 1 Eintrag (→ BR-002)
- **zeitslots**: min. 1 Eintrag (→ BR-002)
- **erstelltAm**: UTC-Timestamp, ISO-8601-Format

---

## Relationships

- **Contains**: [DO-002 – Gruppe](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-3c4d-7e5f-0a6b-2c7d8e9f0a1d:req/v1)
- **Contains**: [DO-003 – Sportart](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-4c5d-7e6f-1a7b-3c8d9e0f1a2e:req/v1)
- **Contains**: [DO-004 – Zeitslot](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-5c6d-7e7f-2a8b-4c9d0e1f2a3f:req/v1)
- **Contains**: [DO-005 – Spielplan](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-9c0d-7e1f-6a2b-8c3d4e5f6a7j:req/v1)
