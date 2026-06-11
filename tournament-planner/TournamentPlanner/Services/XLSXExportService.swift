import Foundation

enum XLSXExportFehler: LocalizedError {
    case zipFehlgeschlagen

    var errorDescription: String? {
        switch self {
        case .zipFehlgeschlagen:
            return "XLSX-Datei konnte nicht erzeugt werden."
        }
    }
}

struct XLSXExportService {
    func exportiere(turnier: Turnier, nach zielURL: URL) throws {
        let formatter = PlanExportFormatter(turnier: turnier)
        let tempRoot = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempRoot, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        try schreibePaket(in: tempRoot, formatter: formatter)
        if FileManager.default.fileExists(atPath: zielURL.path) {
            try FileManager.default.removeItem(at: zielURL)
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        process.arguments = ["-qr", zielURL.path, "."]
        process.currentDirectoryURL = tempRoot
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw XLSXExportFehler.zipFehlgeschlagen
        }
    }

    private func schreibePaket(in root: URL, formatter: PlanExportFormatter) throws {
        let rels = root.appendingPathComponent("_rels", isDirectory: true)
        let xl = root.appendingPathComponent("xl", isDirectory: true)
        let xlRels = xl.appendingPathComponent("_rels", isDirectory: true)
        let worksheets = xl.appendingPathComponent("worksheets", isDirectory: true)
        try FileManager.default.createDirectory(at: rels, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: xlRels, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: worksheets, withIntermediateDirectories: true)

        try write(contentTypes, to: root.appendingPathComponent("[Content_Types].xml"))
        try write(rootRels, to: rels.appendingPathComponent(".rels"))
        try write(workbook, to: xl.appendingPathComponent("workbook.xml"))
        try write(workbookRels, to: xlRels.appendingPathComponent("workbook.xml.rels"))
        try write(styles, to: xl.appendingPathComponent("styles.xml"))
        try write(sheetXML(formatter: formatter), to: worksheets.appendingPathComponent("sheet1.xml"))
    }

    private func write(_ string: String, to url: URL) throws {
        try string.data(using: .utf8)?.write(to: url)
    }

    private func sheetXML(formatter: PlanExportFormatter) -> String {
        var rows: [String] = []
        var headerCells = [cell("A1", "", style: 1)]
        for (index, sportart) in formatter.sportarten.enumerated() {
            headerCells.append(cell(columnName(index + 2) + "1", formatter.spaltenTitel(fuer: sportart), style: 1))
        }
        rows.append("<row r=\"1\" ht=\"30\" customHeight=\"1\">\(headerCells.joined())</row>")

        for (rowIndex, zeitslot) in formatter.zeitslots.enumerated() {
            let row = rowIndex + 2
            var cells = [cell("A\(row)", zeitslot.anzeigeText, style: 1)]
            for (colIndex, sportart) in formatter.sportarten.enumerated() {
                let coordinate = columnName(colIndex + 2) + "\(row)"
                cells.append(cell(coordinate, formatter.zellenText(sportartId: sportart.id, zeitslotId: zeitslot.id), style: 2))
            }
            rows.append("<row r=\"\(row)\">\(cells.joined())</row>")
        }

        let signaturRow = formatter.zeitslots.count + 3
        rows.append("<row r=\"\(signaturRow)\">\(cell("A\(signaturRow)", "contributed by Luc Rossier", style: 0))</row>")

        let letzteSpalte = max(2, formatter.sportarten.count + 1)
        return """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
          <cols>
            <col min="1" max="1" width="16" customWidth="1"/>
            <col min="2" max="\(letzteSpalte)" width="26" customWidth="1"/>
          </cols>
          <sheetData>
            \(rows.joined(separator: "\n"))
          </sheetData>
        </worksheet>
        """
    }

    private func cell(_ ref: String, _ value: String, style: Int) -> String {
        let escaped = value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
        return "<c r=\"\(ref)\" t=\"inlineStr\" s=\"\(style)\"><is><t>\(escaped)</t></is></c>"
    }

    private func columnName(_ number: Int) -> String {
        var number = number
        var result = ""
        while number > 0 {
            let remainder = (number - 1) % 26
            result = String(UnicodeScalar(65 + remainder)!) + result
            number = (number - 1) / 26
        }
        return result
    }

    private var contentTypes: String {
        """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
          <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
          <Default Extension="xml" ContentType="application/xml"/>
          <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
          <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
          <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
        </Types>
        """
    }

    private var rootRels: String {
        """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
        </Relationships>
        """
    }

    private var workbook: String {
        """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
          <sheets>
            <sheet name="Spielplan" sheetId="1" r:id="rId1"/>
          </sheets>
        </workbook>
        """
    }

    private var workbookRels: String {
        """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
          <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
          <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
        </Relationships>
        """
    }

    private var styles: String {
        """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
          <fonts count="2"><font><sz val="12"/><name val="Helvetica"/></font><font><b/><sz val="12"/><name val="Helvetica"/></font></fonts>
          <fills count="1"><fill><patternFill patternType="none"/></fill></fills>
          <borders count="2"><border/><border><left style="thin"/><right style="thin"/><top style="thin"/><bottom style="thin"/></border></borders>
          <cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>
          <cellXfs count="3"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/><xf numFmtId="0" fontId="1" fillId="0" borderId="1" applyFont="1" applyBorder="1" applyAlignment="1"><alignment horizontal="center" vertical="center" wrapText="1"/></xf><xf numFmtId="0" fontId="0" fillId="0" borderId="1" applyBorder="1" applyAlignment="1"><alignment horizontal="center" vertical="center"/></xf></cellXfs>
        </styleSheet>
        """
    }
}
