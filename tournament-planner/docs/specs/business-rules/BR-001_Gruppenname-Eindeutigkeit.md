---
template-version: 1.0.0
linkservice-id: "urn:pfch:git:01932a4b-6c7d-7e8f-3a9b-5c0d1e2f3a4g:req/v1?anchor=true"
type: Business Rule
status: draft
completeness: Intermediate
responsible: "project-owner"
keywords: group, name, uniqueness, validation
ITAM-Application: TournamentPlanner
---

# [BR-001 – Gruppenname-Eindeutigkeit](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-6c7d-7e8f-3a9b-5c0d1e2f3a4g:req/v1)

---

## Description

> Diese Regel stellt sicher, dass innerhalb eines Turniers keine zwei Gruppen denselben Namen tragen, um eindeutige Identifizierbarkeit im Spielplan zu gewährleisten.

---

## Rule

> Eine Gruppe muss innerhalb desselben Turniers einen Namen besitzen, der sich von allen anderen Gruppennamen unterscheidet (Gross-/Kleinschreibung wird ignoriert).

---

## Condition & Consequence

| | Description |
|---|---|
| **If** | Der Turnierleiter vergibt oder ändert einen Gruppennamen auf einen Wert, der bereits einer anderen Gruppe im selben Turnier zugewiesen ist |
| **Then** | Die Eingabe wird als ungültig markiert, eine Fehlermeldung «Gruppenname bereits vergeben» wird angezeigt, und die Schaltfläche «Spielplan erstellen» bleibt deaktiviert |
| **Else** | Der Name wird akzeptiert und gespeichert |

---

## Affected Data Objects

- [DO-002 – Gruppe](https://linkservice.pnet.ch/link/urn:pfch:git:01932a4b-3c4d-7e5f-0a6b-2c7d8e9f0a1d:req/v1)
