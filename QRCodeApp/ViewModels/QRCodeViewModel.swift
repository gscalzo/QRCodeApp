import SwiftUI
import Combine
import AppKit

@MainActor
final class QRCodeViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published private(set) var history: [QRCodeEntry] = []
    @Published var selectedEntry: QRCodeEntry?
    @Published var errorMessage: String?

    private let generator: QRCodeGenerating
    private let historyStore: QRCodeHistoryStoring
    private let exporter: ImageExporting

    private let imageSize: CGFloat = 512

    init(
        generator: QRCodeGenerating,
        historyStore: QRCodeHistoryStoring,
        exporter: ImageExporting
    ) {
        self.generator = generator
        self.historyStore = historyStore
        self.exporter = exporter

        loadHistory()
    }

    convenience init() {
        self.init(
            generator: QRCodeGenerator(),
            historyStore: QRCodeHistoryStore(),
            exporter: ImageExporter()
        )
    }

    var canGenerate: Bool {
        !trimmedInput.isEmpty
    }

    var trimmedInput: String {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func loadHistory() {
        do {
            history = try historyStore.load().sorted(by: { $0.createdAt > $1.createdAt })
            selectedEntry = history.first
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func generateCode() {
        guard canGenerate else { return }

        do {
            let image = try generator.generateImage(from: trimmedInput, size: imageSize)
            let data = try image.pngData()
            let entry = QRCodeEntry(text: trimmedInput, imageData: data)
            history.insert(entry, at: 0)
            selectedEntry = entry
            try historyStore.save(history)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectEntry(_ entry: QRCodeEntry?) {
        selectedEntry = entry
    }

    func reuseSelectedText() {
        guard let text = selectedEntry?.text else { return }
        inputText = text
    }

    func clearInput() {
        inputText = ""
    }

    func exportSelectedImage() async {
        guard let image = selectedEntry?.previewImage else {
            errorMessage = "Nothing to export."
            return
        }

        do {
            let suggestedName = makeFileName(from: selectedEntry)
            try await exporter.exportPNG(image: image, suggestedName: suggestedName)
        } catch ImageExporterError.userCancelled {
            // Ignore cancellations silently
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func dismissError() {
        errorMessage = nil
    }

    private func makeFileName(from entry: QRCodeEntry?) -> String {
        guard let entry else { return "QRCode.png" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let dateString = formatter.string(from: entry.createdAt)
        let sanitized = entry.text
            .split(separator: " ")
            .prefix(4)
            .joined(separator: "-")
        if sanitized.isEmpty {
            return "QRCode-\(dateString).png"
        } else {
            return "\(sanitized)-\(dateString).png"
        }
    }
}
