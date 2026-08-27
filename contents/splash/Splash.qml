import QtQuick
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasma5support as Plasma5Support
Rectangle {
    id: root
    color: bgColor
    // Bu değerler install.sh tarafından değiştirilebilir / These values can be changed by install.sh
    property bool isConfigured: true                            // Kurulum betiği çalıştırıldı mı kontrolü / Check if the installation script has been run
    property string themeColor: "#ff0000"                       // Parıltı rengi / Glow color (unused when glowEnabled=false)
    property bool glowEnabled: false                            // Parıltı açık mı / Is glow enabled (false = pure fastfetch colors)
    property string displayMode: "logo"                   // "logo" | "full" | "sequential" | "info"
    property string bgColor: "#000000"                          // Arkaplan rengi veya şeffaf "transparent" / Background color or "transparent"

    // Animasyon hızı ayarları / Animation speed settings
    // Bu değerler install.sh tarafından değiştirilebilir / These values can be changed by install.sh
    property int glitchInterval: 30      // Karakter belirme timer aralığı (ms) / Glitch reveal timer interval (ms)
    property int introDuration: 800      // Giriş animasyonu süresi (ms) / Intro fade-in duration (ms)
    property int exitDuration: 1500      // Çıkış animasyonu süresi (ms) / Exit fade-out duration (ms)
    property int minSplashDuration: 4000 // Minimum görünürlük süresi (ms) / Minimum visible duration (ms)
    property int frameDivisor: 50        // Kare başına karakter sayısı böleni / Chars-per-frame divisor (smaller = faster)

    property string logoData: ""
    property string infoData: ""

    // Ekranda gösterilen anlık veriler / Real-time data displayed on the screen
    property string displayedLogoData: ""
    property string displayedInfoData: ""

    // Plain-text versions (no HTML) used for index building
    property string logoPlain: ""
    property string infoPlain: ""

    // Animasyon durum değişkenleri / Animation state variables
    property var logoIndices: []
    property var infoIndices: []
    property int logoAnimStep: 0
    property int infoAnimStep: 0
    property int charsPerFrameLogo: 1
    property int charsPerFrameInfo: 1

    property bool logoLoaded: false
    property bool infoLoaded: false
    property bool errorOccurred: false
    property int stage: 0
    property bool minDurationMet: false

    property bool logoAnimDone: false
    property bool infoAnimStarted: false

    // ─── ANSI → HTML conversion ──────────────────────────────────────────────

    // Standard 4-bit palette (matches most terminal defaults)
    property var ansiPalette: [
        "#000000","#cc0000","#4e9a06","#c4a000",
        "#3465a4","#75507b","#06989a","#d3d7cf",
        "#555753","#ef2929","#8ae234","#fce94f",
        "#729fcf","#ad7fa8","#34e2e2","#eeeeec"
    ]

    // 256-color palette builder (called once, cached in ansi256)
    property var ansi256: []

    function buildAnsi256() {
        var p = [];
        // 0-15: standard + high-intensity (same as ansiPalette)
        for (var i = 0; i < 16; i++) p.push(ansiPalette[i]);
        // 16-231: 6×6×6 color cube
        for (var r = 0; r < 6; r++) {
            for (var g = 0; g < 6; g++) {
                for (var b = 0; b < 6; b++) {
                    var rv = r === 0 ? 0 : 55 + r * 40;
                    var gv = g === 0 ? 0 : 55 + g * 40;
                    var bv = b === 0 ? 0 : 55 + b * 40;
                    p.push("#" +
                    ("0" + rv.toString(16)).slice(-2) +
                    ("0" + gv.toString(16)).slice(-2) +
                    ("0" + bv.toString(16)).slice(-2));
                }
            }
        }
        // 232-255: grayscale ramp
        for (var s = 0; s < 24; s++) {
            var v = 8 + s * 10;
            p.push("#" +
            ("0" + v.toString(16)).slice(-2) +
            ("0" + v.toString(16)).slice(-2) +
            ("0" + v.toString(16)).slice(-2));
        }
        return p;
    }

    // Convert an ANSI SGR sequence (e.g. "38;5;196" or "32" or "0") to an
    // object { fg, bg, bold, reset }.  Returns only what changed.
    function parseSGR(params) {
        var result = { reset: false, bold: false, fg: null, bg: null };
        var nums = params === "" ? [0] : params.split(";").map(Number);
        var i = 0;
        while (i < nums.length) {
            var n = nums[i];
            if (n === 0) { result.reset = true; }
            else if (n === 1) { result.bold = true; }
            else if (n >= 30 && n <= 37) { result.fg = ansi256[n - 30]; }
            else if (n === 39) { result.fg = ""; }  // default fg
            else if (n >= 40 && n <= 47) { result.bg = ansi256[n - 40]; }
            else if (n === 49) { result.bg = ""; }
            else if (n >= 90 && n <= 97) { result.fg = ansi256[n - 90 + 8]; }
            else if (n >= 100 && n <= 107) { result.bg = ansi256[n - 100 + 8]; }
            else if (n === 38 || n === 48) {
                var isFg = (n === 38);
                if (nums[i+1] === 5 && i+2 < nums.length) {
                    // 256-color
                    var idx = nums[i+2];
                    if (isFg) result.fg = ansi256[idx]; else result.bg = ansi256[idx];
                    i += 2;
                } else if (nums[i+1] === 2 && i+4 < nums.length) {
                    // Truecolor
                    var hex = "#" +
                    ("0" + nums[i+2].toString(16)).slice(-2) +
                    ("0" + nums[i+3].toString(16)).slice(-2) +
                    ("0" + nums[i+4].toString(16)).slice(-2);
                    if (isFg) result.fg = hex; else result.bg = hex;
                    i += 4;
                }
            }
            i++;
        }
        return result;
    }

    // Main converter: ANSI string → HTML string + plain-text string (no tags)
    function ansiToHtml(raw) {
        if (ansi256.length === 0) ansi256 = buildAnsi256();

        var html = "";
        var plain = "";
        var spanOpen = false;
        var curFg = "";
        var curBg = "";
        var curBold = false;

        function closeSpan() {
            if (spanOpen) { html += "</span>"; spanOpen = false; }
        }
        function openSpan() {
            if (!curFg && !curBg && !curBold) return; // nothing to style
            var style = "";
            if (curFg)   style += "color:" + curFg + ";";
            if (curBg)   style += "background-color:" + curBg + ";";
            if (curBold) style += "font-weight:bold;";
            html += "<span style=\"" + style + "\">";
            spanOpen = true;
        }

        // Regex: captures escape sequences vs plain text
        var re = /(\x1B\[([0-9;]*)([A-GJKSTfmny]))|([^\x1B\n\r]+)|(\n|\r\n?)/g;
        var match;
        while ((match = re.exec(raw)) !== null) {
            if (match[5] !== undefined) {
                // Newline
                closeSpan();
                html += "<br/>";
                plain += "\n";
                if (curFg || curBg || curBold) openSpan();
            } else if (match[1] !== undefined) {
                // Escape sequence
                var cmd = match[3];
                if (cmd === "m") {
                    var sgr = parseSGR(match[2]);
                    closeSpan();
                    if (sgr.reset) { curFg = ""; curBg = ""; curBold = false; }
                    if (sgr.bold)  { curBold = true; }
                    if (sgr.fg !== null) { curFg = sgr.fg; }
                    if (sgr.bg !== null) { curBg = sgr.bg; }
                    openSpan();
                }
                // All other escape sequences (cursor moves, etc.) are discarded
            } else if (match[4] !== undefined) {
                // Plain text chunk
                var chunk = match[4];
                // HTML-escape special chars
                chunk = chunk.replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/ /g, "&nbsp;");
                html += chunk;
                // For plain: strip HTML entities back to chars for index counting
                plain += match[4];
            }
        }
        closeSpan();
        return { html: html, plain: plain };
    }

    // ─── Glitch animation helpers ─────────────────────────────────────────────

    // We animate on the *plain* text. displayedLogoData / displayedInfoData are
    // plain strings used only for index tracking; the actual Text items show
    // the HTML rebuilt on each step.

    property var logoHtmlChars: []   // per-character HTML fragments for logo
    property var infoHtmlChars: []   // per-character HTML fragments for info
    property var logoPlainChars: []  // matching plain chars (for space detection)
    property var infoPlainChars: []

    // Split an HTML string into per-plain-character fragments.
    // Each entry in the result array corresponds to one plain-text character
    // and contains the HTML needed to render it (including its opening span tag).
    function splitHtmlToChars(html, plain) {
        var chars = [];
        var pi = 0;   // plain index
        var hi = 0;   // html index
        var tagBuf = "";
        var inTag = false;
        var pendingTags = "";

        while (hi < html.length) {
            var c = html[hi];
            if (c === '<') {
                inTag = true;
                tagBuf = "<";
                hi++;
            } else if (inTag) {
                tagBuf += c;
                hi++;
                if (c === '>') {
                    inTag = false;
                    if (tagBuf === "<br/>") {
                        chars.push({ tags: pendingTags, char: "<br/>", tagsAfter: "" });
                        pi++;
                        pendingTags = "";
                    } else {
                        pendingTags += tagBuf;
                    }
                    tagBuf = "";
                }
            } else {
                if (pi >= plain.length) break;
                var entity = "";
                if (html.substring(hi, hi+6) === "&nbsp;") { entity = "&nbsp;"; hi += 6; }
                else if (html.substring(hi, hi+5) === "&amp;") { entity = "&amp;"; hi += 5; }
                else if (html.substring(hi, hi+4) === "&lt;") { entity = "&lt;"; hi += 4; }
                else if (html.substring(hi, hi+4) === "&gt;") { entity = "&gt;"; hi += 4; }
                else { entity = c; hi++; }

                chars.push({ tags: pendingTags, char: entity, tagsAfter: "" });
                pendingTags = "";
                pi++;
            }
        }
        if (pendingTags !== "" && chars.length > 0) {
            chars[chars.length - 1].tagsAfter = pendingTags;
        }
        return chars;
    }

    // Rebuild display HTML from current revealed set
    function rebuildHtml(htmlChars, revealedFlags) {
        var out = "";
        for (var i = 0; i < htmlChars.length; i++) {
            var item = htmlChars[i];
            out += item.tags;
            if (revealedFlags[i]) {
                out += item.char;
            } else {
                out += "<span style=\"color:transparent\">" + item.char + "</span>";
            }
            if (item.tagsAfter) {
                out += item.tagsAfter;
            }
        }
        return out;
    }

    property var logoRevealed: []
    property var infoRevealed: []

    // Karakterleri karıştırma fonksiyonu (Fisher-Yates) / Fisher-Yates character shuffling function
    function shuffleArray(array) {
        for (var i = array.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
    }

    // ─── Timers ───────────────────────────────────────────────────────────────

    Timer {
        id: minDurationTimer
        interval: root.minSplashDuration
        running: false
        onTriggered: {
            minDurationMet = true;
            if (root.stage >= 5) exitAnimation.start();
        }
    }

    // Rastgele metin belirme efekti Timer'ı / Random text reveal effect Timer
    Timer {
        id: glitchAnimTimer
        interval: root.glitchInterval
        running: false
        repeat: true
        onTriggered: {
            var finished = true;

            // Logo
            if (root.logoAnimStep < root.logoIndices.length) {
                finished = false;
                for (var i = 0; i < root.charsPerFrameLogo && root.logoAnimStep < root.logoIndices.length; i++) {
                    var idx = root.logoIndices[root.logoAnimStep];
                    root.logoRevealed[idx] = true;
                    root.logoAnimStep++;
                }
                logoText.text = rebuildHtml(root.logoHtmlChars, root.logoRevealed);

                if (root.displayMode === "sequential" &&
                    root.logoAnimStep >= root.logoIndices.length &&
                    !root.logoAnimDone) {
                    root.logoAnimDone = true;
                    }
            }

            // Info (full mode)
            if (root.displayMode === "full" && root.infoAnimStep < root.infoIndices.length) {
                finished = false;
                for (var j = 0; j < root.charsPerFrameInfo && root.infoAnimStep < root.infoIndices.length; j++) {
                    var jdx = root.infoIndices[root.infoAnimStep];
                    root.infoRevealed[jdx] = true;
                    root.infoAnimStep++;
                }
                infoText.text = rebuildHtml(root.infoHtmlChars, root.infoRevealed);
            }

            // Info (sequential mode, starts after logo done)
            if (root.displayMode === "sequential" && root.infoAnimStarted &&
                root.infoAnimStep < root.infoIndices.length) {
                finished = false;
            for (var k = 0; k < root.charsPerFrameInfo && root.infoAnimStep < root.infoIndices.length; k++) {
                var kdx = root.infoIndices[root.infoAnimStep];
                root.infoRevealed[kdx] = true;
                root.infoAnimStep++;
            }
            infoText.text = rebuildHtml(root.infoHtmlChars, root.infoRevealed);
                }

                if (finished) glitchAnimTimer.stop();
        }
    }

    onLogoAnimDoneChanged: {
        if (root.logoAnimDone && root.displayMode === "sequential") {
            slideLogoTimer.start();
        }
    }

    Timer {
        id: slideLogoTimer
        interval: 120
        running: false
        onTriggered: {
            logoSlideAnimation.start();
            infoFadeIn.start();
            root.infoAnimStarted = true;
            if (!glitchAnimTimer.running) glitchAnimTimer.start();
        }
    }

    // Güvenlik Zamanlayıcısı / Safety Timer
    Timer {
        id: safetyTimer
        interval: 3000
        running: true
        onTriggered: {
            var isReady = root.displayMode === "logo"
            ? root.logoLoaded
            : (root.displayMode === "info" ? root.infoLoaded : (root.logoLoaded && root.infoLoaded));
            if (!isReady) {
                showError("'fastfetch' not found or could not be executed.\nPlease make sure the package is installed.");
            }
        }
    }

    function showError(msg) {
        if (root.errorOccurred) return;
        root.errorOccurred = true;
        root.logoData = "";
        root.infoData = "Error: " + msg + "\n\nVisit GitHub for installation & details:\nhttps://github.com/DeadIndian/fastfetch-kde-splash";
        root.displayMode = "full";
        safetyTimer.stop();
        startEffects();
        errorExitTimer.start();
    }

    Timer {
        id: errorExitTimer
        interval: 2000
        onTriggered: {
            minDurationMet = true;
            if (root.stage >= 5) exitAnimation.start();
        }
    }

    // ─── startEffects ─────────────────────────────────────────────────────────

    function startEffects() {
        // Logo Ayarları / Logo Settings
        // Parse logo ANSI → HTML + plain
        if (root.displayMode !== "info") {
            var logoParsed = ansiToHtml(root.logoData);
            root.logoHtmlChars = splitHtmlToChars(logoParsed.html, logoParsed.plain);
            root.logoPlainChars = logoParsed.plain.split("");
            root.logoRevealed = new Array(root.logoHtmlChars.length).fill(false);

            // Build indices (skip spaces / newlines)
            root.logoIndices = [];
            for (var i = 0; i < root.logoPlainChars.length; i++) {
                var c = root.logoPlainChars[i];
                if (c !== ' ' && c !== '\n' && c !== '\r') {
                    root.logoIndices.push(i);
                } else {
                    root.logoRevealed[i] = true;
                }
            }
            shuffleArray(root.logoIndices);

            // Initial hidden render (preserves layout size)
            logoText.text = rebuildHtml(root.logoHtmlChars, root.logoRevealed);

            root.charsPerFrameLogo = root.displayMode === "sequential"
            ? Math.max(1, Math.ceil(root.logoIndices.length / (root.frameDivisor / 2)))
            : Math.max(1, Math.ceil(root.logoIndices.length / root.frameDivisor));
        }

        // Info Ayarları / Info Settings
        // Parse info ANSI → HTML + plain
        if (root.displayMode === "full" || root.displayMode === "sequential" || root.displayMode === "info") {
            var infoParsed = ansiToHtml(root.infoData);
            root.infoHtmlChars = splitHtmlToChars(infoParsed.html, infoParsed.plain);
            root.infoPlainChars = infoParsed.plain.split("");
            root.infoRevealed = new Array(root.infoHtmlChars.length).fill(false);

            root.infoIndices = [];
            for (var j = 0; j < root.infoPlainChars.length; j++) {
                var d = root.infoPlainChars[j];
                if (d !== ' ' && d !== '\n' && d !== '\r') {
                    root.infoIndices.push(j);
                } else {
                    root.infoRevealed[j] = true;
                }
            }
            shuffleArray(root.infoIndices);

            infoText.text = rebuildHtml(root.infoHtmlChars, root.infoRevealed);
            root.charsPerFrameInfo = Math.max(1, Math.ceil(root.infoIndices.length / root.frameDivisor));
        }

        // Sequential: logo starts centered
        if (root.displayMode === "sequential") {
            logoContainer.x = Qt.binding(function() {
                return (root.width - logoContainer.width) / 2;
            });
        }

        introAnimation.start();
        glitchAnimTimer.start();
        minDurationTimer.start();
    }

    onStageChanged: {
        if (stage >= 5 && minDurationMet) exitAnimation.start();
    }

    // ─── Data source ──────────────────────────────────────────────────────────

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            var stdout = data["stdout"] || "";
            // Do NOT strip color codes here — ansiToHtml handles them
            // Only strip non-SGR sequences (cursor movement etc.)
            var cleaned = stdout.replace(/\x1B\[(?![0-9;]*m)[0-9;]*[A-GJKSTfny]/g, "");

            // Trim trailing whitespace per line, and leading/trailing blank lines
            var lines = cleaned.split('\n');
            for (var i = 0; i < lines.length; i++) {
                lines[i] = lines[i].replace(/\s+$/, "");
            }
            cleaned = lines.join('\n').replace(/^[\r\n]+|[\r\n]+$/g, "");

            if (cleaned.replace(/\x1B\[[0-9;]*m/g, "").trim() === "") {
                showError("'fastfetch' returned an empty output.");
                return;
            }

            if (sourceName.indexOf("structure L") !== -1) {
                root.logoData = cleaned;
                root.logoLoaded = true;
            } else {
                root.infoData = cleaned;
                root.infoLoaded = true;
            }

            var isReady = (root.displayMode === "logo")
            ? root.logoLoaded
            : (root.displayMode === "info" ? root.infoLoaded : (root.logoLoaded && root.infoLoaded));

            if (isReady && !root.errorOccurred) {
                safetyTimer.stop();
                startEffects();
            }
            disconnectSource(sourceName);
        }
        function exec(cmd) { connectSource(cmd); }
    }

    // ─── UI ───────────────────────────────────────────────────────────────────

    Item {
        id: content
        anchors.fill: parent
        opacity: 0

        // LOGO BÖLÜMÜ / LOGO SECTION
        // LOGO — position managed by startEffects / logoSlideAnimation
        Item {
            id: logoContainer
            // Default position: left side of centered row ("info" mode hides logo)
            x: root.displayMode === "full"
            ? (root.width - (logoText.implicitWidth + 50 + infoText.implicitWidth)) / 2
            : (root.width - logoText.implicitWidth) / 2
            y: (root.height - logoText.implicitHeight) / 2
            width: logoText.implicitWidth
            height: logoText.implicitHeight
            visible: root.displayMode !== "info"

            Text {
                id: logoText
                text: ""
                color: "white"
                font.family: "Monospace"
                font.pointSize: 13
                font.weight: Font.Normal
                textFormat: Text.RichText
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
                wrapMode: Text.NoWrap
                // No 'color' — colors come from inline HTML spans
            }

            DropShadow {
                anchors.fill: logoText
                source: logoText
                transparentBorder: true
                visible: root.displayMode === "logo" && root.glowEnabled
                color: root.themeColor
                radius: 8   // İç parlama (Keskin) / Inner glow (Sharp)
                samples: 16
            }
            DropShadow {
                anchors.fill: logoText
                source: logoText
                transparentBorder: true
                visible: root.displayMode === "logo" && root.glowEnabled
                color: root.themeColor
                radius: 25  // Dış parlama (Aura) / Outer glow (Aura)
                samples: 30
                opacity: 0.6
            }
        }

        // BİLGİ BÖLÜMÜ / INFO SECTION
        Item {
            id: infoContainer
            visible: root.displayMode === "full" || root.displayMode === "sequential" || root.displayMode === "info"
            opacity: root.displayMode === "sequential" ? 0 : 1
            x: root.displayMode === "info"
            ? (root.width - infoText.implicitWidth) / 2
            : (logoContainer.x + logoContainer.width + 50)
            y: (root.height - infoText.implicitHeight) / 2
            width: infoText.implicitWidth
            height: infoText.implicitHeight

            OpacityAnimator {
                id: infoFadeIn
                target: infoContainer
                from: 0
                to: 1
                duration: 500
                easing.type: Easing.InOutQuad
            }

            Text {
                id: infoText
                text: ""
                color: "white"
                font.family: "Monospace"
                font.pointSize: 13
                textFormat: Text.RichText
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
            }

            DropShadow {
                anchors.fill: infoText
                source: infoText
                transparentBorder: true
                visible: root.displayMode === "logo" && root.glowEnabled
                color: root.themeColor
                radius: 6   // İç parlama / Inner glow
                samples: 12
            }
            DropShadow {
                anchors.fill: infoText
                source: infoText
                transparentBorder: true
                visible: root.displayMode === "logo" && root.glowEnabled
                color: root.themeColor
                radius: 20  // Dış parlama / Outer glow
                samples: 24
                opacity: 0.6
            }
        }
    }

    // Logo slides from center to its left-side position
    NumberAnimation {
        id: logoSlideAnimation
        target: logoContainer
        property: "x"
        from: (root.width - logoContainer.width) / 2
        to: (root.width - (logoContainer.width + 50 + infoContainer.width)) / 2
        duration: 600
        easing.type: Easing.InOutCubic
    }

    OpacityAnimator {
        id: introAnimation
        target: content
        from: 0; to: 1
        duration: root.introDuration
        easing.type: Easing.InOutQuad
    }

    OpacityAnimator {
        id: exitAnimation
        target: root
        from: 1; to: 0
        duration: root.exitDuration
        easing.type: Easing.InOutQuad
    }

    Component.onCompleted: {
        if (!root.isConfigured) {
            showError("Configuration required! Please run 'install.sh' to finalize.");
            return;
        }
        if (root.displayMode !== "info") {
            executable.exec("fastfetch --structure L --pipe false");
        }
        if (root.displayMode !== "logo") {
            executable.exec("fastfetch --logo none --pipe false");
        }
    }
}
