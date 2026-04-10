# Changelog

All notable changes to **kVelocity** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-04-09

### Added
- Initial public release of **kVelocity** by KEYDAL Projects
- KEYDAL-branded MiniMOTD with blue-purple gradient (2-rotation MOTD)
- All plugins and `velocity.jar` bundled inside the repository — zero-network install
- Optional auto-update for `velocity.jar` via PaperMC API and plugins via Modrinth API
- Interactive setup wizard (`setup.sh` / `setup.bat`) with input validation
- Pre-bundled plugin list:
  - **LuckPerms** — permission management
  - **SkinsRestorer** — skin support for cracked mode
  - **ViaVersion** + **ViaBackwards** — 1.16.5 through 1.21.x client support
  - **MiniMOTD** — server list icon + branded MOTD
  - **SignedVelocity** — 1.19+ chat signature bypass for cracked mode (CRITICAL)
  - **spark** — profiling and performance analysis
- 33-language Velocity translation pack (`lang/`)
- Aikar's JVM flags with dynamic `G1HeapRegionSize` based on allocated RAM
- RAM allocation override via `KVELOCITY_RAM` environment variable
- Java version pre-flight check (requires 17+)
- Clean shutdown trap (SIGINT/SIGTERM) — no orphaned Java processes
- Auto-generation of `forwarding.secret` on first run
- Modern player info forwarding with 64-byte secret
- GitHub release workflow (auto-builds ZIP on `v*` tags)
- Issue and feature request templates
- Comprehensive README with architecture diagram and troubleshooting

### Security
- `forwarding.secret` excluded from git via `.gitignore`
- `prevent-client-proxy-connections = true` — blocks Mojang/VPN proxy abuse
- `force-key-authentication = false` — required for cracked mode
- Compression level tuned for bandwidth/CPU balance

### Performance
- `enable-reuse-port = true` — better Linux multi-core scaling
- `tcp-fast-open = true` on supported platforms
- Login rate limiting for bot protection

---

[1.0.0]: https://github.com/KEYDALTR/kVelocity/releases/tag/v1.0.0
