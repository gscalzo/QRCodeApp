import SwiftUI

struct HistorySidebarView: View {
    @ObservedObject var viewModel: QRCodeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("History")
                .font(.title2)
                .bold()
                .padding(.horizontal)

            if viewModel.history.isEmpty {
                ContentUnavailableView(
                    "No QR Codes Yet",
                    systemImage: "qrcode",
                    description: Text("Generate a code to see it here.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.history, selection: $viewModel.selectedEntry) { entry in
                    HistoryRow(entry: entry)
                        .tag(entry)
                }
                .listStyle(.sidebar)
            }
        }
        .frame(minWidth: 220)
    }
}

private struct HistoryRow: View {
    let entry: QRCodeEntry

    var body: some View {
        HStack(spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.text)
                    .lineLimit(1)
                Text(entry.createdAt, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let image = entry.previewImage {
            Image(nsImage: image)
                .resizable()
                .interpolation(.none)
                .cornerRadius(4)
                .frame(width: 40, height: 40)
        } else {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(Image(systemName: "qrcode").foregroundStyle(.secondary))
        }
    }
}
