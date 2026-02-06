local lightningStrikeBeat = 0
local lightningStrikeOffset = 8

local sounds = {}
function Stage:onCreate()

    for i = 1, 2 do
        sounds["thunder_" .. i] = love.audio.newSource(EXTEND_LIBRARY_SFX("week2:thunder_" .. i .. ".ogg"), "static")
    end
end

function Stage:build()
    get("bgLight").alpha = 0
    get("stairsLight").alpha = 0
end

function Stage:onUpdate(dt)
end

local tweenedAlphas = {
    girlfriend = 1,
    boyfriend = 1,
    enemy = 1,
    bgLight = 0,
    stairsLight = 0
}

function Stage:doLightningStrike(playSound, beat)
    if not getGirlfriend() and not getBoyfriend() and not getEnemy() then return end

    if playSound then
        audio.playSound(sounds["thunder_" .. love.math.random(1, 2)])
    end

    get("bgLight").alpha = 1
    get("stairsLight").alpha = 1
    getBoyfriend():call("setAlpha", 0)
    getGirlfriend():call("setAlpha", 0)
    getEnemy():call("setAlpha", 0)

    Timer.after(0.06, function()
        get("bgLight").alpha = 0
        get("stairsLight").alpha = 0
        --[[ getBoyfriend():call("setAlpha", 1)
        getGirlfriend():call("setAlpha", 1)
        getEnemy():call("setAlpha", 1) ]]
        tweenedAlphas.boyfriend = 1
        tweenedAlphas.girlfriend = 1
        tweenedAlphas.enemy = 1
    end)

    Timer.after(0.12, function()
        --[[getNamedProp('bgLight').alpha = 1;
        getNamedProp('stairsLight').alpha = 1;
        getBoyfriend().alpha = 0;
        getDad().alpha = 0;
        getGirlfriend().alpha = 0;
        FlxTween.tween(getNamedProp('bgLight'), {alpha: 0}, 1.5);
        FlxTween.tween(getNamedProp('stairsLight'), {alpha: 0}, 1.5);
        FlxTween.tween(getBoyfriend(), {alpha: 1}, 1.5);
        FlxTween.tween(getDad(), {alpha: 1}, 1.5);
        FlxTween.tween(getGirlfriend(), {alpha: 1}, 1.5);]]
        get("bgLight").alpha = 1
        get("stairsLight").alpha = 1
        tweenedAlphas.boyfriend = 0
        tweenedAlphas.girlfriend = 0
        tweenedAlphas.enemy = 0
        Timer.tween(1.5, tweenedAlphas, {boyfriend = 1, girlfriend = 1, enemy = 1, bgLight = 0, stairsLight = 0})
    end)

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

function Stage:onUpdate(dt)
    if getBoyfriend() then getBoyfriend():call("setAlpha", tweenedAlphas.boyfriend) end
    if getGirlfriend() then getGirlfriend():call("setAlpha", tweenedAlphas.girlfriend) end
    if getEnemy() then getEnemy():call("setAlpha", tweenedAlphas.enemy) end
    get("bgLight").alpha = tweenedAlphas.bgLight
    get("stairsLight").alpha = tweenedAlphas.stairsLight
end
