import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import AppKit

protocol QRCodeGenerating {
    func generateImage(from text: String, size: CGFloat) throws -> NSImage
}

enum QRCodeGeneratorError: LocalizedError {
    case invalidInputData
    case missingOutputImage

    var errorDescription: String? {
        switch self {
        case .invalidInputData:
            return "Unable to encode text into QR data."
        case .missingOutputImage:
            return "Failed to create QR code image."
        }
    }
}

struct QRCodeGenerator: QRCodeGenerating {
    private let context = CIContext()

    func generateImage(from text: String, size: CGFloat) throws -> NSImage {
        guard let messageData = text.data(using: .utf8) else {
            throw QRCodeGeneratorError.invalidInputData
        }

        let filter = CIFilter.qrCodeGenerator()
        filter.message = messageData
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else {
            throw QRCodeGeneratorError.missingOutputImage
        }

        let scale = size / outputImage.extent.width
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledImage = outputImage.transformed(by: transform)

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            throw QRCodeGeneratorError.missingOutputImage
        }

        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        bitmapRep.size = NSSize(width: size, height: size)

        let image = NSImage(size: NSSize(width: size, height: size))
        image.addRepresentation(bitmapRep)
        return image
    }
}
