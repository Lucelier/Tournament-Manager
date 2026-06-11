import AppKit
import Foundation

struct PDFExportService {
    private enum Layout {
        static let seitenGroesse = CGRect(x: 0, y: 0, width: 842, height: 595) // A4 Querformat
        static let rand: CGFloat = 28
        static let titelBereich: CGFloat = 50
        static let kopfzeilenHoehe: CGFloat = 40
        static let zeilenHoehe: CGFloat = 30
        static let kopfFuellung = NSColor(white: 0.93, alpha: 1)
        static let gitterFarbe = NSColor(white: 0.6, alpha: 1)
    }

    var zeilenProSeite: Int {
        let nutzbareHoehe = Layout.seitenGroesse.height
            - Layout.rand * 2
            - Layout.titelBereich
            - Layout.kopfzeilenHoehe
        return max(1, Int(nutzbareHoehe / Layout.zeilenHoehe))
    }

    func exportiere(turnier: Turnier, nach zielURL: URL) throws {
        let formatter = PlanExportFormatter(turnier: turnier)
        var mediaBox = Layout.seitenGroesse
        let data = NSMutableData()

        guard let consumer = CGDataConsumer(data: data as CFMutableData),
              let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw CocoaError(.fileWriteUnknown)
        }

        let seiten = aufgeteilteZeitslots(formatter.zeitslots)
        for (seitenIndex, zeitslots) in seiten.enumerated() {
            context.beginPDFPage(nil)
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
            zeichneSeite(
                formatter: formatter,
                zeitslots: zeitslots,
                seite: seitenIndex + 1,
                seitenGesamt: seiten.count
            )
            NSGraphicsContext.restoreGraphicsState()
            context.endPDFPage()
        }
        context.closePDF()
        try data.write(to: zielURL, options: .atomic)
    }

    private func aufgeteilteZeitslots(_ zeitslots: [Zeitslot]) -> [[Zeitslot]] {
        guard !zeitslots.isEmpty else { return [[]] }
        return stride(from: 0, to: zeitslots.count, by: zeilenProSeite).map {
            Array(zeitslots[$0..<min($0 + zeilenProSeite, zeitslots.count)])
        }
    }

    private func zeichneSeite(
        formatter: PlanExportFormatter,
        zeitslots: [Zeitslot],
        seite: Int,
        seitenGesamt: Int
    ) {
        let seitenRect = Layout.seitenGroesse

        let titel = formatter.turnier.name.isEmpty ? "Spielplan" : formatter.turnier.name
        titel.draw(
            at: CGPoint(x: Layout.rand, y: seitenRect.height - Layout.rand - 20),
            withAttributes: [
                .font: NSFont.boldSystemFont(ofSize: 16),
                .foregroundColor: NSColor.black
            ]
        )

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        var untertitel = "Exportiert am \(dateFormatter.string(from: Date()))"
        if seitenGesamt > 1 {
            untertitel += " – Seite \(seite) von \(seitenGesamt)"
        }
        untertitel.draw(
            at: CGPoint(x: Layout.rand, y: seitenRect.height - Layout.rand - 36),
            withAttributes: [
                .font: NSFont.systemFont(ofSize: 9),
                .foregroundColor: NSColor.darkGray
            ]
        )

        let signatur = "contributed by Luc Rossier"
        let signaturAttribute: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 7),
            .foregroundColor: NSColor.gray
        ]
        let signaturBreite = signatur.size(withAttributes: signaturAttribute).width
        signatur.draw(
            at: CGPoint(x: seitenRect.width - Layout.rand - signaturBreite, y: Layout.rand * 0.35),
            withAttributes: signaturAttribute
        )

        let spalten = formatter.sportarten.count + 1
        let spaltenBreite = (seitenRect.width - Layout.rand * 2) / CGFloat(spalten)
        let tabellenOberkante = seitenRect.height - Layout.rand - Layout.titelBereich

        for spalte in 0..<spalten {
            let rect = CGRect(
                x: Layout.rand + CGFloat(spalte) * spaltenBreite,
                y: tabellenOberkante - Layout.kopfzeilenHoehe,
                width: spaltenBreite,
                height: Layout.kopfzeilenHoehe
            )
            fuelleZelle(rect, hintergrund: Layout.kopfFuellung)
            guard spalte > 0 else { continue }

            let sportart = formatter.sportarten[spalte - 1]
            let standort = sportart.standort?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if standort.isEmpty {
                zeichneZentriert(sportart.name, in: rect, font: .boldSystemFont(ofSize: 10), farbe: .black)
            } else {
                let obereHaelfte = CGRect(x: rect.minX, y: rect.midY - 2, width: rect.width, height: rect.height / 2)
                let untereHaelfte = CGRect(x: rect.minX, y: rect.minY + 2, width: rect.width, height: rect.height / 2)
                zeichneZentriert(sportart.name, in: obereHaelfte, font: .boldSystemFont(ofSize: 10), farbe: .black)
                zeichneZentriert(standort, in: untereHaelfte, font: .systemFont(ofSize: 8), farbe: .darkGray)
            }
        }

        for (zeilenIndex, zeitslot) in zeitslots.enumerated() {
            let zeilenOberkante = tabellenOberkante - Layout.kopfzeilenHoehe - CGFloat(zeilenIndex) * Layout.zeilenHoehe
            for spalte in 0..<spalten {
                let rect = CGRect(
                    x: Layout.rand + CGFloat(spalte) * spaltenBreite,
                    y: zeilenOberkante - Layout.zeilenHoehe,
                    width: spaltenBreite,
                    height: Layout.zeilenHoehe
                )
                if spalte == 0 {
                    fuelleZelle(rect, hintergrund: Layout.kopfFuellung)
                    zeichneZentriert(zeitslot.anzeigeText, in: rect, font: .boldSystemFont(ofSize: 9), farbe: .black)
                } else {
                    fuelleZelle(rect, hintergrund: .white)
                    let text = formatter.zellenText(
                        sportartId: formatter.sportarten[spalte - 1].id,
                        zeitslotId: zeitslot.id
                    )
                    zeichneZentriert(text, in: rect, font: .systemFont(ofSize: 9), farbe: .black)
                }
            }
        }
    }

    private func fuelleZelle(_ rect: CGRect, hintergrund: NSColor) {
        hintergrund.setFill()
        NSBezierPath(rect: rect).fill()
        Layout.gitterFarbe.setStroke()
        NSBezierPath(rect: rect).stroke()
    }

    private func zeichneZentriert(_ text: String, in rect: CGRect, font: NSFont, farbe: NSColor) {
        guard !text.isEmpty else { return }
        let absatz = NSMutableParagraphStyle()
        absatz.alignment = .center
        absatz.lineBreakMode = .byTruncatingTail
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: farbe,
            .paragraphStyle: absatz
        ]
        let inhalt = rect.insetBy(dx: 3, dy: 0)
        let textHoehe = text.boundingRect(
            with: CGSize(width: inhalt.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            attributes: attributes
        ).height
        let textRect = CGRect(
            x: inhalt.minX,
            y: inhalt.midY - textHoehe / 2,
            width: inhalt.width,
            height: textHoehe
        )
        text.draw(with: textRect, options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], attributes: attributes)
    }
}
