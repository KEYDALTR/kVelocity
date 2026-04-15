@echo off
setlocal EnableExtensions
set "SCRIPT_DIR=%~dp0"
set "ROOT_DIR=%SCRIPT_DIR%.."
set "VELOCITY_JAR=%ROOT_DIR%\velocity.jar"
set "OUT_JAR=%ROOT_DIR%\plugins\kGuard-1.0.0.jar"
set "BUILD_DIR=%SCRIPT_DIR%build"
set "TOOLS_DIR=%SCRIPT_DIR%tools"

if not exist "%VELOCITY_JAR%" (
    echo [HATA] velocity.jar bulunamadi: %VELOCITY_JAR%
    exit /b 1
)

if not exist "%TOOLS_DIR%\proguard-base.jar" (
    echo [HATA] tools\ klasoru bos. ProGuard jar'larini indirin ^(bkz. build.sh^).
    exit /b 1
)

if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
mkdir "%BUILD_DIR%\classes"

pushd "%SCRIPT_DIR%"

echo [kGuard] Compiling...
javac -encoding UTF-8 -cp "..\velocity.jar" -d "build\classes" ^
    "src\main\java\com\keydal\kguard\LicenseClient.java" ^
    "src\main\java\com\keydal\kguard\KGuardPlugin.java"
if errorlevel 1 ( popd & exit /b 1 )

echo [kGuard] Packaging raw jar...
pushd "build\classes"
jar cf "..\kGuard-raw.jar" .
popd

echo [kGuard] Running ProGuard ^(obfuscation + shrink^)...
if exist "%OUT_JAR%" del /f "%OUT_JAR%"
java -cp "tools\*" proguard.ProGuard @proguard.conf
if errorlevel 1 ( popd & exit /b 1 )

popd
echo [kGuard] Build OK -^> %OUT_JAR%
endlocal
