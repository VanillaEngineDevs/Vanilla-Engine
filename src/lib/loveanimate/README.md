# Highly modified by Guglio

# <img src="./logo.png" width="24" height="24" /> loveanimate
A library for Love2D to display atlases/spritesheets generated from Adobe Animate, similar to [FlxAnimate](https://lib.haxe.org/p/flxanimate/) or [GDAnimate](https://github.com/what-is-a-git/gdanimate).

---

## ❓ What formats are supported?
- [X] Texture Atlas (Adobe and [BTA](https://github.com/Dot-Stuff/BetterTextureAtlas), supports optimized and unoptimized variants)
- [X] Sparrow Atlas (v1 + v2)

---

## ❓ How do I test this out?
There are several examples to try out [here!](./examples/)

Simply run the project with `love .` to immediately test.
You can add the name of an example to test aswell, for example: `love . lyric`

---

## 💡 Example Usage
Loading and playing a texture atlas
```lua
-- This is the only line you need to import love.animate
require("loveanimate")

local atlas = nil

function love.load()
    atlas = love.animate.newTextureAtlas()

    -- my_atlas is a folder containing all of the images/data for the atlas,
    -- Make sure to use the folder path and NOT the path to any of the 
    -- contents of the folder.
    atlas:load("my_atlas")

    -- Starts playing a specific symbol.
    -- If none is specified, every symbol will be played, 
    -- one after the other.
    atlas:play("my_symbol")
end

function love.update(dt)
    atlas:update(dt) -- Make sure to update the atlas object!
end

function love.draw()
    atlas:draw() -- Can't see the atlas if you never draw it!
end
```

## 📜 TODO
- [X] Color Transform (needs more testing)