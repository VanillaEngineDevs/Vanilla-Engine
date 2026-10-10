local lightningStrikeBeat = 0
local lightningStrikeOffset = 8

local sounds = {}
function Stage:onCreate()
    for i = 1, 2 do
        sounds["thunder_" .. i] = love.audio.newSource(EXTEND_LIBRARY_SFX("week2:thunder_" .. i .. ".ogg"), "static")
    end
end

function Stage:doLightningStrike(playSound, beat)
    if not getGirlfriend() and not getBoyfriend() and not getEnemy() then return end

    if playSound then
        audio.playSound(sounds["thunder_" .. love.math.random(1, 2)])
    end

    get("halloweenBG"):play("lightning", false, false)

    lightningStrikeBeat = beat
    lightningStrikeOffset = love.math.random(8, 24)

    if getBoyfriend():hasAnimation("scared") and getBoyfriend().sprite.curAnim.name ~= "cheer" then
        getBoyfriend():play("scared")
    end

    if getGirlfriend():hasAnimation("scared") then
        getGirlfriend():play("scared")
    end

    self:triggerLightningHaptics()
end

local doPostShockHaptics = false
function Stage:triggerLightningHaptics()
    hapticUtil:vibrate(0, 0.05, 1)

    doPostShockHaptics = true
end

local function randomBool(chance)
    return love.math.random() < (chance / 100)
end

function Stage:onBeatHit(beat)
    if beat == 4 and weeks:getSongID() == "spookeez" then
        self:doLightningStrike(false, beat)
    end

    if randomBool(10) and beat > lightningStrikeBeat + lightningStrikeOffset then
        self:doLightningStrike(true, beat)
    end
end

local postShockCounter = 0
local counterTargetNum = 10

function Stage:onStepHit(step)
    if doPostShockHaptics then
        postShockCounter = postShockCounter + 1

        local postShockAmplitude = 0.05 * (counterTargetNum - postShockCounter) * 2.5
        hapticUtil:vibrate(0, 0.01, postShockAmplitude, 0)

        if postShockCounter >= counterTargetNum then
            doPostShockHaptics = false
            postShockCounter = 0
        end
    end
end

function Stage:onSongRetry()
    lightningStrikeBeat = 0
    lightningStrikeOffset = 8
end
