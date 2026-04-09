@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions EnableDelayedExpansion
title kVelocity ^| KEYDAL Projects


set "JAR=velocity.jar"
if "%KVELOCITY_RAM%"=="" set "KVELOCITY_RAM=512"
set "RAM=%KVELOCITY_RAM%"
set "PROJECT=velocity"
set "API_BASE=https://api.papermc.io/v2/projects"
set "UA=kVelocity/1.0"

echo.
echo    _  __ __     __   _            _ _
echo   ^| ^|/ / \ \   / /__^| ^| ___   ___^(_^) ^|_ _   _
echo   ^| ' /   \ \ / / _ \ ^|/ _ \ / __^| ^| __^| ^| ^| ^|
echo   ^| . \    \ V /  __/ ^| ^(_^) ^| ^(__^| ^| ^|_^| ^|_^| ^|
echo   ^|_^|\_\    \_/ \___^|_^|\___/ \___^|_^|\__^|\__, ^|
echo                                         ^|___/
echo   KEYDAL Projects  ^|  Developer: Egemen KEYDAL
echo.

where java >nul 2>&1
if errorlevel 1 (
    echo [HATA] Java bulunamadi! Java 17+ kurulu olmali.
    echo [HATA] Indir: https://adoptium.net/
    pause
    exit /b 1
)

for /f "tokens=3" %%i in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    set "JAVA_VER_RAW=%%i"
    goto :java_parsed
)
:java_parsed
set "JAVA_VER_RAW=%JAVA_VER_RAW:"=%"
for /f "tokens=1 delims=." %%a in ("%JAVA_VER_RAW%") do set "JAVA_VER=%%a"

if %JAVA_VER% LSS 17 (
    echo [HATA] Java 17+ gerekli, mevcut: %JAVA_VER_RAW%
    echo [HATA] Indir: https://adoptium.net/
    pause
    exit /b 1
)
echo [kVelocity] Java %JAVA_VER% tespit edildi.

if not exist "%JAR%" (
    echo [kVelocity] %JAR% bulunamadi, PaperMC API'den en son surum indiriliyor...

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$ErrorActionPreference='Stop'; " ^
        "$ua = 'kVelocity/1.0'; " ^
        "try { " ^
        "  $proj = Invoke-RestMethod -UserAgent $ua -Uri '%API_BASE%/%PROJECT%'; " ^
        "  $ver = $proj.versions[-1]; " ^
        "  Write-Host ('[kVelocity] Surum: ' + $ver); " ^
        "  $builds = Invoke-RestMethod -UserAgent $ua -Uri ('%API_BASE%/%PROJECT%/versions/' + $ver + '/builds'); " ^
        "  $build = $builds.builds[-1]; " ^
        "  $buildNum = $build.build; " ^
        "  Write-Host ('[kVelocity] Build: ' + $buildNum); " ^
        "  $fileName = $build.downloads.application.name; " ^
        "  $url = '%API_BASE%/%PROJECT%/versions/' + $ver + '/builds/' + $buildNum + '/downloads/' + $fileName; " ^
        "  Invoke-WebRequest -UserAgent $ua -Uri $url -OutFile '%JAR%.tmp'; " ^
        "  Move-Item -Force '%JAR%.tmp' '%JAR%'; " ^
        "  Write-Host ('[kVelocity] ' + $fileName + ' basariyla indirildi.'); " ^
        "} catch { " ^
        "  Write-Host ('[HATA] Indirme basarisiz: ' + $_.Exception.Message); " ^
        "  if (Test-Path '%JAR%.tmp') { Remove-Item -Force '%JAR%.tmp' }; " ^
        "  exit 1; " ^
        "}"

    if errorlevel 1 (
        pause
        exit /b 1
    )
)

if %RAM% GEQ 10240 (
    set "G1HRS=16M"
) else if %RAM% GEQ 4096 (
    set "G1HRS=8M"
) else (
    set "G1HRS=4M"
)

echo [kVelocity] Baslatiliyor ^| RAM: %RAM%MB ^| G1HRS: %G1HRS% ^| Java: %JAVA_VER%
echo.

java ^
  -Xms%RAM%M ^
  -Xmx%RAM%M ^
  -XX:+UseG1GC ^
  -XX:G1HeapRegionSize=%G1HRS% ^
  -XX:+UnlockExperimentalVMOptions ^
  -XX:+ParallelRefProcEnabled ^
  -XX:+AlwaysPreTouch ^
  -XX:MaxGCPauseMillis=200 ^
  -XX:+DisableExplicitGC ^
  -XX:InitiatingHeapOccupancyPercent=15 ^
  -XX:G1MixedGCCountTarget=4 ^
  -XX:G1MixedGCLiveThresholdPercent=90 ^
  -XX:G1RSetUpdatingPauseTimePercent=5 ^
  -XX:SurvivorRatio=32 ^
  -XX:MaxTenuringThreshold=1 ^
  -XX:G1NewSizePercent=30 ^
  -XX:G1MaxNewSizePercent=40 ^
  -XX:G1HeapWastePercent=5 ^
  -XX:G1ReservePercent=20 ^
  -XX:+PerfDisableSharedMem ^
  -Dusing.aikars.flags=https://mcflags.emc.gs ^
  -Daikars.new.flags=true ^
  -Dvelocity.packet-decode-logging=false ^
  -jar %JAR%

if errorlevel 1 (
    echo.
    echo [HATA] Velocity beklenmedik sekilde kapandi. logs\latest.log dosyasini kontrol edin.
    pause
)
endlocal
