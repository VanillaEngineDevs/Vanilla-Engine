---@diagnostic disable: duplicate-doc-alias
-- Lua language server configs
---@alias number number?
---@alias integer number?
---@alias int integer
---@alias float number

-- Game configs
---@class Config
local Config = {}

Config.WindowWidth = 1280
Config.WindowHeight = 720

Config.GameWidth = 1280
Config.GameHeight = 720
Config.VSync = 0
Config.Resizable = true

Config.Version = "11.5.0"

Config.Company = "GuglioIsStupid"
Config.Identity = "MintEngine"

Config.Debug = not love.filesystem.isFused()

return Config