import AppKit

enum ImageEncodingError: LocalizedError {
    case bitmapRepresentationMissing
    case pngEncodingFailed

    var errorDescription: String? {
        switch self {
        case .bitmapRepresentationMissing:
            return "Unable to create bitmap representation from image."
        case .pngEncodingFailed:
            return "Failed to encode PNG data from image."
        }
    }
}

extension NSImage {
    func pngData() throws -> Data {
        guard let tiffData = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            throw ImageEncodingError.bitmapRepresentationMissing
        }

        guard let data = bitmap.representation(using: .png, properties: [:]) else {
            throw ImageEncodingError.pngEncodingFailed
        }

        return data
    }
}
