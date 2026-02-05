local hasPlayedInGameCutscene = false

local picoPlayer, picoOpponent
local blood
local cig

local playerShoots, explode = false, false
local cutsceneConductor = Conductor.new()
local cutsceneTimer = Timer.new()

local cutsceneMusic

local picoDopplegangerSprite = require("data.scripts.props.picoDopplegangerSprite")

local lightWindow
local lightWindowAlpha = 0
local lightWindowColor = {1, 1, 1}

local trainEnabled = true
local trainMoving = false
local trainFrameTiming = 0
local trainCars = 8
local trainFinishing = false
local trainCooldown = 0

local fadeSpeed = 1

local startedMoving = false

local lightColors = {
    hex2rgb(0xFFB66F43),
    hex2rgb(0xFF329A6D),
    hex2rgb(0xFF932C28),
    hex2rgb(0xFF2663AC),
    hex2rgb(0xFF502D64),
}

local colorShader

function Stage:build()
    trainEnabled = true
    trainSound = love.audio.newSource(EXTEND_LIBRARY_SFX("week3:train_passes.ogg", true), "stream")
    lightWindow = get("lights")

    colorShader = love.graphics.newShader("shaders/adjustColor.glsl")

    colorShader:send("brightness", -5)
    colorShader:send("hue", -26)
    colorShader:send("saturation", -16)

    getEnemy().shader = colorShader
    getBoyfriend().shader = colorShader
    getGirlfriend().shader = colorShader
end

function Stage:onCountdownStart(event)
    if not hasPlayedInGameCutscene and getBoyfriend().id == "pico-playable" then
        hasPlayedInGameCutscene = true
        weeks:hideUI()
        event:cancel()

        self:doppleGangerCutscene()
        print("Starting in-game cutscene...")
    else
        self.hasPlayedInGameCutscene = true
    end
end

local function randomBool(chance)
    return love.math.random() < (chance / 100)
end

function Stage:doppleGangerCutscene()
    weeks.isInCutscene = true
    weeks.mayPauseGame = false

    cutsceneConductor:setBPM(150)

    playerShoots = randomBool(50)
    explode = randomBool(8)

    local cigPos = {}
    local shooterPos = {}

    blood = graphics.newTextureAtlas()
    print(EXTEND_LIBRARY("week3:philly/erect/bloodPool", true))
    blood:load(EXTEND_LIBRARY("week3:philly/erect/bloodPool", true))

    picoPlayer = picoDopplegangerSprite()
    picoOpponent = picoDopplegangerSprite()

    cig = graphics.newSparrowAtlas()

    picoPlayer.x = getBoyfriend().x - 395
    picoPlayer.y = getBoyfriend().y - 85

    picoOpponent.x = getEnemy().x - 362
    picoOpponent.y = getEnemy().y - 73

    picoPlayer.scroll = getBoyfriend().scroll
    picoOpponent.scroll = getEnemy().scroll

    picoPlayer.zIndex = getBoyfriend().zIndex + 1

    if playerShoots then
        picoOpponent.zIndex = picoPlayer.zIndex - 1
        blood.zIndex = picoOpponent.zIndex - 1
        cig.zIndex = getEnemy().zIndex - 2
        cig.flipX = true

        local bfpoint = getBoyfriend():getCameraPoint()
        local enemyPoint = getEnemy():getCameraPoint()

        blood.x = getEnemy().x - 200
        blood.y = getEnemy().y + 400

        cig.x = getBoyfriend().x - 200
        cig.y = getBoyfriend().y + 210

        shooterPos = {bfpoint.x, bfpoint.y}
        cigPos = {enemyPoint.x, enemyPoint.y}
    else
        picoOpponent.zIndex = picoPlayer.zIndex + 1
        blood.zIndex = picoPlayer.zIndex - 1
        cig.zIndex = getEnemy().zIndex - 2

        local bfpoint = getBoyfriend():getCameraPoint()
        local enemyPoint = getEnemy():getCameraPoint()

        blood.x = getEnemy().x + 500
        blood.y = getEnemy().y + 400

        cig.x = getBoyfriend().x - 478.5
        cig.y = getBoyfriend().y + 205

        shooterPos = {bfpoint.x, bfpoint.y}
        cigPos = {enemyPoint.x, enemyPoint.y}
    end

    local midpoint = {(shooterPos[1] + cigPos[1]) / 2, (shooterPos[2] + cigPos[2]) / 2 - 50}
    cig:load(EXTEND_LIBRARY("week3:philly/erect/cigarette", false))
    cig:addAnimByPrefix("cigarette spit", "cigarette spit", 24, false)
    cig.visible = false

    add(cig)
    add(picoPlayer)
    add(picoOpponent)
    add(blood)
    weeks:sort()

    getBoyfriend().visible = false
    getEnemy().visible = false

    if explode then
        cutsceneMusic = love.audio.newSource(EXTEND_LIBRARY_MUSIC("week3:cutscene/cutscene2.ogg", true), "stream")
    else
        cutsceneMusic = love.audio.newSource(EXTEND_LIBRARY_MUSIC("week3:cutscene/cutscene.ogg", true), "stream")
    end
    cutsceneMusic:play()

    picoPlayer:doAnim("Player", playerShoots, explode, cutsceneTimer)
    picoOpponent:doAnim("Opponent", not playerShoots, explode, cutsceneTimer)

    picoPlayer.shader = getBoyfriend().shader
    picoOpponent.shader = getEnemy().shader

    IS_CLASSIC_MOVEMENT = true
    CAM_LERP_POINT.x = midpoint[1]
    CAM_LERP_POINT.y = midpoint[2]

    cutsceneTimer:after(4, function()
        CAM_LERP_POINT.x = cigPos[1]
        CAM_LERP_POINT.y = cigPos[2]
    end)

    cutsceneTimer:after(6.3, function()
        CAM_LERP_POINT.x = shooterPos[1]
        CAM_LERP_POINT.y = shooterPos[2]
    end)

    cutsceneTimer:after(8.75, function()
        cutsceneSkipped = true
        canSkipCutscene = false
        CAM_LERP_POINT.x = cigPos[1]
        CAM_LERP_POINT.y = cigPos[2]
        if explode then getGirlfriend():play("drop70", true, false) end
    end)

    cutsceneTimer:after(11.2, function()
    end)

    cutsceneTimer:after(11.5, function()
        cig.visible = true
        cig:play("cigarette spit", true, false)
    end)

    cutsceneTimer:after(13, function()
        if explode then
            if playerShoots then
                weeks:removeAudio("enemy")
                picoPlayer.visible = false
                getBoyfriend().visible = true
                weeks:performCountdown()
                for i = 1, 4 do
                    enemyArrows[i].visible = false
                    HoldCover:hide(i, 2)
                    for j = 1, #enemyNotes[i] do
                        enemyNotes[i][j].visible = false
                    end
                end
                weeks:showUI()
            else
                picoOpponent.visible = false
                getEnemy().visible = true

                Timer.after(1, function()
                    graphics:fadeOutWipe(1, function()
                        Gamestate.switch(resultsScreen, {
                            diff = string.lower(CURDIFF or "normal"),
                            song = not storyMode and SONGNAME or weekDesc[weekNum],
                            artist = not storyMode and ARTIST or nil,
                            scores = {
                                sickCount = 0,
                                goodCount = 0,
                                badCount = 0,
                                shitCount = 0,
                                missedCount = 0,
                                maxCombo = 0,
                                score = 0
                            }
                        })
                    end)
                end)
            end
        else
            weeks.isInCutscene = false
            weeks.mayPauseGame = true
            picoPlayer.visible = false
            picoOpponent.visible = false
            getBoyfriend().visible = true
            getEnemy().visible = true
            weeks:performCountdown()
            weeks:showUI()
        end

        hasPlayedInGameCutscene = true
        cutsceneMusic:stop()
    end)
end

function Stage:onUpdate(dt)
    cutsceneTimer:update(dt)
    cutsceneConductor:update(dt, true)
    if cutsceneConductor.onBeat then
        self:onCutsceneBeat(cutsceneConductor.curBeat)
    end

    if not lightWindow then return end
    fadeSpeed = (weeks.conductor:getBeatLengthsMS() / 1000) * dt * 1.5
    lightWindowAlpha = lightWindowAlpha - fadeSpeed
    lightWindow.alpha = lightWindowAlpha

    if trainEnabled and trainMoving then
        trainFrameTiming = trainFrameTiming + dt
        if trainFrameTiming >= 1/24 then
            self:updateTrainPos()
            trainFrameTiming = 0
        end
    end
end

function Stage:onBeatHit(beat)
    if trainEnabled then
        if not trainMoving then trainCooldown = trainCooldown + 1 end

        if beat % 8 == 4 and randomBool(30) and not trainMoving and trainCooldown > 8 then
            trainCooldown = love.math.random(-4, 0)
            self:trainStart()
        end
    end

    if beat % 4 == 0 then
        lightWindowAlpha = 1
        lightWindowColor = lightColors[love.math.random(1, #lightColors)]
        lightWindow.colour = lightWindowColor
        lightWindow.alpha = 1
    end
end

function Stage:onStepHit(step)
    if trainEnabled and trainSound:tell("seconds") >= 4.7 and trainMoving then
        hapticUtil:vibrate(0, 0.1, 0.75, 0)
    end
end

function Stage:onSongEnd(event)
    trainMoving = false
    trainEnabled = false
    if trainSound then
        trainSound:stop()
        trainSound = nil
    end
end

function Stage:trainStart()
    trainMoving = true
    --[[ trainSound:play() ]]
    audio.playSound(trainSound)
end

function Stage:updateTrainPos()
    if trainSound:tell("seconds") >= 4.7 then
        startedMoving = true
        if getGirlfriend().id == "nene" then
            getGirlfriend():call("setTrainPassing", true)
        else
            getGirlfriend():play("hairBlow")
        end
    end

    if startedMoving then
        local train = get("train")
        train.x = train.x - 400

        if train.x < -2000 and not trainFinishing then
            train.x = -1150
            trainCars = trainCars - 1

            if trainCars <= 0 then
                trainFinishing = true
            end
        end

        if train.x < -4000 and trainFinishing then
            self:trainReset()
        end
    end
end

function Stage:trainReset()
    if getGirlfriend().id == "nene" then
            getGirlfriend():call("setTrainPassing", false)
        else
            getGirlfriend():play("hairFall")
        end
    get("train").x = 1280 + 200

    trainMoving = false
    trainCars = 8
    trainFinishing = false
    startedMoving = false
end

function Stage:onSongRetry()
    self:trainReset()
end


function Stage:onCutsceneBeat(beat)
    if getGirlfriend().sprite.animFinished then
        getGirlfriend():dance(true)
    end
end