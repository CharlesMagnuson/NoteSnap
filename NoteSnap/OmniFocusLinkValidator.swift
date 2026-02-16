import Foundation

/// Handles validation of OmniFocus deep links
class OmniFocusLinkValidator {

    private static let omnifocusScheme = "omnifocus:///task/"
    private static let minimumTaskIDLength = 8 // Reasonable minimum for UUIDs or other task identifiers

    /// Validates clipboard content for OmniFocus task links
    /// - Returns: Result containing valid URL string or QRCodeError
    static func validateClipboardContent() -> Result<String, QRCodeError> {
        // Check if clipboard has content
        guard let clipboardContent = ClipboardManager.getClipboardContent() else {
            return .failure(.emptyClipboard)
        }

        // Validate the OmniFocus link format
        return validateOmniFocusLink(clipboardContent)
    }

    /// Validates a specific string as an OmniFocus task link
    /// - Parameter link: The string to validate
    /// - Returns: Result containing valid URL string or QRCodeError
    static func validateOmniFocusLink(_ link: String) -> Result<String, QRCodeError> {
        let trimmedLink = link.trimmingCharacters(in: .whitespacesAndNewlines)

        // Check if the link starts with the correct scheme
        guard trimmedLink.lowercased().hasPrefix(omnifocusScheme) else {
            return .failure(.invalidFormat)
        }

        // Extract the task ID part (everything after the scheme)
        let taskIDPart = String(trimmedLink.dropFirst(omnifocusScheme.count))

        // Ensure there's a meaningful task ID
        guard taskIDPart.count >= minimumTaskIDLength else {
            return .failure(.invalidFormat)
        }

        // Additional validation: ensure task ID doesn't contain invalid characters
        // OmniFocus task IDs typically contain alphanumeric characters and hyphens
        let validTaskIDPattern = "^[A-Za-z0-9-_]+$"
        let taskIDRegex = try? NSRegularExpression(pattern: validTaskIDPattern)
        let taskIDRange = NSRange(location: 0, length: taskIDPart.count)

        guard let regex = taskIDRegex,
              regex.firstMatch(in: taskIDPart, options: [], range: taskIDRange) != nil else {
            return .failure(.invalidFormat)
        }

        return .success(trimmedLink)
    }

    /// Quick check if clipboard might contain an OmniFocus link (for UI status)
    /// - Returns: True if clipboard content looks like an OmniFocus link
    static func clipboardLikelyContainsOmniFocusLink() -> Bool {
        guard let content = ClipboardManager.getClipboardContent() else {
            return false
        }
        return content.lowercased().hasPrefix(omnifocusScheme)
    }
}