import UIKit

/// Handles system clipboard interactions
class ClipboardManager {

    /// Reads the current clipboard content
    /// - Returns: String content from clipboard or nil if empty/unavailable
    static func getClipboardContent() -> String? {
        guard UIPasteboard.general.hasStrings else {
            return nil
        }

        let content = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines)
        return content?.isEmpty == false ? content : nil
    }

    /// Checks if clipboard contains any string content
    static func hasClipboardContent() -> Bool {
        return UIPasteboard.general.hasStrings && getClipboardContent() != nil
    }
}