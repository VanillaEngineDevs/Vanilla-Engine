local path = ...

local function r(p)
    return require(path .. "." .. p)
end

r("Lua.String")
r("Lua.Table")
r("Lua.Math")

Point = r("Point")

Signal = r("Signal")

Color = r("Color")

Graphic = r("Graphic")

--[[ Graphic:getGraphic("test") ]]

Basic = r("Basic")
Object = r("Object")
Camera = r("Camera")
Group = r("Group")
Container = r("Container")

State = r("State")
TransitionableState = r("TransitionableState")
Sprite = r("Sprite")
SpriteGroup = r("SpriteGroup")

Sound = r("Sound")