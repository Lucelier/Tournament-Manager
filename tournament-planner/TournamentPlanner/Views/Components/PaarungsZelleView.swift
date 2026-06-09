import SwiftUI
import UniformTypeIdentifiers

struct PaarungsZelleView: View {
    @EnvironmentObject private var viewModel: TurnierViewModel
    let sportart: Sportart
    let zeitslot: Zeitslot

    private var position: ZellenPosition {
        ZellenPosition(sportartId: sportart.id, zeitslotId: zeitslot.id)
    }

    private var istKonflikt: Bool {
        viewModel.konfliktZelle == position
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(istKonflikt ? Color.red.opacity(0.14) : Color(nsColor: .textBackgroundColor))
            Rectangle()
                .stroke(istKonflikt ? .red : Color(nsColor: .separatorColor), lineWidth: istKonflikt ? 2 : 0.5)

            if let paarung = viewModel.paarung(sportartId: sportart.id, zeitslotId: zeitslot.id) {
                Text(viewModel.paarungText(paarung))
                    .font(.callout)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onDrag {
                        NSItemProvider(object: paarung.id.uuidString as NSString)
                    }
            } else {
                Text("Leer")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(width: 170, height: 72)
        .help(istKonflikt ? (viewModel.konfliktText ?? "") : "")
        .onDrop(of: [.text], isTargeted: nil) { providers in
            ladePaarungId(providers: providers) { paarungId in
                guard let paarungId else { return }
                viewModel.verschiebe(paarungId: paarungId, nach: position)
            }
            return true
        }
    }

    private func ladePaarungId(providers: [NSItemProvider], completion: @escaping (UUID?) -> Void) {
        guard let provider = providers.first else {
            completion(nil)
            return
        }

        provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { item, _ in
            let string: String?
            if let data = item as? Data {
                string = String(data: data, encoding: .utf8)
            } else if let value = item as? String {
                string = value
            } else if let value = item as? NSString {
                string = value as String
            } else {
                string = nil
            }

            DispatchQueue.main.async {
                completion(string.flatMap(UUID.init(uuidString:)))
            }
        }
    }
}
