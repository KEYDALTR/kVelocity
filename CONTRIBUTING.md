# Contributing to kVelocity

**kVelocity** bir KEYDAL Projects ürünüdür. Katkılarınız, bug raporlarınız ve özellik istekleriniz memnuniyetle karşılanır.

## Nasıl Katkıda Bulunabilirim?

### Bug Raporu

1. [Issues](https://github.com/KEYDALTR/kVelocity/issues) sayfasında aynı hatanın raporlanmadığını doğrulayın
2. "Bug report" template'ini kullanarak yeni bir issue açın
3. Şunları ekleyin:
   - Kullandığınız Velocity sürümü (`velocity.jar` adından)
   - Java sürümü (`java -version`)
   - OS ve mimari
   - `logs/latest.log` ilgili kısmı
   - Beklenen davranış ve gerçekleşen davranış

### Özellik İsteği

"Feature request" template'ini kullanın. Özelliğin **kullanım senaryosu** ve **alternatifleri**ni belirtin.

### Pull Request

1. Repo'yu fork edin
2. Özelliğiniz için branch açın: `git checkout -b feature/harika-ozellik`
3. Değişikliklerinizi commit edin:
   - Commit mesajları Türkçe veya İngilizce olabilir
   - `feat:`, `fix:`, `docs:`, `refactor:`, `perf:` prefix'leri kullanın
4. Branch'i push edin: `git push origin feature/harika-ozellik`
5. Pull Request açın, template'i doldurun

## Kod Stili

### Shell Scripts (baslat.sh, setup.sh)
- `set -euo pipefail` kullanın
- Portable olmaya çalışın (bash 4+, GNU/BSD sed farkını `sed_i` helper ile yönetin)
- Renkli log çıktısı için mevcut `log/ok/warn/err` helper'larını kullanın
- Input validation **zorunlu**

### Batch Files (baslat.bat, setup.bat)
- `setlocal EnableExtensions EnableDelayedExpansion` ile başlayın
- PowerShell çağrıları için `-NoProfile -ExecutionPolicy Bypass` ekleyin
- UTF-8 için `chcp 65001 >nul 2>&1`

### Config Dosyaları
- KEYDAL header'ı zorunlu:
  ```yaml
  ######################################################
  #  kVelocity | KEYDAL Projects                       #
  #  Developer: Egemen KEYDAL                          #
  #  https://github.com/KEYDALTR/kVelocity       #
  ######################################################
  ```
- Yorumları **Türkçe** yazın, teknik terimler İngilizce kalabilir
- Her bölümü `# ===` ile ayırın

## Test Etme

Pull request açmadan önce:

```bash
# 1) Fresh clone üzerinde setup test
./setup.sh  # tüm default değerlerle

# 2) Start test
./baslat.sh
# Konsola "Done (Xs)!" mesajı gelmeli

# 3) Shutdown test
# Ctrl+C basın, java process düzgün kapanmalı (orphan olmamalı)
ps aux | grep velocity  # boş çıkmalı

# 4) Windows test
setup.bat
baslat.bat
```

## Lisans

Katkıda bulunarak, değişikliklerinizin MIT lisansı altında dağıtılmasını kabul etmiş olursunuz.

## İletişim

Sorularınız için [GitHub Discussions](https://github.com/KEYDALTR/kVelocity/discussions) veya [keydal.net](https://keydal.net) üzerinden ulaşabilirsiniz.

---
**Egemen KEYDAL** — KEYDAL Projects
