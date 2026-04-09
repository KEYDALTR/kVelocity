# Backend Sunucu Yapılandırması

**kVelocity** proxy'sinin backend olarak bağlanacağı Paper/Folia sunucularının nasıl ayarlanacağı.

---

## Gereksinimler

- Paper / Folia / Purpur 1.16.5 - 1.21.x
- kVelocity proxy çalışır durumda (`forwarding.secret` dosyası oluşmuş olmalı)

---

## 1) server.properties

Her backend sunucuda `server.properties`:

```properties
# Proxy arkasında olduğu için online-mode kapalı
online-mode=false

# Farklı portlarda çalıştır
server-port=25566
# veya 25567, 25568 vb.

# Proxy dışından direkt bağlantıyı engelle
# (IP bind'i sadece localhost'a)
server-ip=127.0.0.1
```

**UYARI:** `online-mode=false` cracked gibi görünür ama proxy Velocity forwarding ile oyuncuyu doğrular. Kimlik doğrulama proxy tarafında yapılır.

---

## 2) config/paper-global.yml

```yaml
proxies:
  bungee-cord:
    online-mode: false
  proxy-protocol: false
  velocity:
    enabled: true
    online-mode: true
    secret: 'BURAYA_forwarding.secret_ICERIGI'
```

**`secret` alanını nasıl dolduracaksınız:**

```bash
# Proxy sunucuda
cat /path/to/kVelocity/forwarding.secret
```

Çıkan değeri (64 karakterli hex string) olduğu gibi `secret:` alanına yapıştırın.

> **Güvenlik:** Bu secret proxy ile backend arasındaki güven temelidir. Asla public repo'ya commit etmeyin, Discord'da paylaşmayın, ekran görüntüsü almayın.

---

## 3) spigot.yml (varsa)

```yaml
settings:
  bungeecord: false  # Velocity kullanıyoruz, BungeeCord değil
```

---

## 4) Firewall

Backend sunucularını sadece proxy IP'sinin erişebileceği şekilde kapatın:

### UFW (Ubuntu/Debian)
```bash
# Default olarak tüm 25566 portunu kapat
sudo ufw deny 25566

# Sadece proxy IP'sine aç
sudo ufw allow from 203.0.113.50 to any port 25566

# Tekrar sonuç
sudo ufw status
```

### iptables
```bash
# 25566'ya sadece proxy IP'sinden izin ver
iptables -A INPUT -p tcp --dport 25566 -s 203.0.113.50 -j ACCEPT
iptables -A INPUT -p tcp --dport 25566 -j DROP
```

### Aynı makinede (proxy + backend)
Backend'i sadece `127.0.0.1`'e bind et:
```properties
# server.properties
server-ip=127.0.0.1
```
Bu sayede dışarıdan direkt bağlantı mümkün olmaz.

---

## 5) Test

### Backend canlı mı?
Proxy sunucudan:
```bash
nc -zv 127.0.0.1 25566
# veya
telnet 127.0.0.1 25566
```

### Forwarding çalışıyor mu?
1. Proxy'ye bağlan (`play.keydal.net` gibi)
2. Backend konsolunda oyuncu adının göründüğünü doğrula
3. `/whitelist on` test et — oyuncu cracked ise whitelist çalışmamalı (proxy kimliği doğruluyor)

---

## Sorun Giderme

### "Unable to verify player details"
- `secret` alanı proxy'deki `forwarding.secret` ile birebir aynı mı?
- Başında/sonunda whitespace var mı? (`cat forwarding.secret | xxd | tail` ile kontrol edin)
- Backend'de `velocity.enabled: true` mı?
- Backend Paper/Folia sürümü Velocity forwarding destekliyor mu? (Paper 1.13+ destekliyor)

### Backend'e direkt bağlanabiliyorum
- `server-ip=127.0.0.1` ayarlı mı?
- Firewall kuralları yerinde mi? (`sudo ufw status` veya `iptables -L`)
- `server.properties > online-mode=false` olmasına rağmen sadece proxy oyuncuları bağlanmalı — firewall ile koruyun

### Skin görünmüyor
- **SkinsRestorer** plugin'i backend'lerde de kurulmalı (proxy'de tek başına yeterli değil)
- Cracked sunucular için: `plugins/SkinsRestorer/config.yml > default-skins` ayarlı mı?

### "Forwarding secret mismatch" konsol spam'i
Velocity restart edince secret değişmiş olabilir. `forwarding.secret` dosyasını tekrar backend'lere kopyalayın ve backend'leri restart edin.

---

## Performans İpuçları

- Backend'ler arası `/server` komutu ile geçiş sırasında chunk sending optimize edilmiş Paper yeterli
- Daha fazla performans için **Folia** kullanabilirsiniz — kVelocity tam uyumlu
- Backend sayısı arttıkça **Redis** tabanlı player sync (PlayerBalancer, RedisBungee) düşünülebilir

---

**KEYDAL Projects** | Egemen KEYDAL | [keydal.net](https://keydal.net)
