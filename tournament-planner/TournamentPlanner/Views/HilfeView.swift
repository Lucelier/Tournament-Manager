import SwiftUI

struct HilfeView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Benutzeranleitung")
                    .font(.title2.bold())
                Spacer()
                Button("Schliessen") { dismiss() }
                    .keyboardShortcut(.cancelAction)
            }
            .padding(20)
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    abschnitt(
                        "1. Turnierdaten erfassen",
                        """
                        Gib zuerst einen Turniernamen ein. Erfasse danach mindestens zwei Gruppen, \
                        eine Sportart und einen Zeitslot. Bei jeder Sportart kannst du optional einen \
                        Standort angeben (z. B. «Halle 1») – er erscheint im Spielplan unterhalb des \
                        Spaltentitels. Zeitslots bestehen aus einer Startzeit (Pflicht) und einer \
                        optionalen Endzeit. Mit «Beispieldaten» kannst du die App schnell ausprobieren.
                        """
                    )
                    abschnitt(
                        "2. Spielplan erstellen",
                        """
                        Klicke auf «Spielplan erstellen». Die Planungs-Engine verteilt die Paarungen \
                        automatisch: Jede Gruppe soll jede Sportart mindestens einmal spielen, \
                        Wiederholungen derselben Gegner werden minimiert, und das Raster wird \
                        möglichst vollständig gefüllt. Eine Gruppe spielt nie zweimal im selben \
                        Zeitslot. Mit «Neu berechnen» erzeugst du eine alternative Verteilung.
                        """
                    )
                    abschnitt(
                        "3. Spielplan manuell anpassen",
                        """
                        Ziehe eine Paarung per Drag-and-drop in eine andere Zelle, um den Plan \
                        manuell zu korrigieren. Unzulässige Ziele (belegte Zelle, Gruppe spielt \
                        bereits in diesem Zeitslot) werden abgelehnt und kurz rot markiert.
                        """
                    )
                    abschnitt(
                        "4. Exportieren",
                        """
                        Über «Exportieren» speicherst du den Spielplan als PDF (A4 quer, bei vielen \
                        Zeitslots mehrseitig) oder als XLSX-Tabelle für Excel/Numbers. Der \
                        Dateiname wird automatisch aus Turniername und Datum vorgeschlagen.
                        """
                    )
                    abschnitt(
                        "5. Speicherung",
                        """
                        Alle Eingaben werden automatisch lokal gespeichert und beim nächsten Start \
                        wieder geladen. Mit «Zurück» gelangst du vom Spielplan zurück ins Setup; \
                        der aktuelle Plan wird dabei verworfen.
                        """
                    )
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: 560, height: 520)
    }

    private func abschnitt(_ titel: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titel)
                .font(.headline)
            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
