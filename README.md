# Screen Swap Mod — Windows Install

**Author:** kavtunov

Swap both split-screen sides (**Mio ↔ Zoe**) on Windows.

## Requirements

- Split Fiction on **Steam** or **EA App**
- [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS/releases) (experimental build recommended)

## 1. Find the game folder

Steam → Split Fiction → ⚙️ → Manage → Browse local files.

Typical path:

```text
...\Steam\steamapps\common\Split Fiction\Split\Binaries\Win64\
```

You should see `SplitFiction.exe` in that folder.

## 2. Install UE4SS

1. Download the latest **experimental** UE4SS zip from:  
   https://github.com/UE4SS-RE/RE-UE4SS/releases
2. Extract so you get:

```text
Win64\
  dwmapi.dll
  ue4ss\
    UE4SS.dll
    UE4SS-settings.ini
    Mods\
```

3. Replace `ue4ss\UE4SS-settings.ini` with the Split Fiction config from the UE4SS repo:  
   `assets/CustomGameConfigs/Split Fiction/UE4SS-settings.ini`

## 3. Install this mod

Copy this folder:

```text
Mods\ScreenSwapMod\
```

into:

```text
...\Win64\ue4ss\Mods\ScreenSwapMod\
```

Edit `ue4ss\Mods\mods.txt` and add (or enable) this line **before** `Keybinds`:

```text
ScreenSwapMod : 1
```

You can copy the line from `Mods\mods-entry.txt`.

## 4. Play

1. Start the game and enter **local co-op**.
2. Press **F7** — confirm two LocalPlayers appear in the log.
3. Press **F8** — both screen sides should swap.

Log file:

```text
...\Win64\ue4ss\UE4SS.log
```

Look for lines starting with `[ScreenSwapMod]`.

## Hotkeys

| Key | Action |
|-----|--------|
| **F8** | Swap both sides |
| **F7** | Dump viewports to log |
| **F6** | Force classic L/R layout |

## Troubleshooting

Split Fiction uses Hazelight’s custom split rendering. A simple `LocalPlayer` Origin/Size swap may not work in every scene.

1. After F7 / F8, send the relevant part of `UE4SS.log`.
2. Optionally enable the UE4SS GUI in `UE4SS-settings.ini`:

```ini
[Debug]
ConsoleEnabled = 1
GuiConsoleEnabled = 1
GuiConsoleVisible = 1
```

3. Search live objects for classes matching `*Split*`, `*Viewport*`, `*Layout*` and update the Lua script.

## Uninstall

Delete `dwmapi.dll` and the `ue4ss` folder, **or** set `ScreenSwapMod : 0` in `mods.txt`.
