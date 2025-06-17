local jit = require("jit")
---@class love
local love = require("love")
local Config = require("Backend.Config")

local DEBUG = Config.Debug
local love_VerMajor, love_VerMinor, love_VerRevision, love_VerCodename = love.getVersion()

if love_VerMajor == 12 and love_VerCodename == "" then
    love_VerCodename = "PreRelease" -- Love12 has no codename currently
end

function love.conf(t)
    t.window.title = "Friday Night Funkin'" .. (
        DEBUG and
        (
            " | DEBUG | " .. love_VerMajor .. "." .. love_VerMinor .. "." .. love_VerRevision .. " (" .. love_VerCodename .. ")" .. 
            " | " .. jit.version .. " | " .. love._os .. " (" .. jit.arch .. ")"
        ) or ""
    )

    t.window.width = Config.WindowWidth
    t.window.height = Config.WindowHeight
    t.window.resizable = Config.Resizable
    
    -- Modify render settings, automatically uses which renderer is recommended

    t.version = Config.Version

    t.identity = Config.Identity

    t.console = true
end
