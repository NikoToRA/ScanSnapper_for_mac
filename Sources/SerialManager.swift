//
//  SerialManager.swift
//  ScanSnapper
//
//  Serial port manager for barcode scanner communication
//

import Foundation
import ORSSerial

protocol SerialManagerDelegate: AnyObject {
    func serialManager(_ manager: SerialManager, didOpenPort portPath: String)
    func serialManager(_ manager: SerialManager, didClosePort portPath: String)
    func serialManager(_ manager: SerialManager, didReceiveData data: String)
    func serialManager(_ manager: SerialManager, didEncounterError error: Error)
}

class SerialManager: NSObject {

    // MARK: - Properties

    weak var delegate: SerialManagerDelegate?
    private var serialPort: ORSSerialPort?
    private(set) var isPortOpen: Bool = false

    private var dataBuffer: Data = Data()
    private var silenceTimer: Timer?
    private let timeoutInterval: TimeInterval = 0.20 // 200ms

    // MARK: - Public Methods

    func openPort(path: String, baudRate: Int) {
        NSLog("[SerialManager] Opening port: %@ at baud rate: %d", path, baudRate)

        // Close existing port if open
        closePort()

        guard let port = ORSSerialPort(path: path) else {
            NSLog("[SerialManager] Failed to create serial port for path: %@", path)
            let error = NSError(domain: "SerialManager", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Failed to create serial port"])
            notifyError(error)
            return
        }

        // Configure port settings
        port.baudRate = NSNumber(value: baudRate)
        port.numberOfDataBits = 8
        port.numberOfStopBits = 1
        port.parity = .none
        port.usesRTSCTSFlowControl = false
        port.usesDTRDSRFlowControl = false
        port.delegate = self

        serialPort = port

        // Open the port
        port.open()
    }

    func closePort() {
        guard let port = serialPort else { return }

        NSLog("[SerialManager] Closing port: %@", port.path)

        // Cancel any pending timeout
        cancelSilenceTimer()

        // Clear buffer
        dataBuffer.removeAll()

        // Close port
        port.close()
        port.delegate = nil
        serialPort = nil
        isPortOpen = false
    }

    // MARK: - Private Methods

    private func handleReceivedData(_ data: Data) {
        // Append to buffer
        dataBuffer.append(data)

        // Reset silence timer
        resetSilenceTimer()
    }

    private func resetSilenceTimer() {
        cancelSilenceTimer()

        // Create new timer on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.silenceTimer = Timer.scheduledTimer(withTimeInterval: self.timeoutInterval, repeats: false) { [weak self] _ in
                self?.handleSilenceTimeout()
            }
        }
    }

    private func cancelSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = nil
    }

    private func handleSilenceTimeout() {
        guard !dataBuffer.isEmpty else { return }

        NSLog("[SerialManager] Silence timeout reached, processing buffer (%d bytes)", dataBuffer.count)

        // Decode and normalize data
        if let rawString = String(data: dataBuffer, encoding: .utf8) {
            let normalized = normalizeText(rawString)

            if !normalized.isEmpty {
                NSLog("[SerialManager] Received normalized data: %@", normalized)
                notifyDataReceived(normalized)
            } else {
                NSLog("[SerialManager] Normalized data is empty after filtering")
            }
        } else {
            NSLog("[SerialManager] Failed to decode buffer as UTF-8")
        }

        // Clear buffer
        dataBuffer.removeAll()
    }

    private func normalizeText(_ text: String) -> String {
        var result = ""

        // Filter only harmful control characters, keep all printable characters including Unicode (Japanese, etc.)
        for scalar in text.unicodeScalars {
            let value = scalar.value

            // Keep TAB (9) and LF (10)
            if value == 9 || value == 10 {
                result.append(Character(scalar))
            }
            // Convert CR (13) to LF
            else if value == 13 {
                result.append("\n")
            }
            // Keep all printable ASCII (32-126) and all Unicode characters above 127 (includes Japanese)
            else if (value >= 32 && value <= 126) || value > 127 {
                result.append(Character(scalar))
            }
            // Filter out other control characters (0-8, 11-12, 14-31)
        }

        // Replace CRLF with LF (in case any CR slipped through)
        result = result.replacingOccurrences(of: "\r\n", with: "\n")
        result = result.replacingOccurrences(of: "\r", with: "\n")

        // Trim leading/trailing whitespace
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)

        return result
    }

    private func assertDTRAndRTS() {
        guard let port = serialPort else { return }

        NSLog("[SerialManager] Asserting DTR and RTS")
        port.dtr = true
        port.rts = true
    }

    // MARK: - Delegate Notifications

    private func notifyPortOpened(_ portPath: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.serialManager(self, didOpenPort: portPath)
        }
    }

    private func notifyPortClosed(_ portPath: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.serialManager(self, didClosePort: portPath)
        }
    }

    private func notifyDataReceived(_ data: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.serialManager(self, didReceiveData: data)
        }
    }

    private func notifyError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.serialManager(self, didEncounterError: error)
        }
    }
}

// MARK: - ORSSerialPortDelegate

extension SerialManager: ORSSerialPortDelegate {

    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        NSLog("[SerialManager] Port opened: %@", serialPort.path)
        isPortOpen = true

        // Assert DTR and RTS
        assertDTRAndRTS()

        // Notify delegate
        notifyPortOpened(serialPort.path)
    }

    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        NSLog("[SerialManager] Port closed: %@", serialPort.path)
        isPortOpen = false

        // Cancel timeout and clear buffer
        cancelSilenceTimer()
        dataBuffer.removeAll()

        // Notify delegate
        notifyPortClosed(serialPort.path)
    }

    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        NSLog("[SerialManager] Received %d bytes", data.count)
        handleReceivedData(data)
    }

    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        NSLog("[SerialManager] Port error: %@", error.localizedDescription)
        notifyError(error)
    }

    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        NSLog("[SerialManager] Port removed from system: %@", serialPort.path)
        isPortOpen = false

        // Cancel timeout and clear buffer
        cancelSilenceTimer()
        dataBuffer.removeAll()

        // Notify as port closed
        notifyPortClosed(serialPort.path)

        // Create error for device removal
        let error = NSError(domain: "SerialManager", code: -2,
                          userInfo: [NSLocalizedDescriptionKey: "Serial port was removed from system"])
        notifyError(error)
    }
}
