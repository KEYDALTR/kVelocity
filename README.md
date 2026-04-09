<p align="center">
  <b>Türkçe</b> · <a href="README.en.md">English</a>
</p>

<h1 align="center">kVelocity</h1>

<p align="center">
  <i>Hazır yapılandırılmış, performans odaklı Velocity proxy paketi.</i><br>
  <b>KEYDAL Projects</b> — Egemen KEYDAL tarafından geliştirilmiştir.<br>
  Tamamen ücretsiz ve açık kaynak.
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

## Genel Bakış

**kVelocity**, Türkçe Minecraft topluluğu için özel olarak hazırlanmış, kurulumu tek komutla yapılan, production-ready bir **Velocity proxy** paketidir. Cracked mod desteği, ViaVersion multi-version, interaktif setup wizard, tüm pluginler paket içinde ve optimize edilmiş Aikar JVM flag'leri ile gelir — **klonla, çalıştır, hazır.**

### Öne Çıkan Özellikler

| | |
|---|---|
| **Her şey dahil** | Tüm pluginler paket içinde, internet gereksiz, anında çalışır |
| **Tek komut kurulum** | `./setup.sh` — port, RAM, backend adresleri sorulur, tüm yapılandırma otomatik |
| **Cracked hazır** | SignedVelocity ile 1.19+ chat signature sorunu çözülmüş |
| **Multi-version** | ViaVersion + ViaBackwards ile 1.16.5 → 1.21.x desteği |
| **33 dil desteği** | Velocity'nin tüm resmi çevirileri paket içinde |
| **Aikar's Flags** | G1 heap region size RAM'e göre dinamik ayarlanır |
| **Clean shutdown** | Ctrl+C'de Java process düzgün kapatılır, orphan process olmaz |
| **Input validation** | Setup wizard girdileri doğrular (port, RAM, address format) |
| **Env var override** | `KVELOCITY_RAM=1024 ./baslat.sh` ile runtime RAM override |
| **Auto update** | `setup.sh` Modrinth/PaperMC API'den son sürüm plugin/jar çeker |

---

## Sunucu Mimarisi

```
                      +----------------+
                      |   Oyuncular    |
                      |  (1.16.5 - 1.21.x)
                      +--------+-------+
                               |
                               v
                  +----------------------+
                  |   kVelocity Proxy    |
                  |      :25565          |
                  +----------+-----------+
                             |
              +--------------+---------------+
              |                              |
              v                              v
    +-------------------+          +-------------------+
    |   lobi  :25566    |   ...    |  sunucu :25567    |
    |  (Paper/Folia)    |          |  (Paper/Folia)    |
    +-------------------+          +-------------------+
```

Oyuncu ilk girişte `lobi`'ye düşer. `lobi` çökerse `sunucu`'ya otomatik fallback yapılır (`velocity.toml > try` sırası).

---

## Hızlı Kurulum

### Ön koşullar
- **Java 17+** ([Eclipse Temurin](https://adoptium.net/) önerilir)
- **curl** (Linux/macOS) veya **PowerShell 5+** (Windows, yerleşik)

### 1) Klonla
```bash
git clone https://github.com/KEYDALTR/kVelocity.git
cd kVelocity
```

### 2) Setup Wizard (yapılandırma)
```bash
# Linux / macOS
chmod +x setup.sh baslat.sh
./setup.sh

# Windows
setup.bat
```

Wizard seni şunlar için yönlendirir:
1. Proxy port (default: 25565)
2. Max oyuncu sayısı (default: 100)
3. RAM miktarı MB (default: 512)
4. Backend adresleri (lobi + sunucu)
5. MOTD markası
6. Opsiyonel ek plugin'ler (SkinsRestorer, spark, Velocitab)

### 3) Başlat
```bash
# Linux / macOS
./baslat.sh

# Windows
baslat.bat
```

**İlk çalıştırma:** `velocity.jar` ve tüm plugin'ler paket içinde mevcut. Setup sadece yapılandırma yapar, indirme yapmaz. İsterseniz en güncel sürümler için setup içindeki update fonksiyonunu kullanabilirsiniz.

---

## Paket İçeriği

### Dosya Yapısı
```
kVelocity/
├── velocity.jar            # Velocity proxy JAR (paket içinde)
├── velocity.toml           # Proxy ayarları (KEYDAL başlıklı)
├── baslat.sh / baslat.bat  # Başlatıcı (Java check + JVM flags)
├── setup.sh  / setup.bat   # Interaktif kurulum wizard
├── forwarding.secret       # İlk çalıştırmada oluşturulur (gitignore)
├── lang/                   # 33 dil çevirisi
├── plugins/
│   ├── LuckPerms-Velocity-*.jar
│   ├── SkinsRestorer.jar
│   ├── ViaVersion-*.jar
│   ├── ViaBackwards-*.jar
│   ├── minimotd-velocity-*.jar
│   └── minimotd-velocity/  # Config klasörü
└── docs/
    └── backend-setup.md    # Backend Paper sunucu yapılandırması
```

### Paket Pluginleri

| Plugin | Rol | Kaynak |
|---|---|---|
| **LuckPerms** | Yetki yönetimi (`/lp editor`) | [luckperms.net](https://luckperms.net) |
| **ViaVersion** | Yeni istemci → eski backend | [viaversion.com](https://viaversion.com) |
| **ViaBackwards** | Eski istemci → yeni backend | [viaversion.com](https://viaversion.com) |
| **MiniMOTD** | KEYDAL markalı MOTD + logo | [Modrinth](https://modrinth.com/plugin/minimotd) |
| **SkinsRestorer** | Cracked modda skin desteği | [Modrinth](https://modrinth.com/plugin/skinsrestorer) |

**Setup wizard'dan eklenen opsiyonel plugin'ler (Modrinth üzerinden):**
- **SignedVelocity** — Cracked modda 1.19+ chat fix (KRİTİK)
- **spark** — Profiling (`/sparkv profiler`)
- **Velocitab** — Cross-server tablist

---

## Yapılandırma

### RAM değiştirme
Setup wizard bir kez ayarladıktan sonra hot-override:
```bash
KVELOCITY_RAM=1024 ./baslat.sh
```

Veya kalıcı olarak tekrar `./setup.sh` çalıştırabilirsin.

### Backend sunucu ekleme
`velocity.toml` içinde `[servers]` bölümüne ekle:
```toml
[servers]
lobi = "127.0.0.1:25566"
sunucu = "127.0.0.1:25567"
skyblock = "127.0.0.1:25568"  # yeni

try = ["lobi", "sunucu"]  # fallback sırası
```

### Domain bazlı yönlendirme (forced host)
```toml
[forced-hosts]
"play.keydal.net" = ["lobi"]
"pvp.keydal.net"  = ["sunucu"]
```

### Backend Paper sunucu ayarı
Detaylı rehber: [`docs/backend-setup.md`](docs/backend-setup.md)

Kısaca, her backend Paper sunucusunda `config/paper-global.yml`:
```yaml
proxies:
  velocity:
    enabled: true
    online-mode: true
    secret: 'forwarding.secret içeriği'
```

Ve `server.properties`:
```
online-mode=false
```

---

## Güvenlik

- **`forwarding.secret`** asla paylaşılmaz, commit edilmez — `.gitignore` tarafından hariç tutulur
- **`prevent-client-proxy-connections = true`** — VPN/Mojang proxy abuse engellenir
- **Backend portlarını firewall'da kapalı tut**, sadece proxy IP'sine aç:
  ```bash
  sudo ufw deny 25566
  sudo ufw allow from <PROXY_IP> to any port 25566
  ```
- Cracked mod kullanıyorsan backend'lerde **AuthMe** veya benzer auth plugin'i zorunlu
- Bot koruması için **TCPShield** veya **HAProxy** önünde çalıştırmayı düşün

---

## Performans

| RAM | Öneri |
|---|---|
| **512 MB** | 100 oyuncuya kadar — varsayılan |
| **1 GB** | 200-300 oyuncu |
| **2 GB** | 500+ oyuncu |
| **4 GB+** | 1000+ oyuncu, G1HRS otomatik 8M'ye çıkar |

Aikar's Flags G1GC için optimize edilmiştir. `G1HeapRegionSize` RAM'e göre dinamik seçilir (4M/8M/16M).

---

## Sorun Giderme

<details>
<summary><b>"Unable to verify player details" hatası</b></summary>

`forwarding.secret` içeriği backend'lerde aynı olmalı. Kopyalandığından ve whitespace eklenmediğinden emin ol. Backend'te `velocity.enabled: true` olmalı.
</details>

<details>
<summary><b>Oyuncular bağlanamıyor</b></summary>

- `velocity.toml > [servers]` IP'leri doğru mu?
- Backend sunucular açık mı? `telnet 127.0.0.1 25566`
- Firewall 25565 portuna izin veriyor mu?
</details>

<details>
<summary><b>1.19+ cracked oyuncular chat yazınca atılıyor</b></summary>

**SignedVelocity** yüklü mü? Setup wizard bunu opsiyonel olarak sunar. Manuel kontrol:
```bash
ls plugins/ | grep -i signed
```
Yoksa tekrar `./setup.sh` çalıştırıp "ekstralar" seçeneğini kabul et.
</details>

<details>
<summary><b>Java 17 var ama hata veriyor</b></summary>

`java -version` çıktısını kontrol et. Birden fazla Java kurulu olabilir:
```bash
KVELOCITY_JAVA=/usr/lib/jvm/temurin-21-jdk/bin/java ./baslat.sh
```
</details>

---

## Geliştirme & Katkı

kVelocity bir **KEYDAL Projects** ürünüdür. Pull request'ler, issue'lar ve öneriler açıktır.

- **Issue aç:** [Issues](https://github.com/KEYDALTR/kVelocity/issues)
- **Katkı rehberi:** [`CONTRIBUTING.md`](CONTRIBUTING.md)
- **Değişiklik geçmişi:** [`CHANGELOG.md`](CHANGELOG.md)

---

## Lisans

Bu proje **MIT License** altında lisanslanmıştır — detay için [`LICENSE`](LICENSE) dosyasına bak.

---

## KEYDAL Projects

**kVelocity**, [KEYDAL Projects](https://keydal.net) tarafından **Egemen KEYDAL** imzasıyla sunulmaktadır. Resmi sitelerimiz: [keydal.net](https://keydal.net) · [keydal.tr](https://keydal.tr)

Made with care in Türkiye.
