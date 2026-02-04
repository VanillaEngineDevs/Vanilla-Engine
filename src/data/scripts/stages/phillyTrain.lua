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
    hex2rgb(0xFF31A2FD),
    hex2rgb(0xFF31FD8C),
    hex2rgb(0xFFFB33F5),
    hex2rgb(0xFFFBA633),
    hex2rgb(0xFFFD4531),
}

function Stage:build()
    trainEnabled = true
    trainSound = love.audio.newSource(EXTEND_LIBRARY_SFX("week3:train_passes.ogg", true), "stream")
    lightWindow = get("lights")
end

function Stage:onUpdate(dt)
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

local function randomBool(chance)
    return love.math.random() < (chance / 100)
end

function Stage:onBeatHit(beat)
    if trainEnabled then
        if not trainMoving then trainCooldown = trainCooldown + 1 end

        print(beat % 8, trainMoving, trainCooldown)
        if beat % 8 == 4 and randomBool(30) and not trainMoving and trainCooldown > 8 then
            trainCooldown = love.math.random(-4, 0)
            self:trainStart()
        end
    end

    if beat % 4 == 0 then
        lightWindowAlpha = 1
        lightWindowColor = lightColors[love.math.random(1, #lightColors)]
        lightWindow.colour = lightWindowColor
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
        getGirlfriend():play("hairBlow")
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
    getGirlfriend():play("hairFall")
    get("train").x = 1280 + 200

    trainMoving = false
    trainCars = 8
    trainFinishing = false
    startedMoving = false
end

function Stage:onSongRetry()
    self:trainReset()
end
