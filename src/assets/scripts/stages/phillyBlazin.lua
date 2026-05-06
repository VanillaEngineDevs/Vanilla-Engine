local cameraInitialized = false
local cameraDarkened = false

local lightningTimer = 3
local lightningActive = true

local rainTimeScale = 1

function Stage:onCreate()
    if love.system.getOS() ~= "NX" then
        shaders["rain"]:send("uScale", 0.0075)
        shaders["rain"]:send("uIntensity", 0.5)
        weeks:setStageShader(shaders["rain"])
        print("Applied rain shader to stage")
    end
end

local t = 0
function Stage:onUpdate(dt)
    if love.system.getOS() ~= "NX" then
        t = t + dt * rainTimeScale
        shaders["rain"]:send("uTime", t)
        rainTimeScale = util.smoothLerp(rainTimeScale, 1.535, dt, 0.02)
    end

    if not cameraInitialized then
        self:initializeCamera()
        cameraInitialized = true
    end

    if lightningActive then
        lightningTimer = lightningTimer - dt
    else
        lightningTimer = 1
    end

    if lightningTimer <= 0 then
        self:applyLightning()
        lightningTimer = love.math.random(7, 15)
    end
end

function Stage:onNoteHit(event)
    rainTimeScale = rainTimeScale + 0.7
end

local function randomBool(chance)
    return love.math.random() < (chance / 100)
end

local lightningSounds = {}
function Stage:applyLightning()
    local lightning = get("lightning")
    local skyAdditive = get("skyAdditive")
    local foregroundMultiply = get("foregroundMultiply")
    local additionalLighten = get("additionalLighten")

    local LIGHTNING_FULL_DURATION = 1.5
    local LIGHTNING_FADE_DURATION = 0.3

    skyAdditive.visible = true
    skyAdditive.alpha = 0.7
    Timer.tween(LIGHTNING_FULL_DURATION, skyAdditive, {alpha = 0}, "linear", function()
        self:cleanupLightning()
    end)

    foregroundMultiply.visible = true
    foregroundMultiply.alpha = 0.64
    Timer.tween(LIGHTNING_FULL_DURATION, foregroundMultiply, {alpha = 0}, "linear")

    additionalLighten.visible = true
    additionalLighten.alpha = 0.3
    Timer.tween(LIGHTNING_FADE_DURATION, additionalLighten, {alpha = 0}, "linear")

    lightning.visible = true
    lightning:play("strike", true, false)

    if randomBool(65) then
        lightning.x = love.math.random(-250, 280)
    else
        lightning.x = love.math.random(780, 900)
    end

    local rnd = love.math.random(1, 3)
    lightningSounds[rnd] = lightningSounds[rnd] or love.audio.newSource(EXTEND_LIBRARY_SFX("weekend1:/Lightning" .. rnd .. ".ogg"), "static")
    audio.playSound(lightningSounds[rnd])

    self:triggerLightningHaptics()
end

function Stage:triggerLightningHaptics()
    hapticUtil:vibrate(0, 0.05, 1)
    doPostShockHaptics = true
end

local doPostShockHaptics = false
local postShockCounter = 0
local counterTargetNum = 10

function Stage:onStepHit(step)
    if doPostShockHaptics then
        postShockCounter = postShockCounter + 1
        local postShockAmplitude = 0.05 * (counterTargetNum - postShockCounter) * 2.5
        print("Post-shock haptics, amplitude: " .. postShockAmplitude)
        hapticUtil:vibrate(0, 0.01, postShockAmplitude, 0)

        if postShockCounter >= counterTargetNum then
            doPostShockHaptics = false
            postShockCounter = 0
        end
    end
end

function Stage:onSongEnd()
    lightningActive = false
end

function Stage:cleanupLightning()
    get("skyAdditive").visible = false
    get("foregroundMultiply").visible = false
    get("additionalLighten").visible = false
    get("lightning").visible = false
end

function Stage:initializeCamera()
    local gfpoint = getGirlfriend():getCameraPoint()
    gfpoint.x = gfpoint.x + 50
    gfpoint.y = gfpoint.y - 90

    weeks:getCamera():forcePos(gfpoint.x, gfpoint.y)
end

function Stage:onSongRetry()
    self:initializeCamera()
end
