@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions EnableDelayedExpansion
title kVelocity - Kurulum Sihirbazi


cls
echo.
echo  ==============================================
echo    kVelocity - Kurulum Sihirbazi
echo    KEYDAL Projects ^| Egemen KEYDAL
echo  ==============================================
echo.
echo  Bu sihirbaz Velocity proxy'nizi yapilandirir,
echo  gerekli tum pluginleri indirir ve baslatmaya hazir hale getirir.
echo  Varsayilan degeri kabul etmek icin Enter'a basin.
echo.

:ask_port
set "PORT=25565"
set /p "PORT=[1/6] Proxy portu [25565]: "
echo %PORT%| findstr /r "^[0-9][0-9]*$" >nul || (echo [HATA] Gecersiz port. & goto ask_port)

:ask_max
set "MAXPLAYERS=100"
set /p "MAXPLAYERS=[2/6] Maksimum oyuncu sayisi [100]: "
echo %MAXPLAYERS%| findstr /r "^[0-9][0-9]*$" >nul || (echo [HATA] Gecersiz sayi. & goto ask_max)

:ask_ram
set "RAM=512"
set /p "RAM=[3/6] RAM miktari MB [512]: "
echo %RAM%| findstr /r "^[0-9][0-9]*$" >nul || (echo [HATA] Gecersiz RAM. & goto ask_ram)

echo.
echo  Backend sunucu adresleri (format: host:port)
set "LOBBY=127.0.0.1:25566"
set /p "LOBBY=[4/6] Lobi adresi [127.0.0.1:25566]: "

set "SERVER=127.0.0.1:25567"
set /p "SERVER=      Sunucu adresi [127.0.0.1:25567]: "

set "MOTD=KEYDAL"
set /p "MOTD=[5/7] MOTD markasi [KEYDAL]: "

echo.
echo  kVelocity lisans anahtari ^(https://keydal.net^):
set "LICENSE_KEY=YOUR-LICENSE-KEY-HERE"
set /p "LICENSE_KEY=[6/7] License key: "

echo.
echo  Opsiyonel ozellikler:
set "INSTALL_EXTRAS=E"

echo.
echo  --- Ayarlariniz ---
echo    Port:        %PORT%
echo    Max Oyuncu:  %MAXPLAYERS%
echo    RAM:         %RAM%MB
echo    Lobi:        %LOBBY%
echo    Sunucu:      %SERVER%
echo    MOTD:        %MOTD%
echo    License:     %LICENSE_KEY:~0,20%...
echo    Ekstralar:   %INSTALL_EXTRAS%
echo.
set "CONFIRM=E"
set /p "CONFIRM=Devam edilsin mi? [E/h]: "
if /i not "%CONFIRM%"=="E" (
    echo [UYARI] Kurulum iptal edildi.
    pause
    exit /b 0
)

echo.
echo [kVelocity] [1/5] velocity.jar indiriliyor...
if exist "velocity.jar" (
    echo [OK] velocity.jar zaten mevcut, atlaniyor.
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$ErrorActionPreference='Stop'; " ^
        "$ua = 'kVelocity/1.0'; " ^
        "try { " ^
        "  $proj = Invoke-RestMethod -UserAgent $ua -Uri 'https://api.papermc.io/v2/projects/velocity'; " ^
        "  $ver = $proj.versions[-1]; " ^
        "  $builds = Invoke-RestMethod -UserAgent $ua -Uri ('https://api.papermc.io/v2/projects/velocity/versions/' + $ver + '/builds'); " ^
        "  $build = $builds.builds[-1]; " ^
        "  Write-Host ('[kVelocity]   Surum: ' + $ver + ' Build: ' + $build.build); " ^
        "  $url = 'https://api.papermc.io/v2/projects/velocity/versions/' + $ver + '/builds/' + $build.build + '/downloads/' + $build.downloads.application.name; " ^
        "  Invoke-WebRequest -UserAgent $ua -Uri $url -OutFile 'velocity.jar.tmp'; " ^
        "  Move-Item -Force 'velocity.jar.tmp' 'velocity.jar'; " ^
        "  Write-Host ('[OK] velocity.jar indirildi (' + $build.downloads.application.name + ')'); " ^
        "} catch { " ^
        "  Write-Host ('[HATA] ' + $_.Exception.Message); " ^
        "  if (Test-Path 'velocity.jar.tmp') { Remove-Item -Force 'velocity.jar.tmp' }; " ^
        "  exit 1; " ^
        "}"
    if errorlevel 1 ( pause & exit /b 1 )
)

echo.
echo [kVelocity] [2/5] Pluginler Modrinth'ten indiriliyor...
if not exist "plugins" mkdir plugins

set "CORE_PLUGINS=luckperms viaversion viabackwards minimotd signedvelocity"

for %%P in (%CORE_PLUGINS%) do call :download_plugin %%P
if /i "%INSTALL_EXTRAS%"=="E" (
    for %%P in (%EXTRA_PLUGINS%) do call :download_plugin %%P
)

echo.
echo [kVelocity] [3/5] forwarding.secret kontrol ediliyor...
if exist "forwarding.secret" (
    echo [OK] forwarding.secret zaten mevcut.
) else (
    powershell -NoProfile -Command ^
        "$bytes = New-Object byte[] 32; " ^
        "([Security.Cryptography.RandomNumberGenerator]::Create()).GetBytes($bytes); " ^
        "[IO.File]::WriteAllText('forwarding.secret', ($bytes | ForEach-Object ToString x2) -join '')"
    echo [OK] forwarding.secret olusturuldu ^(64 karakter^).
    echo [UYARI] Bu token'i backend sunucularinizin paper-global.yml dosyasina kopyalayin!
)

echo.
echo [kVelocity] [4/5] velocity.toml guncelleniyor...
if exist "velocity.toml" (
    powershell -NoProfile -Command ^
        "$c = Get-Content 'velocity.toml' -Raw -Encoding UTF8; " ^
        "$c = $c -replace 'bind = \"0\.0\.0\.0:\d+\"', 'bind = \"0.0.0.0:%PORT%\"'; " ^
        "$c = $c -replace 'show-max-players = \d+', 'show-max-players = %MAXPLAYERS%'; " ^
        "$c = $c -replace 'motd = \".*?\"', 'motd = \"<gray>[<gradient:#3b82f6:#8b5cf6>%MOTD%</gradient><gray>] <white>Welcome\"'; " ^
        "$c = $c -replace 'lobi = \".*?\"', 'lobi = \"%LOBBY%\"'; " ^
        "$c = $c -replace 'sunucu = \".*?\"', 'sunucu = \"%SERVER%\"'; " ^
        "[IO.File]::WriteAllText('velocity.toml', $c, (New-Object System.Text.UTF8Encoding $false))"
    echo [OK] velocity.toml guncellendi.
) else (
    echo [HATA] velocity.toml bulunamadi!
    pause
    exit /b 1
)

echo.
echo [kVelocity] [5/6] Baslat scriptleri guncelleniyor...
if exist "baslat.bat" (
    powershell -NoProfile -Command ^
        "$c = Get-Content 'baslat.bat' -Raw; " ^
        "$c = $c -replace 'KVELOCITY_RAM=\d+', 'KVELOCITY_RAM=%RAM%'; " ^
        "[IO.File]::WriteAllText('baslat.bat', $c, (New-Object System.Text.UTF8Encoding $false))"
    echo [OK] baslat.bat RAM -^> %RAM%MB
)
if exist "baslat.sh" (
    powershell -NoProfile -Command ^
        "$c = Get-Content 'baslat.sh' -Raw; " ^
        "$c = $c -replace 'KVELOCITY_RAM:-\d+', 'KVELOCITY_RAM:-%RAM%'; " ^
        "[IO.File]::WriteAllText('baslat.sh', $c -replace \"`r`n\", \"`n\")"
    echo [OK] baslat.sh RAM -^> %RAM%MB
)

echo.
echo [kVelocity] [6/6] kGuard lisans yapilandiriliyor...
if not exist "plugins\kguard" mkdir "plugins\kguard"
powershell -NoProfile -Command ^
    "Set-Content -Path 'plugins\kguard\config.yml' -Value 'license-key: \"%LICENSE_KEY%\"' -Encoding UTF8"
echo [OK] plugins\kguard\config.yml olusturuldu.

echo.
echo  ==============================================
echo    Kurulum basariyla tamamlandi!
echo  ==============================================
echo.
echo   Baslatmak icin: baslat.bat
echo   veya Linux:     ./baslat.sh
echo.
echo  ONEMLI:
echo   1) forwarding.secret icerigini backend sunuculariniza kopyalayin
echo      ^(config/paper-global.yml ^> proxies.velocity.secret^)
echo   2) Backend sunucularda velocity-support'u acin
echo      ^(config/paper-global.yml ^> proxies.velocity.enabled: true^)
echo   3) Dokuman: docs\backend-setup.md
echo.
pause
exit /b 0

:download_plugin
set "SLUG=%~1"

dir /b "plugins\%SLUG%*.jar" >nul 2>&1
if not errorlevel 1 (
    echo [OK]   %SLUG% zaten mevcut, atlaniyor.
    exit /b 0
)

powershell -NoProfile -Command ^
    "$ErrorActionPreference='Stop'; " ^
    "$ua = 'kVelocity/1.0'; " ^
    "try { " ^
    "  $v = Invoke-RestMethod -UserAgent $ua -Uri 'https://api.modrinth.com/v2/project/%SLUG%/version?loaders=%%5B%%22velocity%%22%%5D'; " ^
    "  if ($v.Count -eq 0) { throw 'Velocity surumu bulunamadi.' }; " ^
    "  $file = $v[0].files[0]; " ^
    "  Invoke-WebRequest -UserAgent $ua -Uri $file.url -OutFile ('plugins\\' + $file.filename + '.tmp'); " ^
    "  Move-Item -Force ('plugins\\' + $file.filename + '.tmp') ('plugins\\' + $file.filename); " ^
    "  Write-Host ('[OK]   %SLUG% -> ' + $file.filename); " ^
    "} catch { " ^
    "  Write-Host ('[UYARI] %SLUG% atlandi: ' + $_.Exception.Message); " ^
    "  Get-ChildItem 'plugins\*.tmp' -ErrorAction SilentlyContinue | Remove-Item -Force; " ^
    "}"

exit /b 0
