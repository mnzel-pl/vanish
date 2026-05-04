#!/bin/bash
set -euo pipefail

APP_NAME="Vanish"
BUILD_DIR="$(pwd)/.build"
RELEASE_DIR="$(pwd)/release"
APP_BUNDLE="${RELEASE_DIR}/${APP_NAME}.app"

echo "==> Cleaning build directories..."
rm -rf "$BUILD_DIR" "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

echo "==> Building for x86_64..."
swift build -c release --arch x86_64

echo "==> Building for arm64..."
swift build -c release --arch arm64

X86_BIN="${BUILD_DIR}/x86_64-apple-macosx/release/${APP_NAME}"
ARM_BIN="${BUILD_DIR}/arm64-apple-macosx/release/${APP_NAME}"
UNIVERSAL_BIN="${RELEASE_DIR}/${APP_NAME}_universal"

echo "==> Creating universal binary with lipo..."
lipo -create "$X86_BIN" "$ARM_BIN" -output "$UNIVERSAL_BIN"
lipo -info "$UNIVERSAL_BIN"

echo "==> Assembling .app bundle..."
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"
cp "$UNIVERSAL_BIN" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
cp Info.plist "${APP_BUNDLE}/Contents/Info.plist"
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

echo "==> Packaging into .zip..."
cd "$RELEASE_DIR"
zip -r "${APP_NAME}.zip" "${APP_NAME}.app"
cd ..

ZIP_SIZE=$(du -h "${RELEASE_DIR}/${APP_NAME}.zip" | cut -f1)
echo ""
echo "==> Done!"
echo "    App:  ${APP_BUNDLE}"
echo "    Zip:  ${RELEASE_DIR}/${APP_NAME}.zip (${ZIP_SIZE})"
echo "    Arch: $(lipo -info "$UNIVERSAL_BIN" | awk -F': ' '{print $NF}')"
