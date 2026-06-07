# Bubsy in: Fractured Furry Tales source code (Atari Jaguar, 1994)

Here lies the source code of Bubsy in: Fractured Furry Tales for the Atari Jaguar, released on December 9, 1994. 

Currently this source is a WIP, this is being converted from Devpac syntax to MadMac syntax.

You can find the original source code on this GitHub, or find it here: https://forums.atariage.com/topic/224770-the-atari-jaguar-source-code-thread/#findComment-3693564

Known issues with the source currently:
* EEPROM/savedata fails to read/write properly (crashes)
* Title screen, credits, and hi-score menu don't display
* ~~Level scroll routines are currently messed up~~
* ~~Sound effects are not enabled by default (see EEPROM issue)~~
* Not all entities are scripted/mapped correctly

If you'd like to contribute, shoot up a PR (pull request) and I will accept any fixes when I can.

To build the game, run `build.bat` in the root folder.

You must have the original files to properly build the game. Find the unpacker at `tools/unpack.py`, then select your Bubsy ROM.

Credits for source code:
* Andrew Seed (https://forums.atariage.com/profile/36194-seedy1812/)
* Doctor Clu (https://forums.atariage.com/profile/4709-doctorclu/)
* The RMAC/RLN authors 2011-2026 (https://rmac.is-slick.com/)
* Jaguar SDK Utilities (https://github.com/cubanismo/jag_utils/)
* Pro-Pack Utils (https://github.com/lab313ru/rnc_propack_source)
