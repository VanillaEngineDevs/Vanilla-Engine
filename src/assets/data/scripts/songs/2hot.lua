local gunCocked = false
local spawnedCans = {}

local spraycan = require("assets.data.scripts.props.spraycan")

function Song:onNoteHit(event)
    if event.noteType == "weekend-1-lightcan" then
    elseif event.noteType == "weekened-1-kickcan" then
        local newCan = spraycan()
        local sprayCanPile = get("spraycanPile")

        newCan.x = sprayCanPile.x + 30
        newCan.y = sprayCanPile.y - 840
        newCan.zIndex = sprayCanPile.zIndex - 1

        add(newCan)
        weeks:sort()
        table.insert(spawnedCans, newCan)
    elseif event.noteType == "weekend-1-kneecan" then
    elseif event.noteType == "weekend-1-cockgun" then
        gunCocked = true
        Timer.after(1, function()
            gunCocked = false
        end)
    elseif event.noteType == "weekend-1-firegun" then
        if gunCocked then
            self:shootNextCan()
        end
    end
end

local STATE_ARCING = 2
local STATE_SHOT = 3
local STATE_IMPACTED = 4

function Song:getNextCanWithState(desiredState)
    for i = 1, #spawnedCans do
        local can = spawnedCans[i]
        local canState = can.currentState

        if canState == desiredState then
            return can
        end
    end
end

local globalColor = {1, 1, 1}
function Song:darkenStageProps()
    globalColor[1] = 17/255
    globalColor[2] = 17/255
    globalColor[3] = 17/255

    Timer.after(1/24, function()
        globalColor[1] = 34/255
        globalColor[2] = 34/255
        globalColor[3] = 34/255

        Timer.tween(1.4, globalColor, {1, 1, 1}, "linear")
    end)
end

function Song:blackenStageProps()
    globalColor[1] = 0
    globalColor[2] = 0
    globalColor[3] = 0

    Timer.after(1, function()
        globalColor[1] = 1
        globalColor[2] = 1
        globalColor[3] = 1
    end)
end

function Song:onUpdate(dt)
    for _, prop in ipairs(weeks:getProps()) do
        if not prop.name then goto continue end
        if globalColor[1] == 0 then
            if prop.name == "bf" then goto continue end
        else
            if prop.name == "bf" or prop.name == "enemy" or prop.name == "gf" then goto continue end
        end

        if table.includes(spawnedCans, prop) then goto continue end

        if prop.zIndex == (getBoyfriend().zIndex - 3) then
            goto continue
        end

        prop.color[1] = globalColor[1]
        prop.color[2] = globalColor[2]
        prop.color[3] = globalColor[3]

        ::continue::
    end
end

local canVibrationPreset = {
    period = 0.1,
    duration = 0.1,
    amplitude = 1,
    sharpness = 1
}

function Song:shootNextCan()
    local can = self:getNextCanWithState(STATE_ARCING)

    if can then
        can.currentState = STATE_SHOT
        can:playCanShot()
    
        Timer.after(1/24, function()
            self:darkenStageProps()

            hapticUtil:vibrateByPreset(canVibrationPreset)
        end)
    end
end

function Song:missNextCan()
    local can = self:getNextCanWithState(STATE_ARCING)
    if can then
        can.currentState = STATE_IMPACTED
    end
end

function Song:spawnImpactParticle()

end

function Song:onNoteMiss(event)
    if event.noteType == "weekend-1-cockgun" then
        event.healthChange = 0
    elseif event.noteType == "weekend-1-firegun" then
        gunCocked = false
        event.healthChange = 0
        self:missNextCan()
        self:takeCanDamage()
    elseif event.noteType == "weekend-1-firegun-hip" then
        gunCocked = false
        event.healthChange = 0
        self:missNextCan()
        self:takeCanDamage()
    elseif event.noteType == "weekend-1-firegun-far" then
        gunCocked = false
        event.healtHChange = 0
        self:missNextCan()
        self:takeCanDamage()
    end
end

local HEALTH_LOSS = 0.25 * 2

function Song:takeCanDamage()
    health = health - HEALTH_LOSS

    if health <= 0 then
        gameoverSubstate.musicSuffix = "-pico-explode"
        gameoverSubstate.blueBallSuffix = "-pico-explode"

        self:blackenStageProps()
    else
        hapticUtil:vibrateByPreset(canVibrationPreset)
        Timer.after(0.45, function()
            hapticUtil:vibrateByPreset(canVibrationPreset)
        end)
    end
end
