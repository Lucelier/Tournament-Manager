# TODO – Offene Findings aus dem Projekt-Review

Stand: 2026-07-09. Vollständiges Review aus den Sichten Business Analyse, Architektur,
Entwicklung, Testing, Security, Usability und DevOps. Unit-Tests zum Review-Zeitpunkt:
11/11 grün. Schweregrade: 🔴 Hoch · 🟡 Mittel · ⚪ Niedrig.

## Priorisierte Top-5

1. [ ] **DEV-1** – Fehlende Warnung bei unmöglicher Sportarten-Abdeckung
2. [ ] **DEV-2 / UX-1** – Datenverlust ohne Rückfrage (Cmd+N, «Beispieldaten»)
3. [ ] **SE-1** – Ad-hoc-Signatur macht DMG-Distribution für Dritte unbrauchbar
4. [ ] **DO-1** – Defekter swiftc-Fallback in `build_app.sh`
5. [ ] **AR-2 + SE-2** – zip-Prozess nativ ersetzen, danach Sandbox/Hardened Runtime aktivieren

---

## 1. Business Analyse

- [ ] 🟡 **BA-1 – DO-004-Constraints nicht umgesetzt:** Spec verlangt Format `HH:mm` und
  `endzeit > startzeit`; implementiert sind freie Textfelder ohne Formatprüfung
  (`Zeitslot.startzeit/endzeit`, `ZeitslotListeView.swift`). Tippfehler wandern ungefiltert
  in PDF/XLSX. *(siehe auch UX-3)*
- [ ] 🟡 **BA-2 – UC-003 E1 abweichend implementiert:** Spec fordert bei Schreibrechtsfehler
  eine spezifische Meldung und erneutes Öffnen des Speicherdialogs; implementiert ist nur ein
  generischer Alert ohne Retry (`TurnierViewModel.exportiere`).
- [ ] ⚪ **BA-3 – UC-001 Postcondition veraltet:** Spec sagt bei Abbruch «keine Daten
  persistiert» — tatsächlich speichert die App bei jeder Eingabe sofort. Spec anpassen.
- [ ] ⚪ **BA-4 – Spec-Abweichungen klein:** UC-001 Schritt 2 (Anzahlfeld vs. +/−-Buttons);
  NFR «300 dpi PDF» nicht sinnvoll (Vektor-PDF); Excel-2016-Kompatibilität ungeprüft.
- [ ] ⚪ **BA-5 – Spec-Hygiene:** UCs/DOs stehen auf `status: draft` trotz Release 1.0;
  tote `linkservice.pnet.ch`-Links in öffentlichem Repo.

## 2. Architektur

- [ ] 🟡 **AR-1 – `nichtPlatziert` ist toter Pfad:** Engine liefert es immer leer
  (`PlanungsEngine.erstelleSpielplan`), UI und `verschiebe()` unterstützen es aber.
  Entweder unplatzierbare Pflichtpaarungen dort ablegen oder Konstrukt entfernen.
- [ ] 🟡 **AR-2 – Sandbox-Inkompatibilität:** XLSX-Export ruft `/usr/bin/zip` als externen
  Prozess auf. Mit aktivierter App Sandbox bricht der Export (Kindprozess erbt keine
  Schreibrechte auf die NSSavePanel-URL). Native ZIP-Erzeugung implementieren.
- [ ] 🟡 **AR-3 – Planung synchron auf MainActor:** Bis zu 500 Multi-Start-Läufe mit
  O(Zellen²)-Phase-2; bei grossen Turnieren (≈20 Gruppen) friert die UI ein.
  Auf Hintergrund-Task auslagern.
- [ ] ⚪ **AR-4 – Keine Service-Abstraktionen:** ViewModel hält konkrete Service-Typen statt
  Protokolle → schlecht testbar (erklärt 28 % Coverage des ViewModels).

## 3. Entwicklung

- [ ] 🔴 **DEV-1 – `warnungZuWenigZellen` mathematisch unvollständig**
  (`TurnierViewModel.swift`): Geprüft wird nur `zeitslots < gruppen/2`. Wenn die
  Sportartenzahl der Engpass ist, fehlt die Warnung. Beispiel: 4 Gruppen, 3 Sportarten,
  2 Zeitslots → Abdeckung braucht 6 Spiele, möglich sind max. 4, keine Warnung.
  Korrekte Untergrenze: `zeitslots ≥ (gruppen × sportarten / 2) / min(gruppen/2, sportarten)`.
- [ ] 🔴 **DEV-2 – `neuesTurnier()` vernichtet Daten ohne Rückfrage:** Cmd+N ersetzt das
  Turnier inkl. Spielplan und persistiert sofort (kein Undo, Single-Document). Gleiches gilt
  für den «Beispieldaten»-Button in `SetupView`. Bestätigungsdialoge ergänzen. *(= UX-1)*
- [ ] ⚪ **DEV-3 – `konfliktZelle` wird nie automatisch zurückgesetzt:** Rote Markierung
  bleibt bis zur nächsten erfolgreichen Verschiebung; Hilfe verspricht «kurz rot markiert».
- [ ] ⚪ **DEV-4 – I/O bei jedem Tastendruck:** Jedes `onChange` schreibt das komplette JSON
  pretty-printed auf Platte. Debounce einführen.
- [ ] ⚪ **DEV-5 – Kleinigkeiten:** `PaarungsKey` normalisiert UUIDs über String-Roundtrip
  (fragil); `write(_:to:)` im XLSX-Service schluckt Encoding-Fehler still via
  Optional-Chaining; `onDisappear` als Speicher-Trigger feuert beim App-Quit nicht zuverlässig.

## 4. Testing

- [ ] 🟡 **TE-1 – ViewModel praktisch ungetestet (28 %):** Validierung, `verschiebe`-
  Orchestrierung und insbesondere `warnungZuWenigZellen` (DEV-1) ohne Tests.
- [ ] 🟡 **TE-2 – PersistenzService ohne Tests (56 %):** Speichern/Laden-Roundtrip und
  v. a. die `bezeichnung`-Migration (`Zeitslot.init(from:)`) ungetestet.
- [ ] ⚪ **TE-3 – Nicht-deterministische Engine-Tests:** `shuffled()` ohne seedbaren RNG →
  latentes Flakiness-Risiko. Injizierbaren `RandomNumberGenerator` einführen.
- [ ] ⚪ **TE-4 – Keine UI-/Integrationstests:** Drag-and-drop, Navigation und Export-Dialog
  nur manuell getestet.

## 5. Security

- [ ] 🔴 **SE-1 – Distribution ohne Developer-ID und Notarisierung:** Bundle ist nur
  ad-hoc-signiert (`TeamIdentifier=not set`). Heruntergeladene DMGs lehnt Gatekeeper als
  «beschädigt» ab; Empfänger müssen Quarantäne-Attribute manuell entfernen.
  Developer-ID-Zertifikat + `notarytool` einrichten.
- [ ] 🟡 **SE-2 – App Sandbox und Hardened Runtime deaktiviert:** In ARCH-001 selbst
  empfohlen; Aktivierung kollidiert mit AR-2 (zip-Prozess) — zuerst AR-2 lösen.
- [ ] ⚪ **SE-3 – Eingabe-Limits (DO-Specs: 1–50 Zeichen) nicht erzwungen:** Kosmetisch,
  da XML-Escaping und PDF-Truncation vorhanden.

## 6. Usability

- [ ] 🔴 **UX-1 – Datenverlust-Fallen:** Cmd+N und «Beispieldaten» ohne Bestätigung
  (= DEV-2); Entfernen einer Gruppe/Sportart/eines Zeitslots löscht einen bestehenden
  Spielplan kommentarlos.
- [ ] 🟡 **UX-2 – Tastaturbedienung unvollständig:** UC-001 fordert vollständige Bedienung
  ohne Maus; manuelles Verschieben existiert nur als Drag-and-drop. Accessibility-Labels
  auf Icon-Buttons (+/−) fehlen für VoiceOver.
- [ ] 🟡 **UX-3 – Zeitslot-Freitext:** Keine Formatführung (Time-Picker/Maske), keine
  Warnung bei Ende < Start, keine automatische Sortierung nach Uhrzeit. *(= BA-1)*
- [ ] ⚪ **UX-4 – Konflikt-Feedback:** Rote Markierung bleibt dauerhaft (DEV-3), Ursache nur
  per Hover-Tooltip erfahrbar.
- [ ] ⚪ **UX-5 – Drop-Ziele unsichtbar:** Leere Zellen zeigen nicht an, dass sie Drop-Ziele
  sind; `isTargeted` in `PaarungsZelleView` ungenutzt.

## 7. DevOps

- [ ] 🔴 **DO-1 – `build_app.sh`-Fallback defekt:** swiftc-Dateiliste enthält
  `HilfeView.swift` nicht → Fallback-Build schlägt fehl. Zudem nur `x86_64` (Apple Silicon
  nur via Rosetta) und driftendes Info.plist-Duplikat ohne AppIcon.
- [ ] 🟡 **DO-2 – Binärartefakte im Git:** `dist/TournamentPlanner.app` und DMG (≈5 MB)
  eingecheckt; `.gitignore` deckt `dist/` nicht ab. Artefakte in GitHub-Releases verschieben.
- [ ] 🟡 **DO-3 – Kein CI:** Keine GitHub-Actions-Workflows; Tests und Release-Builds laufen
  nur manuell. `macos-latest`-Workflow mit `xcodebuild test` ergänzen.
- [ ] ⚪ **DO-4 – Versionierung verstreut:** `CFBundleShortVersionString = 1.0` in zwei
  Info.plists hardcodiert; keine Git-Tags, kein dokumentierter Release-Prozess. Bundle-ID
  `ch.local.TournamentPlanner` für Notarisierung ungeeignet.
