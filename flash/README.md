# Stats HUD for The Binding of Isaac (Flash)

A stats overlay for the original Flash game ([Steam app 113200](https://store.steampowered.com/app/113200/The_Binding_of_Isaac/),
including Wrath of the Lamb and the Eternal Edition). It shows Isaac's speed, tears, damage, range, shot speed, luck,
devil room chance and angel room chance on the left side of the screen, like Repentance's stats HUD, with the
Repentance HUD icons (from EID's inline icons) and EID's bitmap font.

It is built exactly like [EID Flash](https://github.com/tomandesMSH/FlashTBoI-EID/blob/master/flash/README.md): players install it with the
**patcher** (`patcher/`), which builds the modded game from their own copy, so no game files are ever distributed.
See `patcher/README.txt` for the player instructions.

## How it works

The Flash game has no mod API. The Steam build is an MDM Zinc 3 projector that keeps the game SWF encrypted inside
`Isaac.exe`.

- **Release side** (`tools/make_payload.py`): the Stats HUD code is compiled on its own into a DoAction tag (a
  generated one-frame SWF is filled by FFDec and the tag is taken out again). It is stored in
  `patcher/stats_hud_payload.json` together with the font/icon atlas. The payload contains only the mod's own code
  and assets, no game code.
- **Player side** (`patcher/stats_hud_patcher.py`, Python standard library only):
  1. Copies the game folder to a temporary folder and runs the copy for a few seconds.
  2. Reads the decrypted SWF (SWF 8, ActionScript 2) from the copy's memory.
  3. Inserts the atlas (`DefineBitsLossless2` + `ExportAssets` "shud_atlas") and the DoAction into frame 1, after
     the game's own script.
  4. Writes `Stats HUD/isaac_stats.swf` and the launcher `Stats HUD/Stats HUD.exe` for Adobe's standalone Flash
     Player 32 projector (`--get-projector` downloads it and verifies its checksum).
  5. Prints the Steam launch option `"<folder>\Stats HUD\Stats HUD.exe" %command%` and copies it to the clipboard.

`--swf "EID Flash/isaac_eid.swf"` patches EID Flash's result instead, giving a game with both mods. The patcher
recognises EID Flash by its `eid_atlas` export and refuses an SWF that already has `shud_atlas`. Both mods carry the
same projector compatibility code (`as2/shud_host.as` is EID's `eid_host.as`); the second one skips itself when
`_root.fullf.eidHost` is already set.

## Where the values come from

Everything is read from or computed by the game's own code in the game clip `_root.a` (DefineSprite 6765). The
overlay refreshes every frame and only redraws a row when its text changes.

| Stat | Source |
|---|---|
| Speed | `_root.playsp`, recomputed by the game every frame in the player update. |
| Tears | `firr(t)` on a scratch object: the game's fire delay function (`t.fire`, frames between shots at 30 fps), shown as `30 / (delay + 1)`, Rebirth's convention (base 2.73). Dr. Fetus' `x3 + 10` from the firing code is applied. |
| Damage | `dmgdo()`, the function each tear's damage comes from, times the tear's `x1.15` for Cricket's Head, Blood of the Martyr, Magic Mushroom and The Devil / Book of Belial (`create()`, tear type 2). Chemical Peel's left eye bonus and Chocolate Milk's charge are left out (per shot); the variables `dmgdo()` changes (`_root.firrb`, `sob`, `chaf`, `chal`, `f1`) are restored. |
| Range | The game's range value `_root.firrr` (base 23; the pause screen's range bar), computed from the tear height and fall speed that `create()` sets, without its random per-tear part. |
| Shot speed | The tear speed multiplier from `create()`: clamped to 0.6 - 1.42, then x1.4 with My Reflection. |
| Luck | `_root.luck`. |
| Devil room | The roll made when the boss room's devil door is checked (`trg.sat` in the room code): `min(0.3, Pentagram x0.2) + 1%`, +25% / +35% for the held items `_root.it` 2 / 38, +35% for a killed beggar (`_root.bumkill`), +35% while `bossdmg`, +99% while no damage was taken on the floor (`_root.devil`), halved twice by a devil room in the last floors (`_root.lastdev`). None on floor 1 and from floor 9. After the roll: 100% (`_root.devil == 2`) or 0% (`== 3`). |
| Angel room | Wrath of the Lamb replaces the devil room with a holy room (angel items: `_root.ittt10`) when `_root.altsat`, a coin flip at the start of the floor made only if a devil room was seen before (`lastdev > 0`) and no deal was taken (`evs == 0`). In that case the chance is split evenly between devil and angel until the room appears, without peeking at the coin flip. |

## Layout

| Path | Purpose |
|---|---|
| `as2/shud_host.as` | Projector compatibility (fullscreen, quit), same as EID Flash's; skipped when EID Flash is already in the SWF. |
| `as2/shud_stats.as` | Overlay: stat computation and renderer (ActionScript 2). Settings in `_root.shudCfg` (scale 1.6 = 2 screen pixels per font pixel at the default 800x600 window, position, alpha, change indicator time). |
| `as2/shud_debug.as` | Test-only hooks for `--debug` builds: F9 teleports to the treasure room, F8 adds the next test item to `ups[]`, F7 luck +1, F6 loses the floor's no-damage bonus, F5 pretends to be on floor 5 with a devil room seen before. |
| `data/eid_markup.lua` | EID's inline icon table (copied from EID's `features/eid_data.lua`), for the stat icon frames and offsets. |
| `patcher/stats_hud_patcher.py` | The player-facing patcher: dumps the user's game, applies the payload, sets up the launcher. |
| `patcher/stats_hud_payload.json` | Generated by `build.py`: compiled code + atlas + launcher. Contains no game code. |
| `patcher/README.txt` | Player instructions, shipped in the release zip. |
| `launcher/StatsHUDLauncher.cs` | `Stats HUD.exe` (C#, compiled with Windows' .NET Framework `csc`): starts the projector with `isaac_stats.swf`, ignores its arguments (Steam's `%command%`) and waits for the game to close. |
| `tools/shud_assets.py` | Builds the atlas and AS2 tables from `resources/font/eid_default.fnt`, `resources/gfx/eid_inline_icons.anm2` and `data/eid_markup.lua`. |
| `tools/make_payload.py` | Compiles the AS2 code on its own and the launcher, and writes the payload. |
| `tools/build.py` | Developer build: makes the payload and applies it with the patcher (`--swf` to patch another SWF, e.g. EID Flash's). |
| `tools/package.py` | Zips `patcher/` into `Stats_HUD_<version>.zip` for release. |
| `tools/build_exe.py` | Builds `Stats_HUD_Patcher.exe` (PyInstaller, single file, payload bundled). |
| `tools/swfdump.py` | Developer helper: dumps `<work>/isaac.swf` with the patcher's dump code. |
| `tools/test/` | `keys.ps1`, `shot.ps1`, `screen.ps1`: send keys to the game window and take screenshots, for in-game tests. |
| `VERSION` | Version (used in the payload and release zip name). |

## Building

Everything derived from the game lives in a work directory outside the repository: `$STATS_HUD_WORK`, else
`$EID_FLASH_WORK`, default `~/flash-isaac-decomp` (the same one EID Flash uses; this mod's output goes to
`<work>/build/stats_hud/`). **Never commit those files.** They contain the game's code and assets.

Requirements are the same as for EID Flash: Windows, Python 3 with Pillow, a Java 21 runtime and JPEXS FFDec in
`<work>/tools` (or `$JAVA` / `$FFDEC_JAR`), and Adobe's Flash Player 32 projector to play the result.

```sh
python flash/tools/swfdump.py            # once (or reuse EID Flash's): writes <work>/isaac.swf
python flash/tools/build.py              # refreshes patcher/stats_hud_payload.json -> <work>/build/stats_hud/isaac_stats.swf
python flash/tools/build.py --debug      # -> isaac_stats_debug.swf (test hooks, payload not refreshed)
python flash/tools/build.py --swf <work>/build/isaac_eid.swf   # both mods in one SWF
python flash/tools/package.py            # -> <work>/build/stats_hud/Stats_HUD_<version>.zip
python flash/tools/build_exe.py          # -> <work>/build/stats_hud/exe/Stats_HUD_Patcher.exe (pip install pyinstaller)
```

Release: bump `VERSION`, run `build.py`, `package.py` and `build_exe.py`, commit the refreshed payload, then attach
the exe and the zip to a release tagged `v<VERSION>`.

## Credits

- Font and stat icons from External Item Descriptions by Wofsauge and contributors, see `../CREDITS.md`.
- The Binding of Isaac © Edmund McMillen & Florian Himsl. No game code or assets are included here.
