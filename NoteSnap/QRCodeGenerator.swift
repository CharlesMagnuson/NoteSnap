import UIKit
import CoreImage

/// Generates QR codes using Core Image
class QRCodeGenerator {

    /// Generates a QR code image for the given text
    /// - Parameters:
    ///   - text: The text to encode in the QR code
    ///   - size: The desired size of the QR code (default: 100x100)
    /// - Returns: Result containing UIImage or QRCodeError
    static func generateQRCode(from text: String, size: CGFloat = 100) -> Result<UIImage, QRCodeError> {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.generationFailed)
        }

        guard let data = text.data(using: .utf8) else {
            return .failure(.generationFailed)
        }

        // Create QR code filter
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return .failure(.generationFailed)
        }

        // Set input data
        qrFilter.setValue(data, forKey: "inputMessage")
        // Set error correction level to Medium (25% recovery)
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")

        // Get the output image
        guard let qrCodeImage = qrFilter.outputImage else {
            return .failure(.generationFailed)
        }

        // Scale the QR code to the desired size
        let scaleX = size / qrCodeImage.extent.width
        let scaleY = size / qrCodeImage.extent.height
        let scaledImage = qrCodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        // Convert CIImage to UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return .failure(.generationFailed)
        }

        let uiImage = UIImage(cgImage: cgImage)
        return .success(uiImage)
    }

    /// Creates a QR code with a white background and border for better contrast
    /// - Parameters:
    ///   - text: The text to encode
    ///   - size: The desired QR code size
    ///   - borderSize: The border width (default: 4 pixels)
    /// - Returns: Result containing UIImage with white background or QRCodeError
    static func generateQRCodeWithBackground(from text: String, size: CGFloat = 100, borderSize: CGFloat = 4) -> Result<UIImage, QRCodeError> {
        let qrResult = generateQRCode(from: text, size: size - (borderSize * 2))

        switch qrResult {
        case .success(let qrImage):
            // Create a white background with border
            let backgroundSize = size
            UIGraphicsBeginImageContextWithOptions(CGSize(width: backgroundSize, height: backgroundSize), false, 0)
            defer { UIGraphicsEndImageContext() }

            guard let context = UIGraphicsGetCurrentContext() else {
                return .failure(.generationFailed)
            }

            // Draw white background
            context.setFillColor(UIColor.white.cgColor)
            context.fill(CGRect(origin: .zero, size: CGSize(width: backgroundSize, height: backgroundSize)))

            // Draw thin border
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(1)
            let borderRect = CGRect(x: 0.5, y: 0.5, width: backgroundSize - 1, height: backgroundSize - 1)
            context.stroke(borderRect)

            // Draw the QR code centered
            let qrRect = CGRect(
                x: borderSize,
                y: borderSize,
                width: size - (borderSize * 2),
                height: size - (borderSize * 2)
            )
            qrImage.draw(in: qrRect)

            guard let finalImage = UIGraphicsGetImageFromCurrentImageContext() else {
                return .failure(.generationFailed)
            }

            return .success(finalImage)

        case .failure(let error):
            return .failure(error)
        }
    }
}