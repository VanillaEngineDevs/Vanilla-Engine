oPrint = print
function print(...)
    local args = {...}
    for i = 1, #args do
        args[i] = tostring(args[i])
    end
    oPrint("[" .. (debug.getinfo(2, "S").source):gsub("@", ""):gsub(".lua", "") .. "] " .. table.concat(args, " "))
end

function printf(str, ...)
    oPrint("[" .. (debug.getinfo(2, "S").source):gsub("@", ""):gsub(".lua", "") .. "] " .. string.format(str, ...))
end

function oPrintf(str, ...)
    oPrint(string.format(str, ...))
end

function love.load()
    Config = require("Backend.Config")
    Class = require("Lib.Class")
    Json = require("Lib.Json")
    Timer = require("Lib.Timer")
    Xml = require("Lib.Xml")

    require("Backend")
    require("Funkin")

    Game = Group()
    Game.sound = require "Backend.SoundManager"
    Game.camera = Camera()
    Game.cameras = Group()
    Game.cameras.list = {}
    function Game.cameras:reset(new)
        Game.camera = nil

        while #self.list > 0 do
            self:remove(self.list[1])
        end

        if new == nil then
            new = Camera()
        end

        Game.camera = new
        self:add(new)
        new.ID = 0

        Camera._defaultCameras = {new}
    end
    function Game.cameras:add(camera)
        if not camera:isInstanceOf(Camera) then
            error("Expected a Camera instance")
        end
        table.insert(self.list, camera)
        self:insert(#self.list, camera)
    end
    function Game:switchState(newState)
        for _, member in ipairs(Game.members) do
            if member:isInstanceOf(State) then
                member:destroy()
                self:remove(member)
            end
        end

        newState:create()
        self:add(newState)
    end
    Game.width, Game.height = Config.GameWidth, Config.GameHeight
    table.insert(Camera._defaultCameras, Camera(0, 0, 1280, 720))
    Game:add(Camera._defaultCameras[1])

    SongRegistry:loadEntries()
    StageRegistry:loadEntries()

    Paths.setCurrentLevel("week1")
    local songData = SongRegistry:fetchEntry("bopeebo")
    print(songData)
    songData:cacheCharts()
    local params = {
        targetSong = songData,
        targetDifficulty = "hard"
    }

    Game:switchState(PlayState(params))

    love.audio.setVolume(0.1)
end 

function love.update(dt)
    Game:update(dt)
    Game.sound.update(dt)
    FunkinSound:update(dt)

    -- print the count of all playing sources
    --print("Playing sources: " .. love.audio.getActiveSourceCount())
end

function love.draw()
    Game:draw()
end
