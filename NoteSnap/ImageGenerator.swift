//
//  ImageGenerator.swift
//  NoteSnap
//
//  Created by Charles Magnuson on 2/11/26.
//

import UIKit
import CoreGraphics

class ImageGenerator {
    private let backgroundColor: UIColor = .white
    private let textColor: UIColor = .black
    private let dpi: CGFloat = 300 // Standard 300 DPI for high-quality printing

    func generateImage(from text: String, widthInches: Double = 2.0, heightInches: Double = 3.0, qrCodeURL: String? = nil) -> UIImage {
        // Convert inches to pixels at 300 DPI
        let imageWidth = CGFloat(widthInches * Double(dpi))
        let imageHeight = CGFloat(heightInches * Double(dpi))
        let margin: CGFloat = min(imageWidth, imageHeight) * 0.05 // 5% margin relative to smallest dimension

        // Calculate QR code space requirements (20% of smaller dimension - significantly larger for better scanning)
        let qrSize = min(imageWidth, imageHeight) * 0.20
        let qrBottomMargin = margin
        let qrTotalHeight = qrCodeURL != nil ? qrSize + qrBottomMargin : 0

        let size = CGSize(width: imageWidth, height: imageHeight)

        // Adjust content rect to account for QR code space when QR is present
        let contentRect = CGRect(
            x: margin,
            y: margin,
            width: imageWidth - (margin * 2),
            height: imageHeight - (margin * 2) - qrTotalHeight
        )

        // Create the graphics context
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }

        // Fill background with white
        context.setFillColor(backgroundColor.cgColor)
        context.fill(CGRect(origin: .zero, size: size))

        // Calculate optimal font size and line spacing together
        let textSettings = calculateOptimalTextSettings(for: text, in: contentRect)
        drawText(text, fontSize: textSettings.fontSize, lineSpacing: textSettings.lineSpacing, in: contentRect, context: context)

        // Draw QR code if URL is provided
        if let qrCodeURL = qrCodeURL {
            drawQRCode(url: qrCodeURL, size: qrSize, imageSize: size, context: context)
        }

        // Generate the final image
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }

        return image
    }

    // MARK: - Text Layout Settings

    private struct TextSettings {
        let fontSize: CGFloat
        let lineSpacing: CGFloat
    }

    private func calculateOptimalTextSettings(for text: String, in rect: CGRect) -> TextSettings {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return TextSettings(fontSize: 24, lineSpacing: 4.8) }

        // Define ranges
        let minFontSize: CGFloat = 12
        let maxFontSize: CGFloat = 120
        let maxLineSpacingRatio: CGFloat = 0.2    // Comfortable spacing (current default)
        let minLineSpacingRatio: CGFloat = 0.05   // Minimum spacing to prevent overlap

        // Try different combinations, starting with largest font and most comfortable spacing
        for fontSize in stride(from: maxFontSize, through: minFontSize, by: -2) {
            // Try different line spacing ratios from comfortable to tight
            for spacingRatio in stride(from: maxLineSpacingRatio, through: minLineSpacingRatio, by: -0.02) {
                let lineSpacing = fontSize * spacingRatio
                let textSize = calculateTextSize(for: cleanText, fontSize: fontSize, lineSpacing: lineSpacing, maxWidth: rect.width)

                // If this combination fits, use it
                if textSize.height <= rect.height && textSize.width <= rect.width {
                    return TextSettings(fontSize: fontSize, lineSpacing: lineSpacing)
                }
            }
        }

        // If nothing fits, use minimum settings
        let fallbackLineSpacing = minFontSize * minLineSpacingRatio
        return TextSettings(fontSize: minFontSize, lineSpacing: fallbackLineSpacing)
    }

    private func calculateOptimalFontSize(for text: String, in rect: CGRect) -> CGFloat {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return 24 }

        // Define font size range for binary search
        let minFontSize: CGFloat = 12
        let maxFontSize: CGFloat = 120

        // Binary search for optimal font size
        var low: CGFloat = minFontSize
        var high: CGFloat = maxFontSize

        while high - low > 1 {
            let mid = (low + high) / 2
            let defaultLineSpacing = mid * 0.2  // Use default spacing for compatibility
            let textSize = calculateTextSize(for: cleanText, fontSize: mid, lineSpacing: defaultLineSpacing, maxWidth: rect.width)

            if textSize.height <= rect.height && textSize.width <= rect.width {
                low = mid
            } else {
                high = mid
            }
        }

        return low
    }

    private func calculateTextSize(for text: String, fontSize: CGFloat, lineSpacing: CGFloat, maxWidth: CGFloat) -> CGSize {
        let font = UIFont.systemFont(ofSize: fontSize)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = lineSpacing

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let boundingRect = attributedString.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        return boundingRect.size
    }

    private func drawText(_ text: String, fontSize: CGFloat, lineSpacing: CGFloat, in rect: CGRect, context: CGContext) {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return }

        let font = UIFont.systemFont(ofSize: fontSize)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = lineSpacing

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]

        let attributedString = NSAttributedString(string: cleanText, attributes: attributes)

        // Calculate the text size to center it vertically
        let textSize = attributedString.boundingRect(
            with: CGSize(width: rect.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size

        // Center the text vertically in the available space
        let yOffset = (rect.height - textSize.height) / 2
        let drawingRect = CGRect(
            x: rect.minX,
            y: rect.minY + max(0, yOffset),
            width: rect.width,
            height: rect.height
        )

        attributedString.draw(in: drawingRect)
    }

    // MARK: - QR Code Drawing

    private func drawQRCode(url: String, size: CGFloat, imageSize: CGSize, context: CGContext) {
        // Generate QR code image using the QRCodeGenerator utility
        let qrResult = QRCodeGenerator.generateQRCodeWithBackground(from: url, size: size)

        switch qrResult {
        case .success(let qrImage):
            // Calculate position for bottom-center placement
            let margin: CGFloat = min(imageSize.width, imageSize.height) * 0.05
            let qrX = (imageSize.width - size) / 2
            let qrY = imageSize.height - size - margin

            // Draw QR code at bottom-center position
            let qrRect = CGRect(x: qrX, y: qrY, width: size, height: size)
            qrImage.draw(in: qrRect)

        case .failure:
            // If QR code generation fails, silently continue without QR code
            // This ensures the image generation doesn't fail entirely
            break
        }
    }
}

// MARK: - UIImage Extension for debugging
extension UIImage {
    func debugDescription() -> String {
        return "UIImage(size: \(size), scale: \(scale))"
    }
}