//
//  QRCodeAppTests.swift
//  QRCodeAppTests
//
//  Created by giordano scalzo on 22/11/2025.
//

import XCTest
import AppKit
@testable import QRCodeApp

final class QRCodeAppTests: XCTestCase {
    func testQRCodeGeneratorProducesImage() throws {
        let generator = QRCodeGenerator()
        let image = try generator.generateImage(from: "Hello, QR", size: 256)

        XCTAssertEqual(image.size.width, 256)
        XCTAssertEqual(image.size.height, 256)
        XCTAssertNotNil(image.tiffRepresentation)
    }

    func testHistoryStorePersistsEntries() throws {
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let store = QRCodeHistoryStore(fileManager: .default, directoryURL: tempDirectory)

        let data = Data(repeating: 0xAA, count: 16)
        let entry = QRCodeEntry(text: "Test", createdAt: Date(), imageData: data)

        try store.save([entry])
        let loaded = try store.load()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.text, "Test")
        XCTAssertEqual(loaded.first?.pngData(), data)
    }

    @MainActor
    func testViewModelAddsEntryToHistory() throws {
        let generator = MockGenerator()
        let store = InMemoryHistoryStore()
        let exporter = MockExporter()
        let viewModel = QRCodeViewModel(generator: generator, historyStore: store, exporter: exporter)

        viewModel.inputText = "Sample"
        viewModel.generateCode()

        XCTAssertEqual(viewModel.history.count, 1)
        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(viewModel.selectedEntry?.text, "Sample")
    }

    @MainActor
    func testExportUsesExporter() async {
        let generator = MockGenerator()
        let store = InMemoryHistoryStore()
        let exporter = MockExporter()
        let viewModel = QRCodeViewModel(generator: generator, historyStore: store, exporter: exporter)

        viewModel.inputText = "Export"
        viewModel.generateCode()

        await viewModel.exportSelectedImage()
        XCTAssertEqual(exporter.exportCount, 1)
    }
}

// MARK: - Test Doubles

private final class MockGenerator: QRCodeGenerating {
    func generateImage(from text: String, size: CGFloat) throws -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()
        NSColor.black.setFill()
        NSBezierPath(rect: NSRect(x: 0, y: 0, width: size, height: size)).fill()
        image.unlockFocus()
        return image
    }
}

private final class InMemoryHistoryStore: QRCodeHistoryStoring {
    var entries: [QRCodeEntry] = []

    func load() throws -> [QRCodeEntry] {
        entries
    }

    func save(_ entries: [QRCodeEntry]) throws {
        self.entries = entries
    }
}

private final class MockExporter: ImageExporting {
    var exportCount = 0

    @MainActor
    func exportPNG(image: NSImage, suggestedName: String) async throws {
        exportCount += 1
    }
}
