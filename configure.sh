#!/bin/bash
# Remote configurator for the KDE Store install of Deads Fastfetch Splash.
# Configures the files KDE already downloaded — no clone, no re-download.
#
#   curl -fsSL https://raw.githubusercontent.com/DeadIndian/fastfetch-kde-splash/main/configure.sh | bash
#
# Reconnect stdin to the terminal so prompts work under `curl | bash`
# (piped stdin is the script itself; without this every `read` just defaults).
( : </dev/tty ) 2>/dev/null && exec </dev/tty

set -e

QML="$HOME/.local/share/plasma/look-and-feel/fork-fastfetch-splash/contents/splash/Splash.qml"
if [ ! -f "$QML" ]; then
    echo "Not installed. Get it from System Settings > Splash Screen > Get New,"
    echo "or the KDE Store, then run this again."
    exit 1
fi

echo "Configuring Deads Fastfetch Splash"
echo ""

# Color (glow)
echo "Glow color: 1=red 2=blue 3=green 4=cyan 5=none (default), or a #HEX"
read -p "> " C; C=${C:-5}
case "$C" in
    1|red) COLOR="#ff0000" ;; 2|blue) COLOR="#0080ff" ;;
    3|green) COLOR="#00ff00" ;; 4|cyan) COLOR="#00ffff" ;;
    5|none) COLOR="none" ;; *) COLOR="$C" ;;
esac
if [ "$COLOR" = "none" ]; then GLOW="false"; else GLOW="true"; fi

# Layout
echo "Layout: 1=logo (default) 2=full 3=info 4=sequential"
read -p "> " L; L=${L:-1}
case "$L" in 2|full) LAYOUT="full" ;; 3|info) LAYOUT="info" ;; 4|sequential) LAYOUT="sequential" ;; *) LAYOUT="logo" ;; esac

# Background
echo "Background: 1=black (default) 2=transparent, or a #HEX"
read -p "> " B; B=${B:-1}
case "$B" in 2|transparent) BG="transparent" ;; 1|black) BG="#000000" ;; *) BG="$B" ;; esac

# Speed
echo "Speed: 1=normal (default) 2=fast 3=slow"
read -p "> " S; S=${S:-1}
case "$S" in
    2|fast) GLITCH=15; INTRO=400; EXIT=800; MIN=2500; DIV=25 ;;
    3|slow) GLITCH=50; INTRO=1500; EXIT=3000; MIN=6000; DIV=100 ;;
    *)      GLITCH=30; INTRO=800; EXIT=1500; MIN=4000; DIV=50 ;;
esac

sed -i "s/property bool isConfigured: .*/property bool isConfigured: true/g" "$QML"
sed -i "s/property string themeColor: \".*\"/property string themeColor: \"$COLOR\"/g" "$QML"
sed -i "s/property bool glowEnabled: .*/property bool glowEnabled: $GLOW/g" "$QML"
sed -i "s/property string displayMode: \".*\"/property string displayMode: \"$LAYOUT\"/g" "$QML"
sed -i "s/property string bgColor: \".*\"/property string bgColor: \"$BG\"/g" "$QML"
sed -i "s/property int glitchInterval: .*/property int glitchInterval: $GLITCH/g" "$QML"
sed -i "s/property int introDuration: .*/property int introDuration: $INTRO/g" "$QML"
sed -i "s/property int exitDuration: .*/property int exitDuration: $EXIT/g" "$QML"
sed -i "s/property int minSplashDuration: .*/property int minSplashDuration: $MIN/g" "$QML"
sed -i "s/property int frameDivisor: .*/property int frameDivisor: $DIV/g" "$QML"

echo ""
echo "Done: color=$COLOR layout=$LAYOUT bg=$BG"
echo "Re-select the splash in System Settings (or log out/in) to see it."
