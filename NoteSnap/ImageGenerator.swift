//
//  ImageGenerator.swift
//  NoteSnap
//
//  Created by Charles Magnuson on 2/11/26.
//

import UIKit
import CoreGraphics

class ImageGenerator {
    // Image specifications for 2"x3" at 300 DPI
    private let imageWidth: CGFloat = 600
    private let imageHeight: CGFloat = 900
    private let margin: CGFloat = 30
    private let backgroundColor: UIColor = .white
    private let textColor: UIColor = .black

    func generateImage(from text: String) -> UIImage {
        let size = CGSize(width: imageWidth, height: imageHeight)
        let contentRect = CGRect(
            x: margin,
            y: margin,
            width: imageWidth - (margin * 2),
            height: imageHeight - (margin * 2)
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

        // Calculate optimal font size and draw text
        let optimalFontSize = calculateOptimalFontSize(for: text, in: contentRect)
        drawText(text, fontSize: optimalFontSize, in: contentRect, context: context)

        // Generate the final image
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }

        return image
    }

    private func calculateOptimalFontSize(for text: String, in rect: CGRect) -> CGFloat {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return 24 }

        // Start with a reasonable font size and adjust
        var fontSize: CGFloat = 60
        let minFontSize: CGFloat = 12
        let maxFontSize: CGFloat = 120

        // Binary search for optimal font size
        var low: CGFloat = minFontSize
        var high: CGFloat = maxFontSize

        while high - low > 1 {
            let mid = (low + high) / 2
            let textSize = calculateTextSize(for: cleanText, fontSize: mid, maxWidth: rect.width)

            if textSize.height <= rect.height && textSize.width <= rect.width {
                low = mid
            } else {
                high = mid
            }
        }

        return low
    }

    private func calculateTextSize(for text: String, fontSize: CGFloat, maxWidth: CGFloat) -> CGSize {
        let font = UIFont.systemFont(ofSize: fontSize)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping

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

    private func drawText(_ text: String, fontSize: CGFloat, in rect: CGRect, context: CGContext) {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return }

        let font = UIFont.systemFont(ofSize: fontSize)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping

        // Calculate line spacing for better readability
        let lineSpacing = fontSize * 0.2
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
}

// MARK: - UIImage Extension for debugging
extension UIImage {
    func debugDescription() -> String {
        return "UIImage(size: \(size), scale: \(scale))"
    }
}