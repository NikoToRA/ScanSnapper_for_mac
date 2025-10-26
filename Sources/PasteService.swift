import Cocoa
import ApplicationServices

/// Service responsible for outputting text through either paste or type modes
class PasteService {

    // MARK: - Properties

    var outputMode: OutputMode = .paste
    var suffixMode: SuffixMode = .none
    var interCharDelay: InterCharDelay = .ms0
    var trailingLF: Bool = false

    // Track if accessibility alert has been shown
    private var hasShownAccessibilityAlert = false

    // MARK: - Public Methods

    /// Outputs text using the configured mode (paste or type)
    /// - Parameter text: The text to output
    func output(_ text: String) {
        assert(Thread.isMainThread, "output(_:) must be called on main thread")

        NSLog("[PasteService] output called with text length: \(text.count)")
        NSLog("[PasteService] Text: [\(text)]")
        NSLog("[PasteService] outputMode: \(outputMode), suffixMode: \(suffixMode), interCharDelay: \(interCharDelay), trailingLF: \(trailingLF)")

        // Check accessibility permissions (required for Type mode, optional for Paste mode)
        let hasAccessibility = AXIsProcessTrusted()
        if !hasAccessibility {
            NSLog("[PasteService] WARNING: Accessibility permissions not granted.")
            if outputMode == .type {
                NSLog("[PasteService] ERROR: Type mode requires accessibility. Aborting.")
                return
            } else {
                NSLog("[PasteService] INFO: Paste mode will attempt to work without accessibility.")
            }
        }

        // Prepare text with optional trailing LF
        var finalText = text
        if trailingLF {
            finalText += "\n"
            NSLog("[PasteService] Added trailing LF")
        }

        // Route to appropriate handler
        switch outputMode {
        case .paste:
            handlePasteMode(finalText)
        case .type:
            handleTypeMode(finalText)
        }

        // Apply suffix after a brief delay
        if suffixMode != .none {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.applySuffix()
            }
        }
    }

    // MARK: - Private Methods - Paste Mode

    private func handlePasteMode(_ text: String) {
        NSLog("[PasteService] Using paste mode")

        // Copy to clipboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        NSLog("[PasteService] Text copied to clipboard")

        // Brief delay to ensure clipboard is ready
        Thread.sleep(forTimeInterval: 0.01)

        // Synthesize Cmd+V
        synthesizeCmdV()
    }

    private func synthesizeCmdV() {
        NSLog("[PasteService] Synthesizing Cmd+V")

        // CRITICAL: Check accessibility permission before attempting to send events
        let hasAccessibility = AXIsProcessTrusted()
        NSLog("[PasteService] Accessibility permission status: \(hasAccessibility)")

        if !hasAccessibility {
            NSLog("[PasteService] ⚠️ WARNING: CGEvent posting requires accessibility permission!")
            NSLog("[PasteService] ⚠️ Text is in clipboard, but cannot auto-paste without permission")
            NSLog("[PasteService] ⚠️ Please manually press Cmd+V to paste, or grant accessibility permission")

            // Only show alert once per session
            if !hasShownAccessibilityAlert {
                hasShownAccessibilityAlert = true
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "アクセシビリティ権限が必要です"
                    alert.informativeText = "自動ペーストにはアクセシビリティ権限が必要です。\n\nテキストはクリップボードにコピー済みです。手動で Cmd+V を押してペーストするか、システム設定でアクセシビリティ権限を許可してください。\n\n注意: Xcodeから実行している場合は、Xcode自体にも権限が必要です。"
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: "システム設定を開く")
                    alert.addButton(withTitle: "OK (手動でペースト)")

                    if alert.runModal() == .alertFirstButtonReturn {
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                    }
                }
            }
            return
        }

        guard let eventSource = CGEventSource(stateID: .combinedSessionState) else {
            NSLog("[PasteService] ERROR: Failed to create CGEventSource")
            return
        }

        let cmdKeyCode: CGKeyCode = 0x37  // Command key
        let vKeyCode: CGKeyCode = 0x09    // V key

        // Small delay to ensure clipboard is ready and focus is on target app
        Thread.sleep(forTimeInterval: 0.05)

        // Cmd down
        guard let cmdDown = CGEvent(keyboardEventSource: eventSource, virtualKey: cmdKeyCode, keyDown: true) else {
            NSLog("[PasteService] ERROR: Failed to create Cmd down event")
            return
        }
        cmdDown.flags = .maskCommand
        cmdDown.post(tap: .cghidEventTap)
        NSLog("[PasteService] Posted Cmd down")

        // Small delay between key events
        Thread.sleep(forTimeInterval: 0.01)

        // V down
        guard let vDown = CGEvent(keyboardEventSource: eventSource, virtualKey: vKeyCode, keyDown: true) else {
            NSLog("[PasteService] ERROR: Failed to create V down event")
            return
        }
        vDown.flags = .maskCommand
        vDown.post(tap: .cghidEventTap)
        NSLog("[PasteService] Posted V down")

        // Small delay
        Thread.sleep(forTimeInterval: 0.01)

        // V up
        guard let vUp = CGEvent(keyboardEventSource: eventSource, virtualKey: vKeyCode, keyDown: false) else {
            NSLog("[PasteService] ERROR: Failed to create V up event")
            return
        }
        vUp.flags = .maskCommand
        vUp.post(tap: .cghidEventTap)
        NSLog("[PasteService] Posted V up")

        // Small delay
        Thread.sleep(forTimeInterval: 0.01)

        // Cmd up
        guard let cmdUp = CGEvent(keyboardEventSource: eventSource, virtualKey: cmdKeyCode, keyDown: false) else {
            NSLog("[PasteService] ERROR: Failed to create Cmd up event")
            return
        }
        cmdUp.post(tap: .cghidEventTap)
        NSLog("[PasteService] Posted Cmd up")

        NSLog("[PasteService] ✅ Cmd+V synthesized and posted successfully")
    }

    // MARK: - Private Methods - Type Mode

    private func handleTypeMode(_ text: String) {
        NSLog("[PasteService] Using type mode with inter-char delay: \(interCharDelay)")

        guard let eventSource = CGEventSource(stateID: .combinedSessionState) else {
            NSLog("[PasteService] ERROR: Failed to create CGEventSource")
            return
        }

        let delaySeconds: TimeInterval = {
            switch interCharDelay {
            case .ms0: return 0.0
            case .ms5: return 0.005
            case .ms10: return 0.01
            }
        }()

        for (index, char) in text.enumerated() {
            // Handle special characters with key codes
            if char == "\n" {
                typeKey(keyCode: 0x24, eventSource: eventSource)  // Enter
            } else if char == "\t" {
                typeKey(keyCode: 0x30, eventSource: eventSource)  // Tab
            } else {
                // Use Unicode string for international character support
                typeUnicodeCharacter(char, eventSource: eventSource)
            }

            // Apply inter-character delay (except after last character)
            if delaySeconds > 0 && index < text.count - 1 {
                Thread.sleep(forTimeInterval: delaySeconds)
            }
        }

        NSLog("[PasteService] Type mode completed, typed \(text.count) characters")
    }

    private func typeKey(keyCode: CGKeyCode, eventSource: CGEventSource) {
        // Key down
        if let keyDown = CGEvent(keyboardEventSource: eventSource, virtualKey: keyCode, keyDown: true) {
            keyDown.post(tap: .cgSessionEventTap)
        }

        // Key up
        if let keyUp = CGEvent(keyboardEventSource: eventSource, virtualKey: keyCode, keyDown: false) {
            keyUp.post(tap: .cgSessionEventTap)
        }
    }

    private func typeUnicodeCharacter(_ char: Character, eventSource: CGEventSource) {
        let string = String(char)

        // Create keyboard event and set Unicode string
        if let keyDown = CGEvent(keyboardEventSource: eventSource, virtualKey: 0, keyDown: true) {
            // Convert Swift String to UTF-16 for CGEvent
            let utf16Array = Array(string.utf16)
            keyDown.keyboardSetUnicodeString(stringLength: utf16Array.count, unicodeString: utf16Array)
            keyDown.post(tap: .cgSessionEventTap)
        }

        if let keyUp = CGEvent(keyboardEventSource: eventSource, virtualKey: 0, keyDown: false) {
            let utf16Array = Array(string.utf16)
            keyUp.keyboardSetUnicodeString(stringLength: utf16Array.count, unicodeString: utf16Array)
            keyUp.post(tap: .cgSessionEventTap)
        }
    }

    // MARK: - Private Methods - Suffix

    private func applySuffix() {
        assert(Thread.isMainThread, "applySuffix() must be called on main thread")

        guard suffixMode != .none else { return }

        NSLog("[PasteService] Applying suffix: \(suffixMode)")

        guard let eventSource = CGEventSource(stateID: .combinedSessionState) else {
            NSLog("[PasteService] ERROR: Failed to create CGEventSource for suffix")
            return
        }

        let keyCode: CGKeyCode = {
            switch suffixMode {
            case .tab: return 0x30   // Tab
            case .enter: return 0x24 // Enter
            case .none: return 0
            }
        }()

        if keyCode != 0 {
            typeKey(keyCode: keyCode, eventSource: eventSource)
            NSLog("[PasteService] Suffix applied successfully")
        }
    }
}
