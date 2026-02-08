local yunjin, chaewon, eunchae

local dust1, dust2, dust3, dust4

local lightsColors = {}
local lightsDurations = {}
local lightsIntensities = {}

local baseVisible = {true, false, false, false, false}
local baseVisible = {true, true, true, true, true}
local baseSinging = {false, false, false, false, false, false}

local lightsEnabled = false
local THEFUCKINGENEMYVISIBILITY = false

local backLightColorTween = {
    backLightColorAlphaTween = nil,
    backLightColorAlpha = 0
}
local backLightWhiteTween = {
    backLightWhiteAlphaTween = nil,
    backLightWhiteAlpha = 0
}

local characterShaderTween = {
    darkenAmtTween = nil,
    darkenAmt = 0
}
local stageShaderTween = {
    darkenAmtTween = nil,
    darkenAmt = 0
}

local truckLight1Tween = {
    truckLight1StengthTween = nil,
    truckLight1Strength = 0
}
local truckLight2Tween = {
    truckLight2StengthTween = nil,
    truckLight2Strength = 0
}

local characterShader
local stageShader

function Stage:build()
    characterShader = love.graphics.newShader("assets/shaders/sserafimShader.glsl")
    characterShader:send("isChar", true)
    stageShader = love.graphics.newShader("assets/shaders/sserafimShader.glsl")
    yunjin = Character.getCharacter("sserafim-yunjin")
    chaewon = Character.getCharacter("sserafim-chaewon")
    eunchae = Character.getCharacter("sserafim-eunchae")

    yunjin.characterType = CHARACTER_TYPE.OTHER
    chaewon.characterType = CHARACTER_TYPE.OTHER
    eunchae.characterType = CHARACTER_TYPE.OTHER

    yunjin.zIndex = 1000
    chaewon.zIndex = 1000
    eunchae.zIndex = 1000

    yunjin.scroll.x = 0.95
    yunjin.scroll.y = 0.95

    chaewon.scroll.x = 0.95
    chaewon.scroll.y = 0.95

    eunchae.scroll.x = 0.97
    eunchae.scroll.y = 0.97

    add(yunjin)
    add(chaewon)
    add(eunchae)

    -- the one i nthe truck
    yunjin.x = -1194
    yunjin.y = -952
    yunjin.danceEvery = 0

    -- ORANMGE HAIR
    chaewon.x = -75
    chaewon.y = -1010

    -- blue ahir
    eunchae.x = -15
    eunchae.y = -230

    self:setGirlsVisible(baseVisible)
    self:setGirlsSinging(baseSinging)
    self:setLightState(false)

    doorKick1 = love.audio.newSource("assets/sserafim/sounds/doorKick1.ogg", "static")
    doorKick2 = love.audio.newSource("assets/sserafim/sounds/doorKick2.ogg", "static")

    for i = 1, #enemyArrows do
        enemyArrows[i].visible = false
        for j = 1, #enemyNotes[i] do
            enemyNotes[i][j].visible = false
        end
    end
end

function Stage:onUpdate(dt)
    characterShader:send("darkAmt", characterShaderTween.darkenAmt)
    stageShader:send("darkAmt", stageShaderTween.darkenAmt)
    characterShader:send("truckStrength", weeks:get("truckLight1").alpha)
    stageShader:send("truckStrength", weeks:get("truckLight1").alpha)
    characterShader:send("pulseStrength", weeks:get("backLightColor").alpha)
    stageShader:send("pulseStrength", weeks:get("backLightColor").alpha)

    getGirlfriend().visible = true
    getEnemy().visible = THEFUCKINGENEMYVISIBILITY
end

function Stage:onSongEvent(event)
    if event.name == "sserafimSing" then
        self:setGirlsSinging(event.value.singing)
    elseif event.name == "sserafimShow" then
        self:setGirlsVisible(event.value.visible)
    elseif event.name == "sserafimGuitarVibration" then
        hapticUtil:increasingVibrate(0.25, 1/2, event.value.duration)
    elseif event.name == "sserafimDark" then
        self:setDarkenAmt(event.value.amount, event.value.duration)
    elseif event.name == "sserafimLights" then
        self:flashTruckLights(event.value.amount, event.value.duration)
    elseif event.name == "sserafimCover" then
        self:setCoverVisible(event.value.visible)
    elseif event.name == "sserafimFlash" then
        weeks:flash(event.value.duration)
    elseif event.name == "sserafimPulseLights" then
        self:setLightState(event.value.enabled, event.value.colors, event.value.durations, event.value.intensities)
    elseif event.name == "sserafimKick" then
        self:kickTruck(event.value.final)
    end
end

function Stage:setGirlsVisible(visible)
    --visible = {false, false, false, false, true}
    if #visible < 5 then
        print("Got " .. #visible .. " visibility values, expected 5.")
        return
    end

    yunjin.visible = visible[1]
    THEFUCKINGENEMYVISIBILITY = visible[2]
    getEnemy().visible = visible[2]
    chaewon.visible = visible[3]
    eunchae.visible = visible[4]
    getBoyfriend().visible = visible[5]
end

function Stage:setGirlsSinging(singing)
    if #singing < 6 then
        print("Got " .. #singing .. " singing values, expected 6.")
        return
    end

    yunjin.characterType = singing[1] and CHARACTER_TYPE.BF or CHARACTER_TYPE.DAD
    getEnemy().characterType = singing[2] and CHARACTER_TYPE.BF or CHARACTER_TYPE.DAD
    chaewon.characterType = singing[3] and CHARACTER_TYPE.BF or CHARACTER_TYPE.DAD
    eunchae.characterType = singing[4] and CHARACTER_TYPE.BF or CHARACTER_TYPE.DAD
    getBoyfriend().characterType = singing[5] and CHARACTER_TYPE.BF or CHARACTER_TYPE.DAD
    getGirlfriend().characterType = singing[6] and CHARACTER_TYPE.BF or CHARACTER_TYPE.DAD
end

function Stage:setDarkenAmt(amount, duration)
    if characterShaderTween.darkenAmtTween then
        Timer.cancel(characterShaderTween.darkenAmtTween)
    end
    if stageShaderTween.darkenAmtTween then
        Timer.cancel(stageShaderTween.darkenAmtTween)
    end

    characterShaderTween.darkenAmtTween = Timer.tween(duration, characterShaderTween, {darkenAmt = amount}, 'in-out-sine', function()
        characterShaderTween.darkenAmtTween = nil
    end)
    stageShaderTween.darkenAmtTween = Timer.tween(duration, stageShaderTween, {darkenAmt = amount}, 'in-out-sine', function()
        stageShaderTween.darkenAmtTween = nil
    end)
end

function Stage:flashTruckLights(amount, duration)
    if truckLight1Tween.truckLight1StengthTween then
        Timer.cancel(truckLight1Tween.truckLight1StengthTween)
    end
    if truckLight2Tween.truckLight2StengthTween then
        Timer.cancel(truckLight2Tween.truckLight2StengthTween)
    end

    hapticUtil:vibrate(0, duration / 2, amount / 2)

    weeks:get("truckLight1").alpha = amount
    weeks:get("truckLight2").alpha = amount

    characterShader:send("truckStrength", amount)
    stageShader:send("truckStrength", amount)

    truckLight1Tween.truckLight1StengthTween = Timer.tween(duration, weeks:get("truckLight1"), {alpha = 0}, 'in-out-cubic', function()
        characterShader:send("truckStrength", 0)
        stageShader:send("truckStrength", 0)
        truckLight1Tween.truckLight1StengthTween = nil
    end)
    truckLight2Tween.truckLight2StengthTween = Timer.tween(duration, weeks:get("truckLight2"), {alpha = 0}, 'in-out-cubic')
end

function Stage:flashBackLight(amt, duration, color)
    if backLightColorTween.backLightColorAlphaTween then
        Timer.cancel(backLightColorTween.backLightColorAlphaTween)
    end
    if backLightWhiteTween.backLightWhiteAlphaTween then
        Timer.cancel(backLightWhiteTween.backLightWhiteAlphaTween)
    end

    weeks:get("backLightColor").color = color

    weeks:get("backLightColor").alpha = amt * 0.8
    weeks:get("backLightWhite").alpha = amt * 0.7

    characterShader:send("lightColor", color)
    stageShader:send("lightColor", color)

    characterShader:send("pulseStrength", weeks:get("backLightColor").alpha)
    stageShader:send("pulseStrength", weeks:get("backLightColor").alpha)

    backLightColorTween.backLightColorAlphaTween = Timer.tween(duration, weeks:get("backLightColor"), {alpha = 0}, 'in-out-cubic', function()
        characterShader:send("pulseStrength", 0)
        stageShader:send("pulseStrength", 0)
        backLightColorTween.backLightColorAlphaTween = nil
    end)
end

function Stage:setCoverVisible(visible)
    weeks:get("solidCover").visible = visible
end

function Stage:setLightState(enabled, colors, durations, intensities)
    lightsEnabled = enabled
    if colors == nil or durations == nil or intensities == nil then
        return
    end
    lightsColors = {}
    for i = 1, #colors do
        table.insert(lightsColors, hex2rgb(colors[i]))
    end
    lightsDurations = durations
    lightsIntensities = intensities
end

function Stage:kickTruck(final)
    if final then
        yunjin:play("kick2", true, false)
        doorKick2:play()
        yunjin.danceEvery = 1

        hapticUtil:vibrate(0, 0.2, 0.8, 0)
    else
        yunjin:play("kick1", true, false)
        doorKick1:play()

        hapticUtil:vibrate(0, 0.2, 0.4, 0)
    end
end

function Stage:addProp(prop, name)
    prop.shader = stageShader
    print("Added prop " .. name .. " with shader " .. tostring(prop.shader))

    -- TODO: BLENDMODES!!!!
    if name == "truckLight1" then
        prop.shader = nil
        --prop.blend=12
        --prop.visible = false
    elseif name == "truckLight2" then
        prop.shader = nil
    elseif name == "backLightColor" then
        prop.shader = nil
        --prop.blend=12
        --prop.visible = false
        prop.color = hex2rgb(0xFFCC3300)
    elseif name == "backLightWhite" then
        prop.shader = nil
        --prop.visible = false
        --prop.blend=0
    elseif name == "truckTest" then
        prop.shader = nil
    elseif name == "solidCover" then
        prop.shader = nil
    elseif name == "truckDoor" then
        prop.visible = false
    elseif name == "solidCover" then
        prop.visible = false
    elseif name == "solid" then
        prop.visible = false
    end
end

function Stage:addCharacter(char, name)
    local targetIndex = 1
    if name == "sserafim-yunjin" then
        targetIndex = 1
    elseif name == "sserafim-chaewon" then
        targetIndex = 3
    elseif name == "sserafim-eunchae" then
        targetIndex = 4
    elseif name == "sserafim-sakura" then
        targetIndex = 5
    elseif name == "sserafim-gf" then
        targetIndex = 6
    end

    char.characterType = baseSinging[targetIndex] and CHARACTER_TYPE.BF or CHARACTER_TYPE.DAD
    char.visible = baseVisible[targetIndex]
    char.shader = characterShader
end

function Stage:onBeatHit(beat)
    if lightsEnabled then
        self:flashBackLight(lightsIntensities[beat % #lightsIntensities + 1], lightsDurations[beat % #lightsDurations + 1], lightsColors[beat % #lightsColors + 1])
    end
end
