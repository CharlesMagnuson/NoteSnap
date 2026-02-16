import Foundation

enum QRCodeError: Error, LocalizedError {
    case emptyClipboard
    case invalidFormat
    case generationFailed

    var errorDescription: String? {
        switch self {
        case .emptyClipboard:
            return "Clipboard is empty. Please copy an OmniFocus task link first."
        case .invalidFormat:
            return "Invalid link format. Please copy a link that starts with 'omnifocus:///task/'."
        case .generationFailed:
            return "Failed to generate QR code. Please try again."
        }
    }

    /// Provides detailed user guidance for each error type
    var recoverySuggestion: String? {
        switch self {
        case .emptyClipboard:
            return "Go to OmniFocus, select a task, and tap 'Copy Link' from the share menu."
        case .invalidFormat:
            return "Make sure you're copying a task link from OmniFocus, not regular text or other app links."
        case .generationFailed:
            return "Check that your device has sufficient memory and try creating a shorter note."
        }
    }
}