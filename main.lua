function love.load()
    -- Libraries
    input = (require "libs.baton").new {
        controls = {
            g_left = {"key:left", "key:a", "axis:leftx-", "button:dpleft"},
            g_right = {"key:right", "key:d", "axis:leftx+", "button:dpright"},
            g_up = {"key:up", "key:w", "axis:lefty-", "button:dpup"},
            g_down = {"key:down", "key:s", "axis:lefty+", "button:dpdown"},

            m_confirm = {"key:return", "button:a"},
            m_down = {"key:down", "button:dpdown"},
            m_up = {"key:up", "button:dpup"},
            m_left = {"key:left", "button:dpleft"},
            m_right = {"key:right", "button:dpright"},
            m_back = {"key:escape", "button:b"},
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
    CoolUtil = require "modules.CoolUtil"
    Paths = require "backend.Paths"
    Cache = require "backend.Cache"
    Conductor = require "backend.Conductor"
    Camera = require "backend.Camera"
    Sprite = require "modules.Sprite"
    Text = require "modules.Text"
    Group = require "modules.flixel.Group"
    Song = require "backend.Song"
    MusicBeatState = require "backend.MusicBeatState"
    BaseStage = require "backend.BaseStage"
    StageData = require "backend.StageData"
    WeekData = require "backend.WeekData"
    Difficulty = require "backend.Difficulty"

    StrumNote = require "objects.StrumNote"
    Note = require "objects.Note"
    Character = require "objects.Character"
    BGSprite = require "objects.BGSprite"

    Stages = {
        Stage = require "states.stages.Stage",
        Spooky = require "states.stages.Spooky",
        Philly = require "states.stages.Philly",
        Limo = require "states.stages.Limo",
    }

    push.setupScreen(1280, 720, {upscale = "normal"})


    -- States
    TitleState = require "states.Title"
    MainMenuState = require "states.MainMenu"
    StoryMenuState = require "states.StoryMenu"
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

        if MusicBeatState.fade.graphic then
            love.graphics.draw(MusicBeatState.fade.graphic, 0, MusicBeatState.fade.y, 0, push:getWidth(), MusicBeatState.fade.height)
        end
    push:finish()

    -- print fps
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
end
