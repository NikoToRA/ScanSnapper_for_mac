#!/bin/bash

# ScanSnapper Release Build Script
# This script builds a Release version of ScanSnapper and creates a distributable ZIP file

set -e  # Exit on any error

echo "========================================="
echo "ScanSnapper Release Build Script"
echo "========================================="
echo ""

# Configuration
PROJECT_NAME="ScanSnapper"
SCHEME_NAME="ScanSnapper"
CONFIGURATION="Release"
BUILD_DIR="./build"
ARCHIVE_PATH="${BUILD_DIR}/${PROJECT_NAME}.xcarchive"
DIST_DIR="${BUILD_DIR}/dist"
VERSION="1.0.0"
DIST_NAME="${PROJECT_NAME}_v${VERSION}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Clean previous builds
echo -e "${YELLOW}[1/6] Cleaning previous builds...${NC}"
if [ -d "${BUILD_DIR}" ]; then
    rm -rf "${BUILD_DIR}"
    echo "✓ Removed old build directory"
fi
mkdir -p "${BUILD_DIR}"
mkdir -p "${DIST_DIR}"
echo ""

# Step 2: Build the project
echo -e "${YELLOW}[2/6] Building ${PROJECT_NAME} in ${CONFIGURATION} configuration...${NC}"
xcodebuild -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME_NAME}" \
    -configuration "${CONFIGURATION}" \
    clean archive \
    -archivePath "${ARCHIVE_PATH}" \
    | grep -E "^\*\*|^Build|^Archive|^Command" || true

if [ ! -d "${ARCHIVE_PATH}" ]; then
    echo -e "${RED}✗ Build failed - archive not created${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Build successful${NC}"
echo ""

# Step 3: Extract .app from archive
echo -e "${YELLOW}[3/6] Extracting application...${NC}"
APP_PATH="${ARCHIVE_PATH}/Products/Applications/${PROJECT_NAME}.app"

if [ ! -d "${APP_PATH}" ]; then
    echo -e "${RED}✗ Application not found in archive${NC}"
    exit 1
fi

cp -R "${APP_PATH}" "${DIST_DIR}/"
echo -e "${GREEN}✓ Application extracted${NC}"
echo ""

# Step 4: Copy documentation
echo -e "${YELLOW}[4/6] Copying documentation...${NC}"
if [ -f "INSTALLATION.md" ]; then
    cp INSTALLATION.md "${DIST_DIR}/"
    echo "✓ Copied INSTALLATION.md"
fi

if [ -f "README.md" ]; then
    cp README.md "${DIST_DIR}/"
    echo "✓ Copied README.md"
fi

if [ -f "LICENSE" ]; then
    cp LICENSE "${DIST_DIR}/"
    echo "✓ Copied LICENSE"
fi
echo ""

# Step 5: Create distribution directory structure
echo -e "${YELLOW}[5/6] Creating distribution package...${NC}"
FINAL_DIST_DIR="${BUILD_DIR}/${DIST_NAME}"
mv "${DIST_DIR}" "${FINAL_DIST_DIR}"
echo -e "${GREEN}✓ Distribution directory created: ${FINAL_DIST_DIR}${NC}"
echo ""

# Step 6: Create ZIP archive
echo -e "${YELLOW}[6/6] Creating ZIP archive...${NC}"
cd "${BUILD_DIR}"
ZIP_NAME="${DIST_NAME}.zip"

# Use ditto for better macOS compatibility (preserves resource forks and metadata)
ditto -c -k --keepParent "${DIST_NAME}" "${ZIP_NAME}"

if [ ! -f "${ZIP_NAME}" ]; then
    echo -e "${RED}✗ ZIP creation failed${NC}"
    exit 1
fi

cd - > /dev/null
echo -e "${GREEN}✓ ZIP archive created${NC}"
echo ""

# Summary
echo "========================================="
echo -e "${GREEN}Build Complete!${NC}"
echo "========================================="
echo ""
echo "Distribution package: ${BUILD_DIR}/${ZIP_NAME}"
echo "Size: $(du -h "${BUILD_DIR}/${ZIP_NAME}" | cut -f1)"
echo ""
echo "Contents:"
echo "  • ${PROJECT_NAME}.app"
if [ -f "${FINAL_DIST_DIR}/INSTALLATION.md" ]; then
    echo "  • INSTALLATION.md"
fi
if [ -f "${FINAL_DIST_DIR}/README.md" ]; then
    echo "  • README.md"
fi
if [ -f "${FINAL_DIST_DIR}/LICENSE" ]; then
    echo "  • LICENSE"
fi
echo ""
echo "Next steps:"
echo "  1. Test the application in ${FINAL_DIST_DIR}/"
echo "  2. Upload ${BUILD_DIR}/${ZIP_NAME} to GitHub Releases"
echo ""
echo "To create a GitHub release:"
echo "  gh release create v${VERSION} \\"
echo "    --title \"${PROJECT_NAME} v${VERSION}\" \\"
echo "    --notes \"Initial release\" \\"
echo "    ${BUILD_DIR}/${ZIP_NAME}"
echo ""
echo "========================================="
