@REM ==================================================================================================
@REM                                       ReVanced Installer
@REM                                    v1.0.0
@REM ==================================================================================================

@echo off
setlocal EnableDelayedExpansion

echo ======================
echo   ReVanced Installer
echo v1.0.0
echo ======================

echo.
echo =========== Getting ADB ===========

if exist platform-tools (
    echo ADB already downloaded^^!
) else (
    echo Downloading ADB...
    curl -L -o platform-tools.zip https://dl.google.com/android/repository/platform-tools_r31.0.3-windows.zip
    tar -xf platform-tools.zip
    del platform-tools.zip
)

echo.
echo ====== Searching for device =======

for /f "tokens=1,2 delims= " %%a in ('%cd%\platform-tools\adb.exe devices') do set "device=%%a"
if "%device%" == "List" (
    echo No device found^^!
    echo Please connect your android device and try again.
    pause
    exit
)

for /f "tokens=1 delims=device" %%a in ("%device%") do set "device=%%a"
if "%device%" == "" (
    echo No device found^^!
    echo Please connect your android device and try again.
    pause
    exit
)

for /f "tokens=1,2 delims=" %%a in ('%cd%\platform-tools\adb.exe devices') do set "deviceAuthorized=%%a"
if "x%deviceAuthorized%" == "x%deviceAuthorized:device=%" (
    echo Device not authorized^^!
    echo Please authorize your device and try again.
    pause
    exit
)

echo Device found: %device% 

echo.
echo ========== Getting Java ===========

if exist zulu17.42.19-ca-jdk17.0.7-win_x64 (
    echo Java already downloaded^^!
) else (
    echo Downloading Java...
    curl -L -o java.zip https://cdn.azul.com/zulu/bin/zulu17.42.19-ca-jdk17.0.7-win_x64.zip
    tar -xf java.zip
    del java.zip
)

echo.
echo ==== Getting ReVanced releases ====

set "cliUrl=https://api.github.com/repos/revanced/revanced-cli/releases/latest"
set "patchesUrl=https://api.github.com/repos/revanced/revanced-patches/releases/latest"
set "integrationsUrl=https://api.github.com/repos/revanced/revanced-integrations/releases/latest"

set string=
for /f "delims=" %%x in ('curl -s %cliUrl% --header "Authorization: Bearer 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"') do set "string=!string! %%x"
set string=%string:"=%
set "string=%string:~2,-2%"
set "string=%string:: ==%"
set "%string:, =" & set "%"

set cliDownloadUrl=%browser_download_url%
set cliDownloadUrl=%cliDownloadUrl:}=%
set cliDownloadUrl=%cliDownloadUrl:]=%
set cliVersion=%tag_name%

set string=
for /f "delims=" %%x in ('curl -s %patchesUrl% --header "Authorization: Bearer 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"') do set "string=!string! %%x"
set string=%string:"=%
set "string=%string:~2,-2%"
set "string=%string:: ==%"
set "%string:, =" & set "%"

set patchesDownloadUrl=%browser_download_url%
set patchesDownloadUrl=%patchesDownloadUrl:}=%
set patchesDownloadUrl=%patchesDownloadUrl:]=%
set patchesVersion=%tag_name%

set string=
for /f "delims=" %%x in ('curl -s %integrationsUrl% --header "Authorization: Bearer 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"') do set "string=!string! %%x"
set string=%string:"=%
set "string=%string:~2,-2%"
set "string=%string:: ==%"
set "%string:, =" & set "%"

set integrationsDownloadUrl=%browser_download_url%
set integrationsDownloadUrl=%integrationsDownloadUrl:}=%
set integrationsDownloadUrl=%integrationsDownloadUrl:]=%
set integrationsVersion=%tag_name%

echo.
if exist revanced-cli.jar (
    echo ReVanced CLI already downloaded^^!
) else (
    echo Downloading ReVanced CLI version %cliVersion%...
    curl -L -o revanced-cli.jar %cliDownloadUrl%
)

echo.
if exist revanced-patches.jar (
    echo ReVanced Patches already downloaded^^!
) else (
    echo Downloading ReVanced Patches version %patchesVersion%...
    curl -L -o revanced-patches.jar %patchesDownloadUrl%
)

echo.
if exist revanced-integrations.apk (
    echo ReVanced Integrations already downloaded^^!
) else (
    echo Downloading ReVanced Integrations version %integrationsVersion%...
    curl -L -o revanced-integrations.apk %integrationsDownloadUrl%
)

echo.
echo ===== Getting YouTube APK =====

if exist YouTube.apk (
    echo YouTube APK already downloaded^^!
) else (
    curl -L -o YouTube.apk https://www.dropbox.com/s/kyxl6e9920mt2pm/YouTube.apk?dl=1
)

echo.
echo ===== Getting MicroG APK =====
if exist "Vanced MicroG.apk" (
    echo Vanced MicroG APK already downloaded^^!
) else (
    curl -L -o "Vanced MicroG.apk" https://www.dropbox.com/s/w1ay9vztkqo7s0b/Vanced%20MicroG.apk?dl=1
)

echo.
echo ======== Installing MicroG ========
platform-tools\adb.exe shell pm uninstall --user 0 com.mgoogle.android.gms
platform-tools\adb.exe install -r "Vanced MicroG.apk"

echo.
echo ======== Patching YouTube =========
zulu17.42.19-ca-jdk17.0.7-win_x64\bin\java.exe -jar %cd%\revanced-cli.jar -a %cd%\YouTube.apk -o %cd%\YouTube-ReVanced.apk -b %cd%\revanced-patches.jar -m %cd%\revanced-integrations.apk -d %device%

pause
