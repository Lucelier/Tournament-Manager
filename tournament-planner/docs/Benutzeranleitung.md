# TournamentPlanner – Benutzeranleitung

Diese Anleitung ist auch direkt in der App über den Knopf **«Hilfe»** (oben rechts im Setup und im Spielplan) abrufbar.

---

## 1. Turnierdaten erfassen

1. Gib einen **Turniernamen** ein.
2. Erfasse mindestens **zwei Gruppen** mit eindeutigen Namen.
3. Erfasse mindestens **eine Sportart**. Optional kannst du pro Sportart einen **Standort** angeben (z. B. «Halle 1», «Rasenplatz») – er erscheint im Spielplan klein unterhalb des Spaltentitels.
4. Erfasse mindestens **einen Zeitslot** mit Startzeit (Pflicht) und optionaler Endzeit.

> Tipp: Mit **«Beispieldaten»** füllst du das Setup mit einem kompletten Beispielturnier, um die App schnell auszuprobieren.

Fehlende oder doppelte Angaben werden unterhalb der Eingabebereiche rot angezeigt; der Knopf «Spielplan erstellen» bleibt deaktiviert, bis alles gültig ist.

## 2. Spielplan erstellen

Klicke auf **«Spielplan erstellen»**. Die Planungs-Engine verteilt die Paarungen automatisch nach festen Prioritäten:

1. Jede Gruppe soll **jede Sportart mindestens einmal** spielen.
2. **Gegnerwiederholungen** werden minimiert.
3. Das Raster wird **möglichst vollständig gefüllt**.

Eine Gruppe spielt nie zweimal im selben Zeitslot. Mit **«Neu berechnen»** erzeugst du eine alternative Verteilung.

## 3. Spielplan manuell anpassen

Ziehe eine Paarung per **Drag-and-drop** in eine andere Zelle. Unzulässige Ziele werden abgelehnt und kurz rot markiert:

- Die Zielzelle ist bereits belegt.
- Eine der beiden Gruppen spielt im Ziel-Zeitslot bereits.

## 4. Exportieren

Über **«Exportieren»** speicherst du den Spielplan als:

- **PDF** – A4-Querformat, druckfertig; bei vielen Zeitslots automatisch mehrseitig mit wiederholter Kopfzeile.
- **XLSX** – Tabellenkalkulation für Excel oder Numbers.

Der Dateiname wird automatisch aus Turniername und Datum vorgeschlagen.

## 5. Speicherung

Alle Eingaben werden **automatisch lokal gespeichert** (`~/Library/Application Support/TournamentPlanner/turnier.json`) und beim nächsten Start wieder geladen. Es werden keine Daten an externe Dienste übertragen.

Mit **«Zurück»** gelangst du vom Spielplan zurück ins Setup; der aktuelle Plan wird dabei nach Rückfrage verworfen.

---

*contributed by Luc Rossier*
