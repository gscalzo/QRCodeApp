import AppKit
import UniformTypeIdentifiers

protocol ImageExporting {
    @MainActor
    func exportPNG(image: NSImage, suggestedName: String) async throws
}

enum ImageExporterError: LocalizedError {
    case userCancelled

    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "Export cancelled."
        }
    }
}

struct ImageExporter: ImageExporting {
    @MainActor
    func exportPNG(image: NSImage, suggestedName: String) async throws {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = suggestedName

        let response: NSApplication.ModalResponse
        if let window = NSApp.mainWindow ?? NSApp.keyWindow {
            response = await panel.beginSheetModal(for: window)
        } else {
            response = panel.runModal()
        }

        guard response == .OK, let url = panel.url else {
            throw ImageExporterError.userCancelled
        }

        let data = try image.pngData()
        try data.write(to: url)
    }
}
