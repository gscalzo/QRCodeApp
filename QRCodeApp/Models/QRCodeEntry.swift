import Foundation
import AppKit

struct QRCodeEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let text: String
    let createdAt: Date
    private let imageData: Data

    init(id: UUID = UUID(), text: String, createdAt: Date = Date(), imageData: Data) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.imageData = imageData
    }

    var previewImage: NSImage? {
        NSImage(data: imageData)
    }

    func pngData() -> Data {
        imageData
    }
}
