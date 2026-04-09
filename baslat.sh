#!/bin/bash

set -euo pipefail

JAR="velocity.jar"
RAM="${KVELOCITY_RAM:-512}"
JAVA_BIN="${KVELOCITY_JAVA:-java}"
PROJECT="velocity"
API_BASE="https://api.papermc.io/v2/projects"
USER_AGENT="kVelocity/1.0 (+https://github.com/KEYDALTR/kVelocity)"

R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; C='\033[0;36m'; W='\033[1;37m'; N='\033[0m'

log()  { echo -e "${C}[kVelocity]${N} $*"; }
ok()   { echo -e "${G}[kVelocity]${N} $*"; }
warn() { echo -e "${Y}[kVelocity]${N} $*"; }
err()  { echo -e "${R}[HATA]${N} $*" >&2; }

echo ""
echo -e "${C}  _  __ __     __   _            _ _${N}"
echo -e "${C} | |/ / \ \   / /__| | ___   ___(_) |_ _   _${N}"
echo -e "${C} | ' /   \ \ / / _ \ |/ _ \ / __| | __| | | |${N}"
echo -e "${C} | . \    \ V /  __/ | (_) | (__| | |_| |_| |${N}"
echo -e "${C} |_|\_\    \_/ \___|_|\___/ \___|_|\__|\__, |${N}"
echo -e "${C}                                       |___/${N}"
echo -e "${W} KEYDAL Projects  |  Developer: Egemen KEYDAL${N}"
echo ""

if ! command -v "$JAVA_BIN" >/dev/null 2>&1; then
    err "Java bulunamadi! Java 17+ kurulu olmali."
    err "Indir: https://adoptium.net/"
    exit 1
fi

JAVA_RAW=$("$JAVA_BIN" -version 2>&1 | head -n1)
JAVA_VER=$(echo "$JAVA_RAW" | awk -F '"' '/version/ {print $2}' | awk -F. '{print $1}')

if [ -z "$JAVA_VER" ] || [ "$JAVA_VER" -lt 17 ] 2>/dev/null; then
    err "Java 17+ gerekli, mevcut: $JAVA_RAW"
    err "Indir: https://adoptium.net/"
    exit 1
fi
ok "Java $JAVA_VER tespit edildi."

if [ ! -f "$JAR" ]; then
    log "$JAR bulunamadi, PaperMC API'den en son surum indiriliyor..."

    VERSION=$(curl -sfA "$USER_AGENT" "$API_BASE/$PROJECT" \
        | grep -oE '"[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9._-]*)?"' \
        | tail -1 | tr -d '"')

    if [ -z "$VERSION" ]; then
        err "Surum bilgisi alinamadi! Internet baglantinizi kontrol edin."
        exit 1
    fi
    log "Surum: $VERSION"

    BUILD=$(curl -sfA "$USER_AGENT" "$API_BASE/$PROJECT/versions/$VERSION/builds" \
        | grep -oE '"build":[0-9]+' | tail -1 | grep -oE '[0-9]+')

    if [ -z "$BUILD" ]; then
        err "Build bilgisi alinamadi!"
        exit 1
    fi
    log "Build: $BUILD"

    FILENAME="$PROJECT-$VERSION-$BUILD.jar"
    DL_URL="$API_BASE/$PROJECT/versions/$VERSION/builds/$BUILD/downloads/$FILENAME"

    if ! curl -fL --progress-bar -A "$USER_AGENT" -o "$JAR.tmp" "$DL_URL"; then
        err "Indirme basarisiz!"
        rm -f "$JAR.tmp"
        exit 1
    fi
    mv "$JAR.tmp" "$JAR"
    ok "$JAR basariyla indirildi. ($FILENAME)"
fi

if [ "$RAM" -ge 10240 ]; then
    G1HRS="16M"
elif [ "$RAM" -ge 4096 ]; then
    G1HRS="8M"
else
    G1HRS="4M"
fi

JAVA_PID=""
cleanup() {
    echo ""
    warn "Kapatma sinyali alindi, Velocity durduruluyor..."
    if [ -n "$JAVA_PID" ] && kill -0 "$JAVA_PID" 2>/dev/null; then
        kill -TERM "$JAVA_PID" 2>/dev/null || true
        wait "$JAVA_PID" 2>/dev/null || true
    fi
    ok "Temiz kapatildi."
    exit 0
}
trap cleanup INT TERM

log "Baslatiliyor | RAM: ${RAM}MB | G1HRS: ${G1HRS} | Java: $JAVA_VER"
echo ""

"$JAVA_BIN" \
    -Xms${RAM}M \
    -Xmx${RAM}M \
    -XX:+UseG1GC \
    -XX:G1HeapRegionSize=$G1HRS \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+ParallelRefProcEnabled \
    -XX:+AlwaysPreTouch \
    -XX:MaxGCPauseMillis=200 \
    -XX:+DisableExplicitGC \
    -XX:InitiatingHeapOccupancyPercent=15 \
    -XX:G1MixedGCCountTarget=4 \
    -XX:G1MixedGCLiveThresholdPercent=90 \
    -XX:G1RSetUpdatingPauseTimePercent=5 \
    -XX:SurvivorRatio=32 \
    -XX:MaxTenuringThreshold=1 \
    -XX:G1NewSizePercent=30 \
    -XX:G1MaxNewSizePercent=40 \
    -XX:G1HeapWastePercent=5 \
    -XX:G1ReservePercent=20 \
    -XX:+PerfDisableSharedMem \
    -Dusing.aikars.flags=https://mcflags.emc.gs \
    -Daikars.new.flags=true \
    -Dvelocity.packet-decode-logging=false \
    -jar "$JAR" &

JAVA_PID=$!
wait "$JAVA_PID"
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    err "Velocity $EXIT_CODE kod ile kapandi. logs/latest.log dosyasini kontrol edin."
fi
exit $EXIT_CODE
