#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VELOCITY_JAR="$ROOT_DIR/velocity.jar"
OUT_JAR="$ROOT_DIR/plugins/kGuard-1.0.0.jar"
BUILD_DIR="$SCRIPT_DIR/build"

if [ ! -f "$VELOCITY_JAR" ]; then
    echo "[HATA] velocity.jar bulunamadi: $VELOCITY_JAR"
    exit 1
fi

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/classes"

cd "$SCRIPT_DIR"

echo "[kGuard] Compiling..."
javac -encoding UTF-8 -cp "../velocity.jar" -d "build/classes" \
    src/main/java/com/keydal/kguard/LicenseClient.java \
    src/main/java/com/keydal/kguard/KGuardPlugin.java

echo "[kGuard] Packaging..."
rm -f "$OUT_JAR"
(cd "build/classes" && jar cf "$OUT_JAR" .)

echo "[kGuard] Build OK -> $OUT_JAR"
ls -lh "$OUT_JAR"
