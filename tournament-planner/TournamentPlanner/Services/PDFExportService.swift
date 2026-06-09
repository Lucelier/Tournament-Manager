import AppKit
import Foundation
import PDFKit

struct PDFExportService {
    func exportiere(turnier: Turnier, nach zielURL: URL) throws {
        let formatter = PlanExportFormatter(turnier: turnier)
        let pageRect = CGRect(x: 0, y: 0, width: 842, height: 595)
        let data = NSMutableData()

        guard let consumer = CGDataConsumer(data: data as CFMutableData),
              let context = CGContext(consumer: consumer, mediaBox: nil, nil) else {
            throw CocoaError(.fileWriteUnknown)
        }

        context.beginPDFPage([kCGPDFContextMediaBox as String: pageRect] as CFDictionary)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)

        zeichne(formatter: formatter, in: pageRect)

        NSGraphicsContext.restoreGraphicsState()
        context.endPDFPage()
        context.closePDF()
        try data.write(to: zielURL, options: .atomic)
    }

    private func zeichne(formatter: PlanExportFormatter, in pageRect: CGRect) {
        let margin: CGFloat = 28
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 18),
            .foregroundColor: NSColor.labelColor
        ]
        let smallAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10),
            .foregroundColor: NSColor.secondaryLabelColor
        ]

        let title = formatter.turnier.name.isEmpty ? "Spielplan" : formatter.turnier.name
        title.draw(at: CGPoint(x: margin, y: pageRect.height - margin - 20), withAttributes: titleAttributes)

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        "Exportiert am \(dateFormatter.string(from: Date()))"
            .draw(at: CGPoint(x: margin, y: pageRect.height - margin - 38), withAttributes: smallAttributes)

        let tableTop = pageRect.height - margin - 64
        let tableHeight = tableTop - margin
        let rowCount = max(formatter.zeitslots.count + 1, 1)
        let columnCount = max(formatter.sportarten.count + 1, 1)
        let cellWidth = (pageRect.width - margin * 2) / CGFloat(columnCount)
        let cellHeight = min(34, tableHeight / CGFloat(rowCount))
        let fontSize = max(7, min(11, cellHeight * 0.32))

        for row in 0..<rowCount {
            for column in 0..<columnCount {
                let rect = CGRect(
                    x: margin + CGFloat(column) * cellWidth,
                    y: tableTop - CGFloat(row + 1) * cellHeight,
                    width: cellWidth,
                    height: cellHeight
                )
                NSColor.gridColor.setStroke()
                NSBezierPath(rect: rect).stroke()

                let isHeader = row == 0 || column == 0
                if isHeader {
                    NSColor.controlBackgroundColor.setFill()
                    NSBezierPath(rect: rect).fill()
                }

                let text: String
                if row == 0 && column == 0 {
                    text = ""
                } else if row == 0 {
                    text = formatter.sportarten[column - 1].name
                } else if column == 0 {
                    text = formatter.zeitslots[row - 1].anzeigeText
                } else {
                    text = formatter.zellenText(
                        sportartId: formatter.sportarten[column - 1].id,
                        zeitslotId: formatter.zeitslots[row - 1].id
                    )
                }

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: isHeader ? NSFont.boldSystemFont(ofSize: fontSize) : NSFont.systemFont(ofSize: fontSize),
                    .foregroundColor: NSColor.labelColor
                ]
                text.draw(
                    with: rect.insetBy(dx: 5, dy: 5),
                    options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
                    attributes: attributes
                )
            }
        }
    }
}
