#!/bin/bash

set -euo pipefail

R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; B='\033[0;34m'; C='\033[0;36m'; W='\033[1;37m'; N='\033[0m'

log()  { echo -e "${C}[kVelocity]${N} $*"; }
ok()   { echo -e "${G}[OK]${N} $*"; }
warn() { echo -e "${Y}[UYARI]${N} $*"; }
err()  { echo -e "${R}[HATA]${N} $*" >&2; }

USER_AGENT="kVelocity/1.0 (+https://github.com/KEYDALTR/kVelocity)"
PAPER_API="https://api.papermc.io/v2/projects"
MODRINTH_API="https://api.modrinth.com/v2"

sed_i() {
    if [ "$(uname)" = "Darwin" ]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

clear
echo ""
echo -e "${C}==============================================${N}"
echo -e "${W}  kVelocity - Kurulum Sihirbazi${N}"
echo -e "${C}  KEYDAL Projects | Egemen KEYDAL${N}"
echo -e "${C}==============================================${N}"
echo ""
echo -e "${Y}Bu sihirbaz Velocity proxy'nizi yapilandirir,${N}"
echo -e "${Y}gerekli tum pluginleri indirir ve baslatmaya hazir hale getirir.${N}"
echo -e "${Y}Varsayilan degeri kabul etmek icin Enter'a basin.${N}"
echo ""

validate_port() {
    [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 1 ] && [ "$1" -le 65535 ]
}

validate_num() {
    [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 1 ]
}

validate_address() {
    [[ "$1" =~ ^[a-zA-Z0-9._-]+:[0-9]+$ ]]
}

ask() {
    local prompt="$1"
    local default="$2"
    local validator="${3:-}"
    local input
    while true; do
        read -rp "$(echo -e "${B}${prompt}${N} [${G}${default}${N}]: ")" input
        input="${input:-$default}"
        if [ -z "$validator" ] || $validator "$input"; then
            echo "$input"
            return
        else
            err "Gecersiz deger: $input"
        fi
    done
}

PORT=$(ask "[1/6] Proxy portu" "25565" validate_port)
MAXPLAYERS=$(ask "[2/6] Maksimum oyuncu sayisi" "100" validate_num)
RAM=$(ask "[3/6] RAM miktari (MB)" "512" validate_num)
echo ""
echo -e "${Y}Backend sunucu adresleri (format: host:port)${N}"
LOBBY=$(ask "[4/6] Lobi adresi" "127.0.0.1:25566" validate_address)
SERVER=$(ask "      Sunucu adresi" "127.0.0.1:25567" validate_address)
MOTD=$(ask "[5/7] MOTD markasi" "KEYDAL" "")

echo ""
echo -e "${Y}kVelocity lisans anahtari (https://keydal.net):${N}"
LICENSE_KEY=$(ask "[6/7] License key" "YOUR-LICENSE-KEY-HERE" "")

echo ""
echo -e "${Y}Opsiyonel ozellikler:${N}"
INSTALL_EXTRAS="${INSTALL_EXTRAS:-E}"

echo ""
echo -e "${C}--- Ayarlariniz ---${N}"
echo -e "  Port:        ${W}$PORT${N}"
echo -e "  Max Oyuncu:  ${W}$MAXPLAYERS${N}"
echo -e "  RAM:         ${W}${RAM}MB${N}"
echo -e "  Lobi:        ${W}$LOBBY${N}"
echo -e "  Sunucu:      ${W}$SERVER${N}"
echo -e "  MOTD:        ${W}$MOTD${N}"
echo -e "  License:     ${W}${LICENSE_KEY:0:20}...${N}"
echo -e "  Ekstralar:   ${W}$INSTALL_EXTRAS${N}"
echo ""
read -rp "$(echo -e "${B}Devam edilsin mi?${N} [${G}E${N}/h]: ")" CONFIRM
CONFIRM="${CONFIRM:-E}"
if [[ ! "$CONFIRM" =~ ^[Ee]$ ]]; then
    warn "Kurulum iptal edildi."
    exit 0
fi

echo ""
log "[1/5] velocity.jar indiriliyor..."
if [ -f "velocity.jar" ]; then
    ok "velocity.jar zaten mevcut, atlaniyor."
else
    VERSION=$(curl -sfA "$USER_AGENT" "$PAPER_API/velocity" \
        | grep -oE '"[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9._-]*)?"' | tail -1 | tr -d '"')
    [ -z "$VERSION" ] && { err "Velocity surum bilgisi alinamadi!"; exit 1; }

    BUILD=$(curl -sfA "$USER_AGENT" "$PAPER_API/velocity/versions/$VERSION/builds" \
        | grep -oE '"build":[0-9]+' | tail -1 | grep -oE '[0-9]+')
    [ -z "$BUILD" ] && { err "Velocity build bilgisi alinamadi!"; exit 1; }

    FILENAME="velocity-$VERSION-$BUILD.jar"
    DL_URL="$PAPER_API/velocity/versions/$VERSION/builds/$BUILD/downloads/$FILENAME"

    log "  Surum: $VERSION Build: $BUILD"
    if curl -fL --progress-bar -A "$USER_AGENT" -o "velocity.jar.tmp" "$DL_URL"; then
        mv "velocity.jar.tmp" "velocity.jar"
        ok "velocity.jar indirildi ($FILENAME)"
    else
        err "velocity.jar indirilemedi!"
        rm -f velocity.jar.tmp
        exit 1
    fi
fi

echo ""
log "[2/5] Pluginler Modrinth'ten indiriliyor..."
mkdir -p plugins

CORE_PLUGINS=(
    "luckperms"
    "viaversion"
    "viabackwards"
    "minimotd"
    "signedvelocity"
)

EXTRA_PLUGINS=(
    "skinsrestorer"
    "spark"
)

download_plugin() {
    local slug="$1"
    local existing
    existing=$(find plugins -maxdepth 1 -iname "${slug}*.jar" 2>/dev/null | head -1)

    if [ -n "$existing" ]; then
        ok "  $slug zaten mevcut ($(basename "$existing")), atlaniyor."
        return 0
    fi

    local api_url="$MODRINTH_API/project/$slug/version?loaders=%5B%22velocity%22%5D"
    local json
    json=$(curl -sfA "$USER_AGENT" "$api_url" 2>/dev/null || echo "")

    if [ -z "$json" ] || [ "$json" = "[]" ]; then
        warn "  $slug: Modrinth'te velocity surumu bulunamadi."
        return 1
    fi

    local dl_url
    local filename
    dl_url=$(echo "$json" | grep -oE '"url":"[^"]*\.jar"' | head -1 | sed 's/"url":"\(.*\)"/\1/')
    filename=$(echo "$json" | grep -oE '"filename":"[^"]*\.jar"' | head -1 | sed 's/"filename":"\(.*\)"/\1/')

    if [ -z "$dl_url" ] || [ -z "$filename" ]; then
        warn "  $slug: indirme URL'si ayiklanamadi."
        return 1
    fi

    if curl -fsL -A "$USER_AGENT" -o "plugins/$filename.tmp" "$dl_url"; then
        mv "plugins/$filename.tmp" "plugins/$filename"
        ok "  $slug -> $filename"
    else
        err "  $slug indirme basarisiz."
        rm -f "plugins/$filename.tmp"
        return 1
    fi
}

for p in "${CORE_PLUGINS[@]}"; do
    download_plugin "$p" || warn "$p atlandi."
done

if [[ "$INSTALL_EXTRAS" =~ ^[Ee]$ ]]; then
    for p in "${EXTRA_PLUGINS[@]}"; do
        download_plugin "$p" || warn "$p atlandi."
    done
fi

echo ""
log "[3/5] forwarding.secret kontrol ediliyor..."
if [ -f "forwarding.secret" ]; then
    ok "forwarding.secret zaten mevcut."
else
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -hex 32 > forwarding.secret
    elif [ -r /dev/urandom ]; then
        tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 64 > forwarding.secret
    else
        echo "kVelocity_$(date +%s)_$(head -c 100 /dev/random | od -An -tx1 | tr -d ' \n' | head -c 32)" > forwarding.secret
    fi
    chmod 600 forwarding.secret
    ok "forwarding.secret olusturuldu (64 byte)."
    warn "Bu token'i backend sunucularinizin paper-global.yml dosyasina kopyalayin!"
fi

echo ""
log "[4/5] velocity.toml guncelleniyor..."
if [ -f "velocity.toml" ]; then
    sed_i "s|bind = \"0.0.0.0:[0-9]*\"|bind = \"0.0.0.0:${PORT}\"|g" velocity.toml
    sed_i "s|show-max-players = [0-9]*|show-max-players = ${MAXPLAYERS}|g" velocity.toml
    sed_i "s|motd = \".*\"|motd = \"<gray>[<gradient:#3b82f6:#8b5cf6>${MOTD}</gradient><gray>] <white>Welcome\"|g" velocity.toml
    sed_i "s|lobi = \".*\"|lobi = \"${LOBBY}\"|g" velocity.toml
    sed_i "s|sunucu = \".*\"|sunucu = \"${SERVER}\"|g" velocity.toml
    ok "velocity.toml guncellendi."
else
    err "velocity.toml bulunamadi!"
    exit 1
fi

echo ""
log "[5/6] Baslat scriptleri guncelleniyor..."
if [ -f "baslat.sh" ]; then
    sed_i "s|KVELOCITY_RAM:-[0-9]*|KVELOCITY_RAM:-${RAM}|g" baslat.sh
    ok "baslat.sh RAM -> ${RAM}MB"
fi
if [ -f "baslat.bat" ]; then
    sed_i "s|KVELOCITY_RAM=[0-9]*|KVELOCITY_RAM=${RAM}|g" baslat.bat
    ok "baslat.bat RAM -> ${RAM}MB"
fi

echo ""
log "[6/6] kGuard lisans yapilandiriliyor..."
mkdir -p plugins/kguard
cat > plugins/kguard/config.yml <<EOF
license-key: "${LICENSE_KEY}"
EOF
chmod 600 plugins/kguard/config.yml 2>/dev/null || true
ok "plugins/kguard/config.yml olusturuldu."

echo ""
echo -e "${C}==============================================${N}"
echo -e "${G}  Kurulum basariyla tamamlandi!${N}"
echo -e "${C}==============================================${N}"
echo ""
echo -e "  Baslatmak icin: ${W}./baslat.sh${N}"
echo -e "  veya Windows:   ${W}baslat.bat${N}"
echo ""
echo -e "${Y}ONEMLI:${N}"
echo -e "  ${Y}1)${N} forwarding.secret icerigini backend sunuculariniza kopyalayin"
echo -e "     (config/paper-global.yml > proxies.velocity.secret)"
echo -e "  ${Y}2)${N} Backend sunucularda velocity-support'u acin"
echo -e "     (config/paper-global.yml > proxies.velocity.enabled: true)"
echo -e "  ${Y}3)${N} Dokuman: ${C}docs/backend-setup.md${N}"
echo ""
