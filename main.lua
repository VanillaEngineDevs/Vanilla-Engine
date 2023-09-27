function love.load()
    -- Libraries
    input = (require "libs.baton").new {
        controls = {
            g_left = {"key:left", "key:a", "axis:leftx-", "button:dpleft"},
            g_right = {"key:right", "key:d", "axis:leftx+", "button:dpright"},
            g_up = {"key:up", "key:w", "axis:lefty-", "button:dpup"},
            g_down = {"key:down", "key:s", "axis:lefty+", "button:dpdown"},

            m_confirm = {"key:return", "button:a"},
        },
        joystick = love.joystick.getJoysticks()[1],
    }
    push = require "libs.push"
    Gamestate = require "libs.gamestate"
    json = require "libs.json"
    xml = require "libs.xml"
    Object = require "libs.classic"
    Timer = require "libs.timer"

    -- Modules
    require "modules.override"
    Paths = require "backend.Paths"
    Cache = require "backend.Cache"
    Conductor = require "backend.Conductor"
    Sprite = require "modules.Sprite"
    Group = require "modules.flixel.Group"
    Song = require "backend.Song"
    MusicBeatState = require "backend.MusicBeatState"
    StrumNote = require "objects.StrumNote"
    Note = require "objects.Note"

    push.setupScreen(1280, 720, {upscale = "normal"})

    -- States
    TitleState = require "states.Title"
    PlayState = require "states.Play"

    Gamestate.switch(TitleState)
end

function love.update(dt)
    Gamestate.update(dt)
    Timer.update(dt)
    input:update()
end

function love.resize(w, h)
    push.resize(w, h)
end

function love.draw()
    push:start()
        Gamestate.draw()
    push:finish()

    -- print fps
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
end
