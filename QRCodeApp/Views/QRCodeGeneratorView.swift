import SwiftUI

struct QRCodeGeneratorView: View {
    @ObservedObject var viewModel: QRCodeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create a QR Code")
                .font(.largeTitle)
                .bold()

            TextField("Enter text, URL, or any value", text: $viewModel.inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
                .padding(.trailing)

            HStack(spacing: 12) {
                Button("Generate QR Code") {
                    viewModel.generateCode()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canGenerate)

                Button("Clear") {
                    viewModel.clearInput()
                }
                .disabled(viewModel.inputText.isEmpty)

                if viewModel.selectedEntry != nil {
                    Button("Reuse Selection") {
                        viewModel.reuseSelectedText()
                    }
                }

                Spacer()

                Button("Download PNG") {
                    Task { await viewModel.exportSelectedImage() }
                }
                .disabled(viewModel.selectedEntry == nil)
            }

            Divider()

            QRCodeDetailView(entry: viewModel.selectedEntry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
    }
}
