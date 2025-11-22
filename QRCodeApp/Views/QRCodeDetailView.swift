import SwiftUI
import AppKit

struct QRCodeDetailView: View {
    let entry: QRCodeEntry?

    var body: some View {
        VStack(spacing: 16) {
            if let image = entry?.previewImage {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(maxWidth: 360, maxHeight: 360)
                    .padding()
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Input")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(entry?.text ?? "")
                        .font(.headline)
                        .textSelection(.enabled)

                    Text(entry?.createdAt ?? .now, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ContentUnavailableView("No Selection", systemImage: "qrcode", description: Text("Pick a QR code from the history or generate a new one."))
            }
        }
        .padding()
    }
}
