import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Properties

    private var statusItem: NSStatusItem!
    private var serialManager: SerialManager!
    private var pasteService: PasteService!

    // Menu items that need dynamic updates
    private var portSubmenu: NSMenu!
    private var outputModeMenu: NSMenu!
    private var suffixMenu: NSMenu!
    private var delayMenu: NSMenu!
    private var trailingLFItem: NSMenuItem!
    private var portToggleItem: NSMenuItem!

    // Current settings
    private var selectedPortPath: String?
    private var outputMode: OutputMode = .paste
    private var suffixMode: SuffixMode = .none
    private var interCharDelay: InterCharDelay = .ms0
    private var trailingLF: Bool = false

    // MARK: - Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("========================================")
        NSLog("[AppDelegate] ✅ Application launching")
        NSLog("[AppDelegate] Current time: \(Date())")
        NSLog("========================================")

        // CRITICAL: Set activation policy to accessory/prohibited BEFORE creating status item
        // This prevents dock icon while allowing menu bar items
        NSApp.setActivationPolicy(.accessory)
        NSLog("[AppDelegate] ✅ Activation policy set to .accessory")

        // Check accessibility permissions
        NSLog("[AppDelegate] 🔍 Checking accessibility permissions...")
        checkAccessibilityPermissions()

        // Initialize services
        NSLog("[AppDelegate] 🔧 Initializing SerialManager...")
        serialManager = SerialManager()
        serialManager.delegate = self
        NSLog("[AppDelegate] ✅ SerialManager initialized")

        NSLog("[AppDelegate] 🔧 Initializing PasteService...")
        pasteService = PasteService()
        NSLog("[AppDelegate] ✅ PasteService initialized")

        // Setup menu bar
        NSLog("[AppDelegate] 📱 Setting up menu bar...")
        setupMenuBar()
        NSLog("[AppDelegate] ✅ Menu bar setup complete")

        // Start port discovery
        NSLog("[AppDelegate] 🔌 Starting port discovery...")
        discoverPorts()

        NSLog("========================================")
        NSLog("[AppDelegate] ✅✅✅ Application launched successfully")
        NSLog("========================================")
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSLog("[AppDelegate] Application terminating")
        serialManager.closePort()
    }

    // MARK: - Menu Bar Setup

    private func setupMenuBar() {
        NSLog("[setupMenuBar] 🚀 Starting menu bar setup")

        // Create status item with variable length (macOS will manage the size)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        NSLog("[setupMenuBar] ✅ Status item created")

        guard let button = statusItem.button else {
            NSLog("[setupMenuBar] ❌ ERROR: Failed to get status item button")
            return
        }
        NSLog("[setupMenuBar] ✅ Button obtained")

        // IMPORTANT: Set button properties BEFORE adding menu
        button.title = "QR"  // Simple text for maximum compatibility
        button.toolTip = "QR Scanner"
        NSLog("[setupMenuBar] ✅ Button title set to 'QR'")

        let menu = NSMenu()
        menu.autoenablesItems = false  // Manual control over menu items

        // Port Selection Submenu
        let portItem = NSMenuItem(title: "Port", action: nil, keyEquivalent: "")
        portSubmenu = NSMenu()
        portItem.submenu = portSubmenu
        menu.addItem(portItem)

        menu.addItem(NSMenuItem.separator())

        // Output Mode Submenu
        let outputItem = NSMenuItem(title: "Output Mode", action: nil, keyEquivalent: "")
        outputModeMenu = NSMenu()

        let pasteItem = NSMenuItem(title: "Paste", action: #selector(selectOutputMode(_:)), keyEquivalent: "")
        pasteItem.tag = OutputMode.paste.rawValue
        pasteItem.state = .on
        outputModeMenu.addItem(pasteItem)

        let typeItem = NSMenuItem(title: "Type", action: #selector(selectOutputMode(_:)), keyEquivalent: "")
        typeItem.tag = OutputMode.type.rawValue
        outputModeMenu.addItem(typeItem)

        outputItem.submenu = outputModeMenu
        menu.addItem(outputItem)

        // Suffix Mode Submenu
        let suffixItem = NSMenuItem(title: "Suffix", action: nil, keyEquivalent: "")
        suffixMenu = NSMenu()

        let noneItem = NSMenuItem(title: "None", action: #selector(selectSuffix(_:)), keyEquivalent: "")
        noneItem.tag = SuffixMode.none.rawValue
        noneItem.state = .on
        suffixMenu.addItem(noneItem)

        let tabItem = NSMenuItem(title: "Tab", action: #selector(selectSuffix(_:)), keyEquivalent: "")
        tabItem.tag = SuffixMode.tab.rawValue
        suffixMenu.addItem(tabItem)

        let enterItem = NSMenuItem(title: "Enter", action: #selector(selectSuffix(_:)), keyEquivalent: "")
        enterItem.tag = SuffixMode.enter.rawValue
        suffixMenu.addItem(enterItem)

        suffixItem.submenu = suffixMenu
        menu.addItem(suffixItem)

        // Inter-char Delay Submenu (disabled by default for Paste mode)
        let delayItem = NSMenuItem(title: "Inter-char Delay", action: nil, keyEquivalent: "")
        delayMenu = NSMenu()

        let delay0Item = NSMenuItem(title: "0ms", action: #selector(selectDelay(_:)), keyEquivalent: "")
        delay0Item.tag = InterCharDelay.ms0.rawValue
        delay0Item.state = .on
        delayMenu.addItem(delay0Item)

        let delay5Item = NSMenuItem(title: "5ms", action: #selector(selectDelay(_:)), keyEquivalent: "")
        delay5Item.tag = InterCharDelay.ms5.rawValue
        delayMenu.addItem(delay5Item)

        let delay10Item = NSMenuItem(title: "10ms", action: #selector(selectDelay(_:)), keyEquivalent: "")
        delay10Item.tag = InterCharDelay.ms10.rawValue
        delayMenu.addItem(delay10Item)

        delayItem.submenu = delayMenu
        delayItem.isEnabled = false // Disabled for Paste mode
        menu.addItem(delayItem)

        // Trailing LF checkbox
        trailingLFItem = NSMenuItem(title: "Trailing LF", action: #selector(toggleTrailingLF(_:)), keyEquivalent: "")
        trailingLFItem.state = .off
        menu.addItem(trailingLFItem)

        menu.addItem(NSMenuItem.separator())

        // Open/Close Port toggle
        portToggleItem = NSMenuItem(title: "Open Port", action: #selector(togglePort(_:)), keyEquivalent: "")
        portToggleItem.isEnabled = false // Disabled until port is selected
        menu.addItem(portToggleItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit(_:)), keyEquivalent: "q"))

        // Assign menu to status item
        statusItem.menu = menu
        NSLog("[setupMenuBar] ✅ Menu assigned to status item")

        // Ensure menu bar icon is visible
        statusItem.isVisible = true
        statusItem.button?.isEnabled = true
        NSLog("[setupMenuBar] ✅ Status item visibility and button enabled")

        // Force display update
        statusItem.button?.needsDisplay = true
        NSLog("[setupMenuBar] ✅ Button display refresh requested")

        NSLog("[AppDelegate] Menu bar setup complete")
    }

    // MARK: - Port Discovery

    private func discoverPorts() {
        NSLog("[AppDelegate] Discovering serial ports")

        portSubmenu.removeAllItems()

        let fileManager = FileManager.default
        let devPath = "/dev"

        do {
            let entries = try fileManager.contentsOfDirectory(atPath: devPath)
            let usbPorts = entries.filter { $0.hasPrefix("cu.usbmodem") }.sorted()

            NSLog("[AppDelegate] Found \(usbPorts.count) USB modem ports")

            if usbPorts.isEmpty {
                let noPortItem = NSMenuItem(title: "No ports found", action: nil, keyEquivalent: "")
                noPortItem.isEnabled = false
                portSubmenu.addItem(noPortItem)
            } else {
                var firstPortPath: String?
                for portName in usbPorts {
                    let portPath = "/dev/\(portName)"
                    let portItem = NSMenuItem(title: portName, action: #selector(selectPort(_:)), keyEquivalent: "")
                    portItem.representedObject = portPath
                    portSubmenu.addItem(portItem)

                    NSLog("[AppDelegate] Added port: \(portPath)")

                    if firstPortPath == nil {
                        firstPortPath = portPath
                    }
                }

                // Auto-select and open the first port
                if let firstPort = firstPortPath {
                    NSLog("[AppDelegate] 🔌 Auto-selecting first port: \(firstPort)")
                    selectedPortPath = firstPort
                    portToggleItem.isEnabled = true

                    // Auto-open the port at 9600 baud
                    NSLog("[AppDelegate] 🔌 Auto-opening port: \(firstPort) at 9600 baud")
                    serialManager.openPort(path: firstPort, baudRate: 9600)
                }
            }

            portSubmenu.addItem(NSMenuItem.separator())
            let refreshItem = NSMenuItem(title: "Refresh", action: #selector(refreshPorts(_:)), keyEquivalent: "")
            portSubmenu.addItem(refreshItem)

        } catch let scanError {
            NSLog("[AppDelegate] ERROR: Failed to scan /dev directory: \(scanError.localizedDescription)")

            let errorItem = NSMenuItem(title: "Error scanning ports", action: nil, keyEquivalent: "")
            errorItem.isEnabled = false
            portSubmenu.addItem(errorItem)
        }
    }

    // MARK: - Accessibility Check

    private func checkAccessibilityPermissions() {
        // Request accessibility permission with prompt
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options)

        if !trusted {
            NSLog("[AppDelegate] WARNING: Accessibility permissions not granted")
            NSLog("[AppDelegate] System permission dialog should appear...")

            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Accessibility Permission Required"
                alert.informativeText = "ScanSnapper needs accessibility permission to simulate keyboard input in Type mode.\n\nPlease grant permission in System Settings > Privacy & Security > Accessibility."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "Open System Settings")
                alert.addButton(withTitle: "Remind Me Later")

                let response = alert.runModal()

                if response == .alertFirstButtonReturn {
                    NSLog("[AppDelegate] Opening System Settings for accessibility")
                    let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                    NSWorkspace.shared.open(url)
                }
            }
        } else {
            NSLog("[AppDelegate] Accessibility permissions granted")
        }
    }

    // MARK: - Menu Actions

    @objc private func selectPort(_ sender: NSMenuItem) {
        guard let portPath = sender.representedObject as? String else {
            NSLog("[AppDelegate] ERROR: Invalid port selection")
            return
        }

        NSLog("[AppDelegate] Port selected: \(portPath)")

        // Close current port if open
        if serialManager.isPortOpen {
            serialManager.closePort()
        }

        // Update selection
        selectedPortPath = portPath

        // Update menu checkmarks
        for item in portSubmenu.items {
            item.state = (item.representedObject as? String) == portPath ? .on : .off
        }

        // Enable port toggle button
        portToggleItem.isEnabled = true
        portToggleItem.title = "Open Port"
    }

    @objc private func refreshPorts(_ sender: NSMenuItem) {
        NSLog("[AppDelegate] Refreshing port list")
        discoverPorts()
    }

    @objc private func selectOutputMode(_ sender: NSMenuItem) {
        guard let mode = OutputMode(rawValue: sender.tag) else {
            NSLog("[AppDelegate] ERROR: Invalid output mode tag")
            return
        }

        NSLog("[AppDelegate] Output mode changed to: \(mode)")

        outputMode = mode

        // Update menu checkmarks
        for item in outputModeMenu.items {
            item.state = (item.tag == mode.rawValue) ? .on : .off
        }

        // Enable/disable delay menu based on mode
        if let delayMenuItem = statusItem.menu?.items.first(where: { $0.title == "Inter-char Delay" }) {
            delayMenuItem.isEnabled = (mode == .type)
        }

        // Update paste service mode
        pasteService.outputMode = mode
    }

    @objc private func selectSuffix(_ sender: NSMenuItem) {
        guard let mode = SuffixMode(rawValue: sender.tag) else {
            NSLog("[AppDelegate] ERROR: Invalid suffix mode tag")
            return
        }

        NSLog("[AppDelegate] Suffix mode changed to: \(mode)")

        suffixMode = mode

        // Update menu checkmarks
        for item in suffixMenu.items {
            item.state = (item.tag == mode.rawValue) ? .on : .off
        }

        // Update paste service suffix
        pasteService.suffixMode = mode
    }

    @objc private func selectDelay(_ sender: NSMenuItem) {
        guard let delay = InterCharDelay(rawValue: sender.tag) else {
            NSLog("[AppDelegate] ERROR: Invalid delay tag")
            return
        }

        NSLog("[AppDelegate] Inter-char delay changed to: \(delay)")

        interCharDelay = delay

        // Update menu checkmarks
        for item in delayMenu.items {
            item.state = (item.tag == delay.rawValue) ? .on : .off
        }

        // Update paste service delay
        pasteService.interCharDelay = delay
    }

    @objc private func toggleTrailingLF(_ sender: NSMenuItem) {
        trailingLF.toggle()
        sender.state = trailingLF ? .on : .off

        NSLog("[AppDelegate] Trailing LF toggled: \(trailingLF)")

        // Update paste service
        pasteService.trailingLF = trailingLF
    }

    @objc private func togglePort(_ sender: NSMenuItem) {
        if serialManager.isPortOpen {
            NSLog("[AppDelegate] Closing port")
            serialManager.closePort()
        } else {
            guard let portPath = selectedPortPath else {
                NSLog("[AppDelegate] ERROR: No port selected")
                showError(message: "Please select a port first")
                return
            }

            NSLog("[AppDelegate] Opening port: \(portPath)")
            serialManager.openPort(path: portPath, baudRate: 9600)
        }
    }

    @objc private func quit(_ sender: NSMenuItem) {
        NSLog("[AppDelegate] Quit requested")
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Helper Methods

    private func showError(message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    private func showNotification(title: String, message: String) {
        NSLog("[AppDelegate] Notification: \(title) - \(message)")
        // Note: Using NSLog instead of deprecated NSUserNotification
        // For production, consider migrating to UserNotifications framework
    }
}

// MARK: - SerialManagerDelegate

extension AppDelegate: SerialManagerDelegate {
    func serialManager(_ manager: SerialManager, didOpenPort portPath: String) {
        NSLog("[AppDelegate] Port opened: \(portPath)")

        DispatchQueue.main.async { [weak self] in
            self?.portToggleItem.title = "Close Port"
            self?.statusItem.button?.title = "📱✓"
        }
    }

    func serialManager(_ manager: SerialManager, didClosePort portPath: String) {
        NSLog("[AppDelegate] Port closed: \(portPath)")

        DispatchQueue.main.async { [weak self] in
            self?.portToggleItem.title = "Open Port"
            self?.statusItem.button?.title = "📱"
        }
    }

    func serialManager(_ manager: SerialManager, didReceiveData data: String) {
        NSLog("[AppDelegate] Received data: \(data)")

        // Pass data to paste service for output
        pasteService.output(data)
    }

    func serialManager(_ manager: SerialManager, didEncounterError error: Error) {
        NSLog("[AppDelegate] Serial error: \(error.localizedDescription)")

        DispatchQueue.main.async { [weak self] in
            self?.showError(message: "Serial port error: \(error.localizedDescription)")
            self?.portToggleItem.title = "Open Port"
            self?.statusItem.button?.title = "📱"
        }
    }
}

// MARK: - Enums

enum OutputMode: Int {
    case paste = 0
    case type = 1
}

enum SuffixMode: Int {
    case none = 0
    case tab = 1
    case enter = 2
}

enum InterCharDelay: Int {
    case ms0 = 0
    case ms5 = 5
    case ms10 = 10
}
