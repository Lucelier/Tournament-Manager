import SwiftUI

struct ExportView: View {
    @EnvironmentObject private var viewModel: TurnierViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var format: ExportFormat = .xlsx

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Exportieren")
                .font(.title2.bold())

            Picker("Format", selection: $format) {
                ForEach(ExportFormat.allCases) { format in
                    Text(format.rawValue).tag(format)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Spacer()
                Button("Abbrechen") {
                    dismiss()
                }
                Button("Speichern") {
                    dismiss()
                    viewModel.exportiere(format: format)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 360)
    }
}
