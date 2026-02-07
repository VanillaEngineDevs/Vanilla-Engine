local hasPlayedCutscene = false
local hasPlayedEndCutscene = false

local TankmanGroup = require("assets.data.scripts.props.tankmanSpriteGroup")
local _tankmanGroup

function Song:onCreate()
    if getBoyfriend().id == "pico-playable" then
        weeks:preloadIcon(icon.imagePath("tankman-bloody"))
    end

    hasPlayedCutscene = false
end


function Song:onCountdownStart(event)
    if not hasPlayedCutscene then hasPlayedCutscene = true end

    if not hasPlayedCutscene then
        hasPlayedCutscene = true

        -- event:cancel()

        -- self:startVideo()
    end

    if not _tankmanGroup then
        _tankmanGroup = TankmanGroup(true)
        weeks:add(_tankmanGroup)
    end
end

function Song:onSongRetry()
    if _tankmanGroup then
        _tankmanGroup:reset()
    end
end

local cutsceneTimer = Timer.new()
function Song:onSongEnd(event)
    if not hasPlayedEndCutscene then
        hasPlayedEndCutscene = true
        event:cancel()

        self:startEndCutscene()
    else
        hasPlayedEndCutscene = false
    end
end

function Song:startEndCutscene()
    local bfpoint = getBoyfriend():getCameraPoint()
    local gfpoint = getGirlfriend():getCameraPoint()
    local enemypoint = getEnemy():getCameraPoint()

    weeks.isInCutscene = true
    weeks:hideUI()

    weeks:setClassicMovement(false)
    if camTween then
        Timer.cancel(camTween)
    end

    Timer.tween(2.8, camera, {x = enemypoint.x + 320, y = enemypoint.y - 70}, "out-expo")
    Timer.tween(2, camera, {zoom = 0.65}, "out-expo")

    getEnemy():play("stressPicoEnding", true, false)
    getEnemy().x = getEnemy().x + 190
    getEnemy().y = getEnemy().y + 31
    getEnemy():update(0)

    cutsceneTimer:after(176/24, function()
        getBoyfriend():play("laughEnd", true, false)
    end)

    cutsceneTimer:after(270/24, function()
        Timer.tween(2, camera, {x = enemypoint.x + 320, y = enemypoint.y - 370}, "in-out-quad")
    end)

    cutsceneTimer:after(320/24, function()
        weeks:endSong()
    end)
end

function Song:onUpdate(dt)
    cutsceneTimer:update(dt)
    if weeks.isInCutscene then
        weeks:setClassicMovement(false)
    end
end
