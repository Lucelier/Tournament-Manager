---
template-version: 1.0.0
linkservice-id: "urn:pfch:git:01932a4b-1c2d-7e3f-8a4b-0c5d6e7f8a9l:req/v1?anchor=true"
type: Business Rule
status: draft
completeness: Intermediate
responsible: "project-owner"
keywords: sport, coverage, priority, duplicate
ITAM-Application: TournamentPlanner
---

# [BR-003 – Sportarten-Abdeckung](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-1c2d-7e3f-8a4b-0c5d6e7f8a9l:req/v1)

---

## Description

> Diese Regel stellt sicher, dass jede Gruppe jede Sportart möglichst mindestens einmal spielt. Zusätzliche Spiele in bereits gespielten Sportarten sind erlaubt, wenn sie helfen, Felder zu füllen.

---

## Rule

> Die Planungs-Engine maximiert die Anzahl unterschiedlicher Gruppe-Sportart-Kombinationen, nachdem Zeitslot-Konflikte ausgeschlossen wurden. Danach darf eine Gruppe eine Sportart erneut spielen, um möglichst viele Felder zu füllen.

---

## Condition & Consequence

| | Description |
|---|---|
| **If** | Eine Platzierung eine noch fehlende Gruppe-Sportart-Kombination abdeckt |
| **Then** | Die Planungs-Engine bevorzugt diese Platzierung gegenüber einer Sportart-Wiederholung |
| **Else** | Die Paarung darf trotzdem platziert werden, um weitere Felder zu füllen, sofern keine höher priorisierte Regel verletzt wird |

---

## Affected Data Objects

- [DO-006 – Paarung](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-0c1d-7e2f-7a3b-9c4d5e6f7a8k:req/v1)
- [DO-005 – Spielplan](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-9c0d-7e1f-6a2b-8c3d4e5f6a7j:req/v1)
