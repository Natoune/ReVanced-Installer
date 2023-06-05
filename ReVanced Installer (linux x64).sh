#!/bin/bash

echo "======================"
echo " ReVanced Installer"
echo " v1.0.0"
echo "======================"

echo ""
echo "=========== Getting ADB ==========="

if [ -d "platform-tools" ]; then
echo "ADB already downloaded!"
else
echo "Downloading ADB..."
curl -L --ssl-no-revoke -o platform-tools.zip https://dl.google.com/android/repository/platform-tools_r31.0.3-linux.zip
unzip -q platform-tools.zip
rm platform-tools.zip
fi

echo ""
echo "======= Searching for device ======="

device=$(./platform-tools/adb devices | awk '{print $1}' | tail -n 1)
if [ "$device" == "List" || "$device" == "" ]; then
echo "No device found!"
echo "Please connect your android device and try again."
read -p "Press any key to continue..."
exit
fi

echo "Device found: $device"

echo ""
echo "=========== Getting Java ==========="

if [ -d "zulu17.42.19-ca-jdk17.0.7-linux_x64" ]; then
echo "Java already downloaded!"
else
echo "Downloading Java..."
curl -L --ssl-no-revoke -o java.zip https://cdn.azul.com/zulu/bin/zulu17.42.19-ca-jdk17.0.7-linux_x64.tar.gz
unzip -q java.zip
rm java.zip
fi

echo ""
echo "===== Getting ReVanced releases ====="

cliUrl="https://api.github.com/repos/revanced/revanced-cli/releases/latest"
patchesUrl="https://api.github.com/repos/revanced/revanced-patches/releases/latest"
integrationsUrl="https://api.github.com/repos/revanced/revanced-integrations/releases/latest"

string=$(curl -s "$cliUrl" --header "Authorization: Bearer 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")
cliDownloadUrl=$(echo "$string" | grep "browser_download_url" | cut -d '"' -f 4)
cliVersion=$(echo "$string" | grep "tag_name" | cut -d '"' -f 4)

string=$(curl -s "$patchesUrl" --header "Authorization: Bearer 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")
patchesDownloadUrl=$(echo "$string" | grep "browser_download_url" | cut -d '"' -f 4)
patchesVersion=$(echo "$string" | grep "tag_name" | cut -d '"' -f 4)

string=$(curl -s "$integrationsUrl" --header "Authorization: Bearer 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")
integrationsDownloadUrl=$(echo "$string" | grep "browser_download_url" | cut -d '"' -f 4)
integrationsVersion=$(echo "$string" | grep "tag_name" | cut -d '"' -f 4)

echo ""
if [ -d "revanced-cli.jar" ]; then
echo "ReVanced CLI already downloaded!"
else
echo "Downloading ReVanced CLI version $cliVersion..."
curl -L --ssl-no-revoke -o revanced-cli.jar "$cliDownloadUrl"
fi

echo ""
if [ -d "revanced-patches.jar" ]; then
echo "ReVanced Patches already downloaded!"
else
echo "Downloading ReVanced Patches version $patchesVersion..."
curl -L --ssl-no-revoke -o revanced-patches.jar "$patchesDownloadUrl"
fi

echo ""
if [ -d "revanced-integrations.apk" ]; then
echo "ReVanced Integrations already downloaded!"
else
echo "Downloading ReVanced Integrations version $integrationsVersion..."
curl -L --ssl-no-revoke -o revanced-integrations.apk "$integrationsDownloadUrl"
fi

echo ""
echo "===== Getting YouTube APK ====="

if [ -d "YouTube.apk" ]
echo "YouTube APK already downloaded!"
else
curl -L --ssl-no-revoke -o YouTube.apk https://www.dropbox.com/s/kyxl6e9920mt2pm/YouTube.apk?dl=1
fi

echo ""
echo "===== Getting MicroG APK ====="

if [ -d "Vanced MicroG.apk" ]
echo "Vanced MicroG APK already downloaded!"
else
curl -L --ssl-no-revoke -o "Vanced MicroG.apk" https://www.dropbox.com/s/w1ay9vztkqo7s0b/Vanced%20MicroG.apk?dl=1
fi

echo ""
echo "======== Installing MicroG ========"
./platform-tools/adb install -r "Vanced MicroG.apk"

echo ""
echo "======== Patching YouTube ========="

zulu17.42.19-ca-jdk17.0.7-linux_x64/bin/java -jar $(pwd)/revanced-cli.jar -a $(pwd)/YouTube.apk -o $(pwd)/YouTube-ReVanced.apk -b $(pwd)/revanced-patches.jar -m $(pwd)/revanced-integrations.apk -d $device
