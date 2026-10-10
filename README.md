# ![Logo](images/logo.png)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/VanillaEngineDevs/Vanilla-Engine?style=flat-square)](https://github.com/VanillaEngineDevs/Vanilla-Engine/releases/latest) [![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/VanillaEngineDevs/Vanilla-Engine?include_prereleases&style=flat-square)](https://github.com/VanillaEngineDevs/Vanilla-Engine/releases) [![GitHub all releases](https://img.shields.io/github/downloads/VanillaEngineDevs/Vanilla-Engine/total?style=flat-square)](https://github.com/VanillaEngineDevs/Vanilla-Engine/releases) [![GitHub issues](https://img.shields.io/github/issues/VanillaEngineDevs/Vanilla-Engine?style=flat-square)](https://github.com/VanillaEngineDevs/Vanilla-Engine/issues) [![GitHub](https://img.shields.io/github/license/VanillaEngineDevs/Vanilla-Engine?style=flat-square)](https://github.com/VanillaEngineDevs/Vanilla-Engine/blob/main/LICENSE) [![Discord](https://img.shields.io/discord/852658576577003550?style=flat-square)](https://discord.gg/tQGzN2Wu48)

[![Download Nightly](https://img.shields.io/badge/Download%20Nightly-black?style=flat-square&logo=github&logoSize=amg)](https://nightly.link/VanillaEngineDevs/Vanilla-Engine/workflows/build/main) [![Download Stable](https://img.shields.io/badge/Download%20Stable-black?style=flat-square&logo=github)](https://github.com/VanillaEngineDevs/Vanilla-Engine/releases/latest)
<br>
---

Friday Night Funkin' Vanilla Engine is a rewrite of [Friday Night Funkin'](https://ninja-muffin24.itch.io/funkin) built on [LÖVE](https://love2d.org/) for Windows and using [Funkin' Rewritten](https://github.com/HTV04/Funkin-Rewritten) as a base.

Friday Night Funkin' Rewritten features:
* A rewritten engine focused on performance and playability
* Much less memory usage than the original game
* Controller support
* Other cool features, like downscroll
* Extended support for more platforms (MacOS, Linux, Nintendo Switch, etc.)
* And more to come!

Join **Vanilla Engine's** server for VE updates and what not: https://discord.gg/TJfbQbptyW

Join **HTV's** server for Funkin' Rewritten updates and discussion: https://discord.gg/tQGzN2Wu48

---

## Controls
If using a controller on a PC, a controller with an Xbox button layout is recommended. (Controller keybinds are not rebindable)
#### Menu
| Action       | Input (Keyboard) | Input (Controller)  |
| :----------- | :------------    | ------------        |
| Select       | `Arrow Keys`     | `Left Stick / D-Pad`|
| Confirm      | `Enter`          | `A`                 |
| Back         | `Escape`         | `B`                 |
#### In-Game
| Action       | Input (Keyboard) | Input (Controller)  |
| :----------- | :------------    | ------------        |
| Arrows       | `WASD / Arrow Keys` | `Left Stick / Right Stick / Shoulder Buttons / D-Pad / ABXY` |
| Confirm (Game Over)      | `Enter`          | `A`                 |
| Back (Pause)         | `Return`         | `Start`              |
#### Debug
| Action          | Input (Keyboard-only) |
| :-----------    | :------------         |
| Take Screenshot | `F3`                  |
| Open Debug Menu | `7`                   |
> [!NOTE]
> Screenshots will be saved in the `screenshots` folder in the game's directory. The path varies by platform:
> | Platform         | Path                                      |
> | :------------    | :---                                      |
> | Windows          | `%APPDATA%\VE-FNFR\screenshots`           |
> | macOS            | `~/Library/Application Support/VE-FNFR/screenshots` |
> | Linux            | `~/.local/share/love/VE-FNFR/screenshots` |
> | Nintendo Switch  | `./VE-FNFR/screenshots`                   |

---

# Building
Prerequisites: **Python** (all platforms), `dkp-pacman` (Linux only).

### Build Command:
```
python make.py <version>
```
Where `<version>` can be one of: `win64`, `macos`, `switch`, `lovefile`, `all`, `clean`.

You can also add an `imageformat` argument, for example:  
```
python make.py win64 --imageformat dxt5
```
Possible formats: `PNG`, `dxt5`, `ASTC`

If using `ASTC`, you may supply an optional `--block` argument, for example:  
```
python make.py switch --imageformat ASTC --block 8x8
```

### Other Platforms
Follow the official instructions for LÖVE game distribution for your platform: https://love2d.org/wiki/Game_Distribution

---

# Special Thanks
* HTV04 for [Funkin' Rewritten](https://github.com/HTV04/Funkin-Rewritten), the original engine used for developing this Engine
* KadeDev for [FNFDataAPI](https://github.com/KadeDev/FNFDataAPI), which was referenced while developing the chart-reading system
* The developers of [BeatFever Mania](https://github.com/Sulunia/beatfever) for their music time interpolation code
* The developers of the [LÖVE](https://love2d.org/) framework, for making Funkin' Rewritten possible
* p-sam for developing [love-nx](https://github.com/retronx-team/love-nx), used for the Nintendo Switch version of the game
* Davidobot for developing [love.js](https://github.com/Davidobot/love.js), used for the Web version of the game
* TurtleP for developing [LÖVE Potion](https://github.com/lovebrew/LovePotion), originally used for the Nintendo Switch version of the game
* Funkin' Crew (ninjamuffin99, PhantomArcade, kawaisprite, and evilsk8er), for making such an awesome game!

---

# License
*Friday Night Funkin' Rewritten* is licensed under the terms of the GNU General Public License v3, with the exception of most of the images, music, and sounds, which are proprietary. While FNF Rewritten is open-source, you must not distribute these proprietary assets outside the game.

Also, derivative works (mods, forks, etc.) of FNF Rewritten must be open-source. The build methods shown in this README technically make one's code open-source anyway, but uploading it to GitHub or a similar service is highly recommended.
