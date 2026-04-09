<p align="center">
  <a href="README.md">Türkçe</a> · <b>English</b>
</p>

<h1 align="center">kVelocity</h1>

<p align="center">
  <i>Pre-configured, performance-focused Velocity proxy package.</i><br>
  <b>KEYDAL Projects</b> — built by Egemen KEYDAL.<br>
  Completely free and open source.
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://adoptium.net/"><img src="https://img.shields.io/badge/Java-17%2B-orange.svg" alt="Java 17+"></a>
  <a href="https://papermc.io/software/velocity"><img src="https://img.shields.io/badge/Velocity-3.4%2B-purple.svg" alt="Velocity 3.4+"></a>
  <a href="https://www.minecraft.net/"><img src="https://img.shields.io/badge/Minecraft-1.16.5--1.21.x-green.svg" alt="Minecraft 1.16.5-1.21.x"></a>
  <a href="https://github.com/KEYDALTR/kVelocity/releases"><img src="https://img.shields.io/github/v/release/KEYDALTR/kVelocity?color=brightgreen" alt="GitHub release"></a>
  <a href="https://github.com/KEYDALTR/kVelocity/stargazers"><img src="https://img.shields.io/github/stars/KEYDALTR/kVelocity?style=social" alt="Stars"></a>
</p>

---

## Overview

**kVelocity** is a production-ready **Velocity proxy** package with one-command setup. It ships with all plugins pre-bundled, cracked mode support, ViaVersion multi-version compatibility, an interactive setup wizard, and optimized Aikar JVM flags — **clone, run, done.**

### Key Features

| | |
|---|---|
| **Batteries included** | All plugins bundled inside the repo, no internet required, works instantly |
| **One-command setup** | `./setup.sh` — prompts for port, RAM, backend addresses, and handles everything |
| **Cracked-ready** | SignedVelocity fixes the 1.19+ chat signature issue for offline-mode servers |
| **Multi-version** | ViaVersion + ViaBackwards supports 1.16.5 → 1.21.x clients |
| **33 languages** | All official Velocity translations included |
| **Aikar's Flags** | G1 heap region size dynamically scales with allocated RAM |
| **Clean shutdown** | Ctrl+C cleanly stops the Java process — no orphaned processes |
| **Input validation** | Setup wizard validates ports, RAM, and address formats |
| **Env var override** | `KVELOCITY_RAM=1024 ./baslat.sh` for runtime RAM override |
| **Auto update** | `setup.sh` can fetch latest versions from Modrinth/PaperMC APIs |

---

## Network Architecture

```
                      +----------------+
                      |     Players   |
                      |  (1.16.5 - 1.21.x)
                      +--------+-------+
                               |
                               v
                  +----------------------+
                  |   kVelocity Proxy    |
                  |       :25565         |
                  +----------+-----------+
                             |
              +--------------+---------------+
              |                              |
              v                              v
    +-------------------+          +-------------------+
    |   lobby :25566    |   ...    |  server :25567    |
    |  (Paper/Folia)    |          |  (Paper/Folia)    |
    +-------------------+          +-------------------+
```

Players land on `lobi` (lobby) by default. If `lobi` goes down, they automatically fall back to `sunucu` (server) — fallback order is defined in `velocity.toml > try`.

---

## Quick Start

### Prerequisites
- **Java 17+** ([Eclipse Temurin](https://adoptium.net/) recommended)
- **curl** (Linux/macOS) or **PowerShell 5+** (Windows, built-in)

### 1) Clone
```bash
git clone https://github.com/KEYDALTR/kVelocity.git
cd kVelocity
```

### 2) Setup Wizard (configuration)
```bash
# Linux / macOS
chmod +x setup.sh baslat.sh
./setup.sh

# Windows
setup.bat
```

The wizard prompts are **in Turkish** but follow this order:
1. Proxy port (default: 25565)
2. Max player count (default: 100)
3. RAM amount in MB (default: 512)
4. Backend addresses (lobby + server)
5. MOTD branding
6. Optional plugins (SkinsRestorer, spark, Velocitab)

### 3) Start
```bash
# Linux / macOS
./baslat.sh

# Windows
baslat.bat
```

**First run:** `velocity.jar` and all plugins are already bundled. Setup only configures — no downloads needed. You can force-update to latest versions by deleting the jars and running `./setup.sh` again.

---

## Package Contents

### File Structure
```
kVelocity/
├── velocity.jar            # Velocity proxy JAR (bundled)
├── velocity.toml           # Proxy config (KEYDAL branded)
├── baslat.sh / baslat.bat  # Starter (Java check + JVM flags)
├── setup.sh  / setup.bat   # Interactive setup wizard
├── forwarding.secret       # Auto-generated on first run (gitignored)
├── lang/                   # 33 language translations
├── plugins/
│   ├── LuckPerms-Velocity-*.jar
│   ├── SkinsRestorer.jar
│   ├── ViaVersion-*.jar
│   ├── ViaBackwards-*.jar
│   ├── minimotd-velocity-*.jar
│   └── minimotd-velocity/  # Config directory
└── docs/
    └── backend-setup.md    # Backend Paper server setup guide
```

> **Note:** Filenames above use `baslat` (Turkish for "start") — the project was built for the Turkish Minecraft community. All code comments are in Turkish, but the project works universally.

### Bundled Plugins

| Plugin | Role | Source |
|---|---|---|
| **LuckPerms** | Permission management (`/lp editor`) | [luckperms.net](https://luckperms.net) |
| **ViaVersion** | Newer clients → older backend | [viaversion.com](https://viaversion.com) |
| **ViaBackwards** | Older clients → newer backend | [viaversion.com](https://viaversion.com) |
| **MiniMOTD** | KEYDAL branded MOTD + logo | [Modrinth](https://modrinth.com/plugin/minimotd) |
| **SkinsRestorer** | Skin support for cracked mode | [Modrinth](https://modrinth.com/plugin/skinsrestorer) |

**Optional plugins offered by the setup wizard (downloaded from Modrinth):**
- **SignedVelocity** — Fixes 1.19+ chat for cracked mode (CRITICAL)
- **spark** — Profiling (`/sparkv profiler`)
- **Velocitab** — Cross-server tablist

---

## Configuration

### Changing RAM
Override at runtime without re-running setup:
```bash
KVELOCITY_RAM=1024 ./baslat.sh
```

Or persistently via `./setup.sh`.

### Adding a backend server
In `velocity.toml`, under `[servers]`:
```toml
[servers]
lobi = "127.0.0.1:25566"
sunucu = "127.0.0.1:25567"
skyblock = "127.0.0.1:25568"  # new

try = ["lobi", "sunucu"]  # fallback order
```

### Domain-based routing (forced host)
```toml
[forced-hosts]
"play.keydal.net" = ["lobi"]
"pvp.keydal.net"  = ["sunucu"]
```

### Backend Paper setup
Detailed guide: [`docs/backend-setup.md`](docs/backend-setup.md)

Briefly, on each backend Paper server, edit `config/paper-global.yml`:
```yaml
proxies:
  velocity:
    enabled: true
    online-mode: true
    secret: 'contents of forwarding.secret'
```

And `server.properties`:
```
online-mode=false
```

---

## Security

- **`forwarding.secret`** is never committed — excluded via `.gitignore`
- **`prevent-client-proxy-connections = true`** — blocks VPN/Mojang proxy abuse
- **Close backend ports at the firewall**, allow only the proxy IP:
  ```bash
  sudo ufw deny 25566
  sudo ufw allow from <PROXY_IP> to any port 25566
  ```
- In cracked mode, install **AuthMe** or a similar auth plugin on backends
- For bot protection, consider **TCPShield** or **HAProxy** in front

---

## Performance

| RAM | Recommendation |
|---|---|
| **512 MB** | Up to 100 players — default |
| **1 GB** | 200-300 players |
| **2 GB** | 500+ players |
| **4 GB+** | 1000+ players, G1HRS automatically increases to 8M |

Aikar's Flags are optimized for G1GC. `G1HeapRegionSize` is auto-selected based on allocated RAM (4M/8M/16M).

---

## Troubleshooting

<details>
<summary><b>"Unable to verify player details" error</b></summary>

`forwarding.secret` contents must match across proxy and backends. Ensure no whitespace was added during copy. The backend must have `velocity.enabled: true`.
</details>

<details>
<summary><b>Players can't connect</b></summary>

- Are the `velocity.toml > [servers]` IPs correct?
- Are backend servers running? `telnet 127.0.0.1 25566`
- Does the firewall allow port 25565?
</details>

<details>
<summary><b>1.19+ cracked players get kicked when chatting</b></summary>

Is **SignedVelocity** installed? The setup wizard offers it as an optional extra. Check manually:
```bash
ls plugins/ | grep -i signed
```
If missing, re-run `./setup.sh` and accept the "extras" option.
</details>

<details>
<summary><b>I have Java 17 but it still errors</b></summary>

Check `java -version`. You may have multiple Java installations:
```bash
KVELOCITY_JAVA=/usr/lib/jvm/temurin-21-jdk/bin/java ./baslat.sh
```
</details>

---

## Development & Contributing

kVelocity is a **KEYDAL Projects** product. Pull requests, issues, and suggestions are welcome.

- **Open an issue:** [Issues](https://github.com/KEYDALTR/kVelocity/issues)
- **Contribution guide:** [`CONTRIBUTING.md`](CONTRIBUTING.md)
- **Changelog:** [`CHANGELOG.md`](CHANGELOG.md)

---

## License

This project is licensed under the **MIT License** — see the [`LICENSE`](LICENSE) file for details.

---

## KEYDAL Projects

**kVelocity** is brought to you by [KEYDAL Projects](https://keydal.net), under the signature of **Egemen KEYDAL**. Official websites: [keydal.net](https://keydal.net) · [keydal.tr](https://keydal.tr)

Made with care in Türkiye.
