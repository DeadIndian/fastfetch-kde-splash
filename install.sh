#!/bin/bash

# Fastfetch KDE Splash Screen Installer
# MIT License - herzane

set -e

# Language detection - dynamically load from lang/ based on $LANG
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

LANG_FILE=""
for f in "$SCRIPT_DIR/lang/"*.sh; do
    code=$(basename "$f" .sh)
    if [[ $LANG == "$code"* ]]; then
        LANG_FILE="$f"
        break
    fi
done

source "${LANG_FILE:-$SCRIPT_DIR/lang/en.sh}"

echo "$MSG_WELCOME"
echo "$MSG_HINT"
echo ""

# Question 1: Color
echo -e "$MSG_C_TEXT"
read -p "$MSG_C_INPUT" INPUT_COLOR
INPUT_COLOR=${INPUT_COLOR:-1} # Default to 1 if empty
case "$INPUT_COLOR" in
    1|red) COLOR="#ff0000" ;;
    2|blue) COLOR="#0080ff" ;;
    3|green) COLOR="#00ff00" ;;
    4|cyan) COLOR="#00ffff" ;;
    yellow) COLOR="#ffff00" ;;
    purple) COLOR="#8000ff" ;;
    *) COLOR="$INPUT_COLOR" ;; # Hex code or custom
esac

echo ""

# Question 2: Layout
echo -e "$MSG_L_TEXT"
read -p "$MSG_L_INPUT" INPUT_LAYOUT
INPUT_LAYOUT=${INPUT_LAYOUT:-1} # Default to 1 if empty
case "$INPUT_LAYOUT" in
    2|full) LAYOUT="full" ;;
    3|info) LAYOUT="info" ;;
    *) LAYOUT="logo" ;; # Any other input defaults to logo
esac

echo ""

# Question 3: Background
echo -e "$MSG_B_TEXT"
read -p "$MSG_B_INPUT" INPUT_BG
INPUT_BG=${INPUT_BG:-1} # Default to 1 if empty
case "$INPUT_BG" in
    2|transparent) BGCOLOR="transparent" ;;
    1|black) BGCOLOR="#000000" ;;
    *) BGCOLOR="$INPUT_BG" ;; # Hex code or custom
esac

echo ""

# Question 4: Speed
echo -e "$MSG_S_TEXT"
read -p "$MSG_S_INPUT" INPUT_SPEED
INPUT_SPEED=${INPUT_SPEED:-1} # Default to 1 if empty
case "$INPUT_SPEED" in
    4|custom)
        echo -e "\n$MSG_S_CUSTOM"
        read -p "$MSG_S_GLITCH" GLITCH; GLITCH=${GLITCH:-30}
        read -p "$MSG_S_INTRO" INTRO; INTRO=${INTRO:-800}
        read -p "$MSG_S_EXIT" EXIT; EXIT=${EXIT:-1500}
        read -p "$MSG_S_MIN" MIN_DUR; MIN_DUR=${MIN_DUR:-4000}
        read -p "$MSG_S_DIV" DIVISOR; DIVISOR=${DIVISOR:-50}
        SPEED_NAME="$SPEED_CUSTOM"
        ;;
    2|fast)
        GLITCH=15; INTRO=400; EXIT=800; MIN_DUR=2500; DIVISOR=25; SPEED_NAME="$SPEED_FAST"
        ;;
    3|slow)
        GLITCH=50; INTRO=1500; EXIT=3000; MIN_DUR=6000; DIVISOR=100; SPEED_NAME="$SPEED_SLOW"
        ;;
    *)
        GLITCH=30; INTRO=800; EXIT=1500; MIN_DUR=4000; DIVISOR=50; SPEED_NAME="$SPEED_NORMAL"
        ;;
esac

echo ""
echo "$MSG_INSTALLING"

# Target directory
TARGET_DIR="$HOME/.local/share/plasma/look-and-feel/fastfetch-splash"

# Remove existing installation to avoid duplicates in KDE settings
if [ -d "$TARGET_DIR" ]; then
    echo "$MSG_REMOVING"
    rm -rf "$TARGET_DIR"
fi

# Create directory
mkdir -p "$TARGET_DIR"

# Copy files
cp -r contents "$TARGET_DIR/"
cp metadata.json "$TARGET_DIR/"

# Inject settings into QML
TARGET_QML="$TARGET_DIR/contents/splash/Splash.qml"
sed -i "s/property bool isConfigured: .*/property bool isConfigured: true/g" "$TARGET_QML"
sed -i "s/property string themeColor: \".*\"/property string themeColor: \"$COLOR\"/g" "$TARGET_QML"
sed -i "s/property string displayMode: \".*\"/property string displayMode: \"$LAYOUT\"/g" "$TARGET_QML"
sed -i "s/property string bgColor: \".*\"/property string bgColor: \"$BGCOLOR\"/g" "$TARGET_QML"
sed -i "s/property int glitchInterval: .*/property int glitchInterval: $GLITCH/g" "$TARGET_QML"
sed -i "s/property int introDuration: .*/property int introDuration: $INTRO/g" "$TARGET_QML"
sed -i "s/property int exitDuration: .*/property int exitDuration: $EXIT/g" "$TARGET_QML"
sed -i "s/property int minSplashDuration: .*/property int minSplashDuration: $MIN_DUR/g" "$TARGET_QML"
sed -i "s/property int frameDivisor: .*/property int frameDivisor: $DIVISOR/g" "$TARGET_QML"

echo ""
printf "$MSG_DONE\n" "$COLOR" "$LAYOUT" "$BGCOLOR" "$SPEED_NAME"
echo ""
echo "$MSG_USE"
echo "   $MSG_STEP1"
echo "   $MSG_STEP2"
echo ""
echo "$MSG_NOTE"
