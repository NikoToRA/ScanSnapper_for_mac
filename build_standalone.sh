#!/bin/bash

echo "🔨 Building standalone ScanSnapper.app..."

# Clean build
xcodebuild -project ScanSnapper.xcodeproj -scheme ScanSnapper -configuration Release clean build

if [ $? -eq 0 ]; then
    echo "✅ Build succeeded!"

    # Copy to Applications folder (optional)
    APP_PATH="$HOME/Library/Developer/Xcode/DerivedData/Build/Products/Release/ScanSnapper.app"

    if [ -d "$APP_PATH" ]; then
        echo "📦 Built app location: $APP_PATH"
        echo ""
        echo "To install:"
        echo "  cp -r \"$APP_PATH\" /Applications/"
        echo ""
        echo "To run now:"
        echo "  open \"$APP_PATH\""
        echo ""
        echo "⚠️  Important: After running the standalone app, grant accessibility"
        echo "   permission to ScanSnapper (not Xcode) in System Settings."

        # Ask if user wants to open the app now
        read -p "Open ScanSnapper.app now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            open "$APP_PATH"
        fi
    else
        echo "❌ Built app not found at expected location"
    fi
else
    echo "❌ Build failed"
    exit 1
fi
