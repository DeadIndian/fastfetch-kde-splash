# Adding a New Language

To add a new language to the installer:

1. Copy `lang/en.sh` to `lang/xx.sh` (replace `xx` with your language code)
2. Translate all `MSG_*` and `SPEED_*` variables

That's it! The installer automatically detects all `.sh` files in the `lang/` directory and matches them against the `$LANG` environment variable. No code changes needed.

## Available Variables

| Variable | Description |
|---|---|
| `MSG_WELCOME` | Welcome message |
| `MSG_HINT` | Hint about default options |
| `MSG_C_TEXT` | Color selection text |
| `MSG_C_INPUT` | Color selection prompt |
| `MSG_L_TEXT` | Layout selection text |
| `MSG_L_INPUT` | Layout selection prompt |
| `MSG_B_TEXT` | Background selection text |
| `MSG_B_INPUT` | Background selection prompt |
| `MSG_S_TEXT` | Speed selection text |
| `MSG_S_INPUT` | Speed selection prompt |
| `MSG_S_CUSTOM` | Custom speed prompt |
| `MSG_S_GLITCH` | Glitch interval prompt |
| `MSG_S_INTRO` | Intro duration prompt |
| `MSG_S_EXIT` | Exit duration prompt |
| `MSG_S_MIN` | Min splash duration prompt |
| `MSG_S_DIV` | Frame divisor prompt |
| `MSG_INSTALLING` | Installing message |
| `MSG_DONE` | Installation complete message |
| `MSG_USE` | Usage section header |
| `MSG_STEP1` | First usage step |
| `MSG_STEP2` | Second usage step |
| `MSG_NOTE` | Important note |
| `MSG_REMOVING` | Removing old version message |
| `SPEED_NORMAL` | Normal speed label |
| `SPEED_FAST` | Fast speed label |
| `SPEED_SLOW` | Slow speed label |
| `SPEED_CUSTOM` | Custom speed label |

## Testing

After creating your language file, test it by running:

```bash
LANG=xx_XX ./install.sh
```

Replace `xx_XX` with your locale (e.g., `de_DE`, `fr_FR`, `ja_JP`).
