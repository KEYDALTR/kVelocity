#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VELOCITY_JAR="$ROOT_DIR/velocity.jar"
OUT_JAR="$ROOT_DIR/plugins/kGuard-1.0.0.jar"
BUILD_DIR="$SCRIPT_DIR/build"
TOOLS_DIR="$SCRIPT_DIR/tools"

if [ ! -f "$VELOCITY_JAR" ]; then
    echo "[HATA] velocity.jar bulunamadi: $VELOCITY_JAR"
    exit 1
fi

if [ ! -d "$TOOLS_DIR" ] || [ -z "$(ls -A "$TOOLS_DIR"/*.jar 2>/dev/null || true)" ]; then
    echo "[HATA] tools/ klasoru bos. ProGuard jar'larini indirin:"
    echo "       mkdir -p tools && cd tools"
    echo "       curl -sfL -o proguard-base.jar https://repo1.maven.org/maven2/com/guardsquare/proguard-base/7.6.1/proguard-base-7.6.1.jar"
    echo "       curl -sfL -o proguard-core.jar https://repo1.maven.org/maven2/com/guardsquare/proguard-core/9.1.10/proguard-core-9.1.10.jar"
    echo "       curl -sfL -o log4j-api.jar https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-api/2.24.3/log4j-api-2.24.3.jar"
    echo "       curl -sfL -o log4j-core.jar https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/2.24.3/log4j-core-2.24.3.jar"
    echo "       curl -sfL -o gson.jar https://repo1.maven.org/maven2/com/google/code/gson/gson/2.11.0/gson-2.11.0.jar"
    exit 1
fi

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/classes"

cd "$SCRIPT_DIR"

echo "[kGuard] Compiling..."
javac -encoding UTF-8 -cp "../velocity.jar" -d "build/classes" \
    src/main/java/com/keydal/kguard/LicenseClient.java \
    src/main/java/com/keydal/kguard/KGuardPlugin.java

echo "[kGuard] Packaging raw jar..."
(cd "build/classes" && jar cf "../kGuard-raw.jar" .)

echo "[kGuard] Running ProGuard (obfuscation + shrink)..."
rm -f "$OUT_JAR"
java -cp "tools/*" proguard.ProGuard @proguard.conf

echo "[kGuard] Build OK -> $OUT_JAR"
ls -lh "$OUT_JAR"
