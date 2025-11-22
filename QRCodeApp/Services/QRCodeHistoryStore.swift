import Foundation

protocol QRCodeHistoryStoring {
    func load() throws -> [QRCodeEntry]
    func save(_ entries: [QRCodeEntry]) throws
}

enum QRCodeHistoryStoreError: LocalizedError {
    case unableToCreateDirectory
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .unableToCreateDirectory:
            return "Unable to create storage directory for history."
        case .encodingFailed:
            return "Failed to encode QR code history."
        }
    }
}

struct QRCodeHistoryStore: QRCodeHistoryStoring {
    private let fileManager: FileManager
    private let historyURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileManager: FileManager = .default, directoryURL: URL? = nil) {
        self.fileManager = fileManager
        let directory = directoryURL ?? QRCodeHistoryStore.makeDirectoryURL(using: fileManager)
        self.historyURL = directory.appendingPathComponent("history.json")
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }

    func load() throws -> [QRCodeEntry] {
        guard fileManager.fileExists(atPath: historyURL.path) else {
            return []
        }

        let data = try Data(contentsOf: historyURL)
        return try decoder.decode([QRCodeEntry].self, from: data)
    }

    func save(_ entries: [QRCodeEntry]) throws {
        try ensureDirectoryExists()
        do {
            let data = try encoder.encode(entries)
            try data.write(to: historyURL, options: [.atomic])
        } catch let encodingError as EncodingError {
            throw encodingError
        } catch {
            throw QRCodeHistoryStoreError.encodingFailed
        }
    }

    private func ensureDirectoryExists() throws {
        let directory = historyURL.deletingLastPathComponent()
        if fileManager.fileExists(atPath: directory.path) == false {
            do {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            } catch {
                throw QRCodeHistoryStoreError.unableToCreateDirectory
            }
        }
    }

    private static func makeDirectoryURL(using fileManager: FileManager) -> URL {
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupport = urls.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let bundleID = Bundle.main.bundleIdentifier ?? "QRCodeApp"
        return appSupport.appendingPathComponent(bundleID, isDirectory: true)
    }
}
