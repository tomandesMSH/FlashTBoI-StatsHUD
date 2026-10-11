Stats HUD for The Binding of Isaac (Flash)
==========================================

Shows Isaac's current stats (speed, tears, damage, range, shot speed, luck, devil and angel room
chance) on the left side of the screen in the original Flash version of The Binding of Isaac
(Steam, including Wrath of the Lamb), like the stats HUD of Rebirth / Repentance.

This package contains NO game files. The patcher builds the modded game from your own copy.


Requirements
------------
- Windows
- The Binding of Isaac (Flash) installed, e.g. from Steam
- For the script version only: Python 3.8 or newer (https://www.python.org/downloads/),
  no extra packages needed


Install
-------
With the exe (Stats_HUD_Patcher.exe):
1. Put Stats_HUD_Patcher.exe in the folder where you want to keep the game (the "Stats HUD"
   folder is created next to it) and double-click it.
2. A game window appears for a few seconds while the patcher reads the game, then closes.
3. At the end, the patcher shows a Steam launch option and copies it to your clipboard
   (see "Steam" below).
4. Start the game with Steam's Play button (after pasting the launch option) or with
   "Stats HUD\Stats HUD.exe".

With the Python script (this zip):
1. Unzip this folder anywhere.
2. Open a command prompt in this folder and run:

       python stats_hud_patcher.py --get-projector

3. Start the game with Steam's Play button (after pasting the launch option it shows) or with
   "Stats HUD\Stats HUD.exe".

If the game is not in your Steam library, add --game "<folder with Isaac.exe>"
(for the exe: run it from a command prompt with that option).

The exe and --get-projector download Adobe's official Flash Player 32 projector
(flashplayer_32_sa.exe) from fpdownload.macromedia.com and check its fingerprint. You can also put
your own copy into the "Stats HUD" folder instead (exe: use --no-projector).


Together with EID Flash
-----------------------
Install EID Flash first, then patch its result instead of the original game (command prompt in
the folder that has both the "EID Flash" folder and the patcher):

    Stats_HUD_Patcher.exe --swf "EID Flash\isaac_eid.swf"
    (or: python stats_hud_patcher.py --get-projector --swf "EID Flash\isaac_eid.swf")

The "Stats HUD" folder then has the game with both mods. Use the launch option the Stats HUD
patcher shows. Repeat this after updating EID Flash.


Steam
-----
At the end, the patcher shows a launch option like this and copies it to your clipboard:

    "<your folder>\Stats HUD\Stats HUD.exe" %command%

Paste it into Steam: Library > right-click The Binding of Isaac > Properties > General >
Launch Options. Steam's Play button then starts Stats HUD instead of the normal game, and Steam
still shows the game as running and counts your playtime.

- If you move the "Stats HUD" folder, run the patcher again and paste the new launch option.
- To play the normal game again, clear the Launch Options box.


Playing
-------
- F3 shows/hides the stats.
- When a stat changes, the difference is shown next to it for a moment.
- Tears are shown as shots per second. Range is the game's own range value (23.00 at the
  start), the one behind the range bar of the pause screen.
- Devil / angel room: the chance that the boss room of this floor opens a devil room (or, in
  Wrath of the Lamb, the angel version of it). An angel room can only replace the devil room if
  you have seen a devil room before and never took a devil deal; until the door appears the
  chance is shown split between both. There is no devil room on the first floor.
- The modded game uses the same save as the Steam version: your unlocks and progress carry
  over in both directions. Don't run both versions at the same time, or one may overwrite the
  other's progress.
- Steam achievements: the launcher sends the achievements you unlock to Steam a few seconds
  later, with the game's own FlashAchievements.exe (Steam must be running). achievements.log
  next to the launcher shows what was sent.
- Your game files are never modified. To uninstall, clear the Steam launch option (if you set
  it) and delete the "Stats HUD" folder.


Credits
-------
Font and stat icons from External Item Descriptions by Wofsauge and contributors:
https://github.com/wofsauge/External-Item-Descriptions
The Binding of Isaac (c) Edmund McMillen & Florian Himsl.
