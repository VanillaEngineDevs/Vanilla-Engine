# DOWNLOAD NIGHTLY HERE: https://nightly.link/VanillaEngineDevs/Vanilla-Engine/workflows/build/main

# ![Logo](images/logo.png)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/VanillaEngineDevs/Vanilla-Engine?style=flat-square)](https://github.com/VanillaEngineDevs/Vanilla-Engine/releases/latest) [![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/VanillaEngineDevs/Vanilla-Engine?include_prereleases&style=flat-square)](https://github.com/VanillaEngineDevs/Vanilla-Engine/releases) [![GitHub all releases](https://img.shields.io/github/downloads/VanillaEngineDevs/Vanilla-Engine/total?style=flat-square)](https://github.com/VanillaEngineDevs/Vanilla-Engine/releases) [![GitHub issues](https://img.shields.io/github/issues/VanillaEngineDevs/Vanilla-Engine?style=flat-square)](https://github.com/VanillaEngineDevs/Vanilla-Engine/issues) [![GitHub](https://img.shields.io/github/license/VanillaEngineDevs/Vanilla-Engine?style=flat-square)](https://github.com/VanillaEngineDevs/Vanilla-Engine/blob/main/LICENSE) [![Discord](https://img.shields.io/discord/852658576577003550?style=flat-square)](https://discord.gg/tQGzN2Wu48)

# FOR MODDING, READ HERE
Vanilla Engine has recently been updated to support the new FNF 0.3.x charts. For backwords compatibility for Charts, Inst, and Vocals, do the following:
1. In your week file, instead of weeks:generateNotes(chartfile, metafile, difficulty), call weeks:legacyGenerateNotes(chartfile)
2. Only load the vocals for "VoicesBF". This is because VE now uses the FNNF 0.3.x Vocals system (split-vocal files).


Friday Night Funkin' Vanilla Engine is a rewrite of [Friday Night Funkin'](https://ninja-muffin24.itch.io/funkin) built on [LÖVE](https://love2d.org/) for Windows and using [Funkin' Rewritten](https://github.com/HTV04/Funkin-Rewritten) for macOS, Linux, and Web platforms, as well as previously unsupported platforms, like the Nintendo Switch!

Friday Night Funkin' Rewritten features:
* A rewritten engine focused on performance and playability
* Much less memory usage than the original game
* Controller support
* Other cool features, like downscroll
* And more to come!

Join Vanilla Engines server for VE updates and what not: https://discord.gg/TBF3HkXWhq

Join my HTV's server for Funkin' Rewritten updates and discussion: https://discord.gg/tQGzN2Wu48

# Controls
If using a controller on a PC, a controller with an Xbox button layout is recommended. Controller buttons will be remappable in a future update.

## Menus
### Keyboard
* Arrow Keys - Select
* Enter - Confirm
* Escape - Back

### Controller
* Left Stick/D-Pad - Select
* A - Confirm
* B - Back

## Game
### Keyboard
* WASD/Arrow Keys - Arrows
* Enter - Confirm (Game Over)
* Escape - Exit

### Controller
* Left Stick/Right Stick/Shoulder Buttons/D-Pad/ABXY - Arrows
* A - Confirm (Game Over)
* Start - Exit

## Debug
### Keyboard
* 6 - Take screenshot
  * Screenshot paths:
    * Windows - `%APPDATA%\VE-FNFR\screenshots`
    * macOS - `~/Library/Application Support/VE-FNFR/screenshots`
	* Linux - `~/.local/share/love/VE-FNFR/screenshots`
	* Nintendo Switch - `./VE-FNFR/screenshots`
* 7 - Open debug menu

# Settings
The settings file can be found in the following places on the following systems:
* Windows - `%APPDATA%\VE-FNFR\settings.ini`
* macOS - `~/Library/Application Support/VE-FNFR/settings.ini`
* Linux - `~/.local/share/love/VE-FNFR/settings.ini`
* Nintendo Switch - `./VE-FNFR/settings.ini`

# Progress
**Menus** - 100% Complete

**Game Engine** - 99% Complete

**Weeks** - 8/8 Complete
* Tutorial + Weeks 1-7 are implemented.

# License
*Friday Night Funkin' Rewritten* is licensed under the terms of the GNU General Public License v3, with the exception of most of the images, music, and sounds, which are proprietary. While FNF Rewritten's code is FOSS, use its assets at your own risk.

Also, derivative works (mods, forks, etc.) of FNF Rewritten must be open-source. The build methods shown in this README technically make one's code open-source anyway, but uploading it to GitHub or a similar platform is advised.

# Building
Web build instructions coming soon! Current method isn't that portable right now, but I'm working on something.

## Unix-like (macOS, Linux, etc.)
After running a build method, its release ZIP will be located at `./build/release`.

### LOVE file
* Run `make lovefile`

### Windows (64-bit)
* Set up dependencies shown in `./resources/win64/dependencies.txt`
* Run `make win64`

### Windows (32-bit)
* Set up dependencies shown in `./resources/win32/dependencies.txt`
* Run `make win32`

### macOS
* Set up dependencies shown in `./resources/macos/dependencies.txt`
* Run `make macos`

### Nintendo Switch
* Set up [devkitPro](https://devkitpro.org/wiki/Getting_Started)
  * Install the `switch-dev` package
* Set up dependencies shown in `./resources/switch/dependencies.txt`
* Run `make switch`

### Desktop Platforms
* Set up dependencies shown in `./resources/win64/dependencies.txt`
* Set up dependencies shown in `./resources/win32/dependencies.txt`
* Set up dependencies shown in `./resources/macos/dependencies.txt`
* Run `make desktop`

### Console Platforms
* Set up [devkitPro](https://devkitpro.org/wiki/Getting_Started)
  * Install the `switch-dev` package
* Set up dependencies shown in `./resources/switch/dependencies.txt`
* Run `make console`

### All Platforms
* Set up dependencies shown in `./resources/win64/dependencies.txt`
* Set up dependencies shown in `./resources/win32/dependencies.txt`
* Set up dependencies shown in `./resources/macos/dependencies.txt`
* Set up [devkitPro](https://devkitpro.org/wiki/Getting_Started)
  * Install the `switch-dev` package
* Set up dependencies shown in `./resources/switch/dependencies.txt`
* Run `make`

## Other
Follow the official instructions for LÖVE game distribution for your platform: https://love2d.org/wiki/Game_Distribution

# Special Thanks
* HTV04 for [Funkin' Rewritten](https://github.com/HTV04/Funkin-Rewritten), the original engine used for developing this Engine
* KadeDev for [FNFDataAPI](https://github.com/KadeDev/FNFDataAPI), which was refrenced while developing the chart-reading system
* The developers of [BeatFever Mania](https://github.com/Sulunia/beatfever) for their music time interpolation code
* The developers of the [LÖVE](https://love2d.org/) framework, for making Funkin' Rewritten possible
* p-sam for developing [love-nx](https://github.com/retronx-team/love-nx), used for the Nintendo Switch version of the game
* Davidobot for developing [love.js](https://github.com/Davidobot/love.js), used for the Web version of the game
* TurtleP for developing [LÖVE Potion](https://github.com/lovebrew/LovePotion), originally used for the Nintendo Switch version of the game
* Funkin' Crew (ninjamuffin99, PhantomArcade, kawaisprite, and evilsk8er), for making such an awesome game!
