# ScanSnapper for Mac

USB barcode scanner application for macOS that receives Japanese text from BC-NL3000UII scanner and automatically pastes or types it into the active application.

## Features

- **Background menu bar app** - Runs silently in the menu bar
- **Two output modes**:
  - **Paste**: Copy to clipboard and send Cmd+V (fast, works in most apps)
  - **Type**: Character-by-character typing (works everywhere, including paste-restricted fields)
- **Japanese text support** - Full UTF-8 encoding with proper handling
- **Line ending normalization** - Automatically converts CRLF/CR to LF
- **Configurable suffix** - Add Tab or Enter after each scan
- **Inter-character delay** - Adjustable timing for Type mode (0/5/10ms)
- **Chunked QR support** - 200ms silence timeout for multi-part QR codes

## Requirements

- macOS 12.0 (Monterey) or later
- Intel or Apple Silicon Mac
- BC-NL3000UII barcode scanner configured for USB-COM mode
- Accessibility permissions (for keyboard injection)

## Installation

### Prerequisites

1. Install Xcode 14+ from the App Store
2. Install Command Line Tools:
   ```bash
   xcode-select --install
   ```

### Building from Source

1. Clone or download this repository
2. Open `ScanSnapper.xcodeproj` in Xcode
3. Add ORSSerialPort dependency:
   - File → Add Package Dependencies
   - URL: `https://github.com/armadsen/ORSSerialPort.git`
   - Version: 2.1.0 or later
4. Build the project (Cmd+B)
5. Run the app (Cmd+R)

### First Launch

On first launch, the app will request **Accessibility** permissions:

1. Click "Open System Settings" when prompted
2. Navigate to: **Privacy & Security → Accessibility**
3. Enable **ScanSnapper** in the list
4. Restart the app

## Scanner Configuration

### BC-NL3000UII Setup

1. **Switch to USB-COM mode** (scan configuration QR code from manual)
2. **Set encoding to UTF-8** (default)
3. **Set suffix**:
   - Recommended: **None** (handle suffix in app)
   - Alternative: **LF** (app will normalize to LF anyway)
4. **Disable flow control** (XON/XOFF and RTS/CTS should be OFF)

### Connection

- Connect scanner via USB
- The device will appear as `/dev/cu.usbmodemWXXXXXXXXX`
- Select the port from the menu bar app

## Usage

### Menu Bar Interface

Click the 📱 icon in the menu bar to access:

- **Port** - Select USB serial port (auto-detected)
- **Output Mode**
  - Paste: Fast clipboard-based injection
  - Type: Slower but universal character-by-character typing
- **Suffix** - Append after each scan
  - None
  - Tab
  - Enter
- **Inter-char Delay** - Typing speed for Type mode (0/5/10ms)
- **Trailing LF** - Add line feed at end
- **Open/Close Port** - Start/stop listening
- **Quit**

### Workflow

1. Select your scanner's port from the menu
2. Click "Open Port"
3. Icon changes to 📱✓ when connected
4. Scan a QR code or barcode
5. Text appears in the active application

### Output Mode Selection

**Use Paste mode when:**
- Target app accepts clipboard paste (Cmd+V)
- Speed is important
- Text is short to medium length

**Use Type mode when:**
- Paste doesn't work (restricted input fields)
- Target app has paste limitations
- You need keystroke-level simulation

## Troubleshooting

### Port Not Found

```bash
# Check if device is connected
ls /dev/cu.usbmodem*

# If empty, check USB connection and scanner mode
```

**Fix:**
- Reconnect USB cable
- Verify scanner is in USB-COM mode (not HID)
- Try different USB port

### Permission Denied

**Error**: "Failed to open port: Permission denied"

**Fix:**
1. Close any other apps using the port (`screen`, `minicom`, etc.)
2. Check System Settings → Privacy & Security → Full Disk Access (if needed)

### Text Not Appearing

**Symptoms**: Port opens, scanner beeps, but no text appears

**Fixes:**
1. Check accessibility permissions are granted
2. Try switching from Paste to Type mode
3. Verify target app's input field is focused
4. Check logs: `Console.app → filter: ScanSnapper`

### Japanese Text Corrupted

**Symptoms**: � characters or mojibake

**Fix:**
- Verify scanner is set to UTF-8 encoding (not Shift-JIS)
- Generate test QR with UTF-8 encoding
- Check with `screen -U /dev/cu.usbmodem... 9600`

### Characters Missing (Long Text)

**Symptoms**: Text cuts off or drops characters

**Fix:**
- Switch to Type mode
- Increase inter-char delay to 5ms or 10ms
- Reduce concurrent app load during scan

### Device Disconnected Error

**Symptoms**: "Serial port was removed from system"

**Fix:**
- Check USB connection
- Try different USB port
- Restart the app after reconnecting

## Technical Details

### Architecture

```
USB Scanner → ORSSerialPort → SerialManager → PasteService → Active App
                   ↓              ↓               ↓
              Background      Main Thread    Main Thread
                Thread       (200ms timer)   (CGEvent)
```

### Key Components

- **AppDelegate**: Menu bar UI, port selection, settings management
- **SerialManager**: USB-serial I/O, 200ms silence detection, text normalization
- **PasteService**: Keyboard injection (Paste via Cmd+V, Type via CGEvent)

### Text Processing Pipeline

1. Raw bytes received from USB
2. Buffer accumulation (200ms silence timeout)
3. UTF-8 decoding
4. Control character filtering (keep TAB, LF, 32-126)
5. Line ending normalization (CRLF/CR → LF)
6. Whitespace trimming
7. Output to active app

### Performance

- **Paste mode**: ~10-50ms latency (instant feel)
- **Type mode**:
  - 0ms delay: ~500 chars/sec
  - 5ms delay: ~200 chars/sec
  - 10ms delay: ~100 chars/sec

## Development

### Project Structure

```
ScanSnapper/
├── ScanSnapper.xcodeproj
├── Sources/
│   ├── AppDelegate.swift       # Menu bar UI and coordination
│   ├── SerialManager.swift     # USB-serial communication
│   ├── PasteService.swift      # Keyboard injection
│   ├── Info.plist              # LSUIElement=YES for menu bar
│   └── Assets.xcassets/        # App icon
└── README.md
```

### Dependencies

- **ORSSerialPort** (SPM): Serial port communication
  - Repository: https://github.com/armadsen/ORSSerialPort
  - Version: 2.1.0+
  - License: MIT

### Build Configuration

- **Minimum macOS**: 12.0
- **Swift Version**: 5.9+
- **Frameworks**: Cocoa, ApplicationServices
- **Entitlements**: com.apple.security.device.usb (for serial access)

### Logging

View logs in Console.app:
```
# Filter by process name
ScanSnapper

# Common log prefixes
[AppDelegate]
[SerialManager]
[PasteService]
```

## Known Limitations

- **IME compatibility**: Text is sent as finalized characters (IME should be OFF)
- **Paste-restricted apps**: Some apps block programmatic paste (use Type mode)
- **Background app activation**: Cmd+V may not work if target app isn't frontmost
- **Very long text**: 2000+ chars may timeout on slow systems (use Type mode with delay)

## License

This project uses ORSSerialPort (MIT License).

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review logs in Console.app
3. Test with `screen -U /dev/cu.usbmodem... 9600` to isolate scanner issues

## Version History

- **1.0.0** - Initial release
  - USB-COM serial communication
  - Paste and Type output modes
  - Japanese text support
  - 200ms silence detection
  - Configurable suffix and delays
