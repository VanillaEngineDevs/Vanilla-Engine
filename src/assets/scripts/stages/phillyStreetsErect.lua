local rainShaderIntensity = 0
local rainShaderStartIntensity = 0
local rainShaderEndIntensity = 0

local lightsStop = false
local lastChange = 0
local changeInterval = 0

local carWaiting = false
local carInterruptable = true
local car2Interruptable = true

local car1Tween, car2Tween
local car1TweenAngle, car2TweenAngle

local scrollingSky

local rainDropTimer = 0
local rainDropWait = 6

function Stage:changeLights(beat)
    lastChange = beat
    lightsStop = not lightsStop

    if lightsStop then
        get("phillyTraffic"):play("tored", true, false)
        changeInterval = 20
    else
        get("phillyTraffic"):play("togreen", true, false)
        changeInterval = 30

        if carWaiting then self:finishCarLights(get("phillyCars")) end
    end
end

function Stage:resetCar(left, right)
    if left then
        carWaiting = false
        carInterruptable = true
        local cars = get("phillyCars")
        if car1Tween then 
            Timer.cancel(car1Tween)
            cars.x = 1200
            cars.y = 818
            cars.angle = 0
        end
        if car1TweenAngle then
            Timer.cancel(car1TweenAngle)
            cars.angle = 0
        end
    end

    if right then
        car2Interruptable = true
        local cars2 = get("phillyCars2")
        if car2Tween then
            Timer.cancel(car2Tween)
            cars2.x = 1200
            cars2.y = 818
            cars2.angle = 0
        end
        if car2TweenAngle then
            Timer.cancel(car2TweenAngle)
            cars2.angle = 0
        end
    end
end

function Stage:onCreate()
    print("wtf")
    if love.system.getOS() ~= "NX" then
        shaders["rain"]:send("uScale", 0.0075)
        weeks:setStageShader(shaders["rain"])
        print("Applied rain shader to stage")
    end

    if weeks:getSongID() == "darnell" then
        rainShaderStartIntensity = 0
        rainShaderEndIntensity = 0.1
    elseif weeks:getSongID() == "lit-up" then
        rainShaderStartIntensity = 0.1
        rainShaderEndIntensity = 0.2
    elseif weeks:getSongID() == "2hot" then
        rainShaderStartIntensity = 0.2
        rainShaderEndIntensity = 0.4
    end

    print(weeks:getSongID() .. " rain shader start intensity: " .. rainShaderStartIntensity)
    print("Rain shader start intensity: " .. rainShaderStartIntensity)

    if love.system.getOS() ~= "NX" then
        rainShaderIntensity = rainShaderStartIntensity
        shaders["rain"]:send("uIntensity", rainShaderIntensity)
    end

    self:resetCar(true, true)
    self:resetStageValues()
end

function Stage:build()
    -- scrolling sky shit
end

local function randomFloat(min, max)
    return min + love.math.random() * (max - min)
end

local function tweenQuadPath(sprite, path, duration, options)
    options = options or {}

    local ease = options.ease or "linear"
    local startDelay = options.startDelay or 0
    local onComplete = options.onComplete

    local steps = #path
    if steps == 0 then return end

    local stepDuration = duration / steps
    local stepIndex = 1
    local tweenHandle

    local function doStep()
        if stepIndex > steps then
            if onComplete then onComplete() end
            return
        end

        local target = path[stepIndex]

        tweenHandle = Timer.tween(stepDuration, sprite, {
            x = target.x,
            y = target.y
        }, ease, function()
            stepIndex = stepIndex + 1
            doStep()
        end)
    end

    if startDelay > 0 then
        Timer.after(startDelay, doStep)
    else
        doStep()
    end

    return function()
        if tweenHandle then
            Timer.cancel(tweenHandle)
        end
    end
end

function Stage:finishCarLights(sprite)
    carWaiting = false
    local duration = randomFloat(1.8, 3)
    local rotations = {-5, 18}
    local offset = {306.6, 168.3}
    local startDelay = randomFloat(0.2, 1.2)

    local path = {
        {x = 1950 - offset[0] - 70, y = 980 - offset[1] + 15},
        {x = 2400 - offset[0], y = 980 - offset[1] - 50},
        {x = 3102 - offset[0], y = 1187 - offset[1] + 40},
    }

    for i, point in ipairs(path) do
        path[i].y = point.y + 50
    end


    sprite.angle = math.rad(rotations[1])
    car1TweenAngle = Timer.tween(duration, sprite, {
        angle = math.rad(rotations[rotations[2]])
    }, "in-sine")
    car1Tween = tweenQuadPath(sprite, path, duration, {
        ease = "in-sine",
        startDelay = startDelay,
        onComplete = function()
            carInterruptable = true
        end
    })
end

function Stage:driveCarLights(sprite)
    if not carInterruptable then return end
    carInterruptable = false

    if car1Tween then
        Timer.cancel(car1Tween)
        car1Tween = nil
    end
    if car1TweenAngle then
        Timer.cancel(car1TweenAngle)
        car1TweenAngle = nil
    end

    local variant = love.math.random(1, 4)
    sprite:play("car" .. variant)

    local extraOffset = {0, 0}
    local duration = 2

    if variant == 1 then
        duration = randomFloat(1, 1.7)
    elseif variant == 2 then
        extraOffset = {20, -15}
        duration = randomFloat(0.9, 1.5)
    elseif variant == 3 then
        extraOffset = {30, 50}
        duration = randomFloat(1.5, 2.5)
    elseif variant == 4 then
        extraOffset = {10, 60}
        duration = randomFloat(1.5, 2.5)
    end

    sprite.offset.x = extraOffset[1]
    sprite.offset.y = extraOffset[2]

    local offset = {306.6, 168.3}

    local path = {
        {x = 1500 - offset[1] - 20, y = 1049 - offset[2] - 20},
        {x = 1770 - offset[1] - 80, y =  994 - offset[2] + 10},
        {x = 1950 - offset[1] - 80, y =  980 - offset[2] + 15},
    }

    for i, point in ipairs(path) do
        path[i].y = point.y + 50
    end

    local rotations = {-7, -5}
    sprite.angle = math.rad(rotations[1])
    car1TweenAngle = Timer.tween(duration, sprite, {
        angle = math.rad(rotations[2])
    }, "out-cubic")
    car1Tween = tweenQuadPath(sprite, path, duration, {
        ease = "out-cubic",
        onComplete = function()
            carWaiting = true
            carInterruptable = true

            if not lightsStop then
                self:finishCarLights(get("phillyCars"))
            end
        end
    })
end

function Stage:driveCar(sprite)
    if not carInterruptable then return end
    carInterruptable = false

    if car1Tween then
        Timer.cancel(car1Tween)
        car1Tween = nil
    end
    if car1TweenAngle then
        Timer.cancel(car1TweenAngle)
        car1TweenAngle = nil
    end

    local variant = love.math.random(1, 4)
    sprite:play("car" .. variant)

    local extraOffset = {0, 0}
    local duration = 2

    if variant == 1 then
        duration = randomFloat(1, 1.7)
    elseif variant == 2 then
        extraOffset = {20, -15}
        duration = randomFloat(0.6, 1.2)
    elseif variant == 3 then
        extraOffset = {30, 50}
        duration = randomFloat(1.5, 2.5)
    elseif variant == 4 then
        extraOffset = {10, 60}
        duration = randomFloat(1.5, 2.5)
    end

    sprite.offset.x = extraOffset[1]
    sprite.offset.y = extraOffset[2]

    local offset = {306.6, 168.3}

    local path = {
        {x = 1570 - offset[1], y = 1049 - offset[2] - 30},
        {x = 2400 - offset[1], y =  980 - offset[2] - 50},
        {x = 3102 - offset[1], y = 1187 - offset[2] + 40},
    }

    for i, point in ipairs(path) do
        path[i].y = point.y + 50
    end

    local rotations = {-8, 18}
    sprite.angle = math.rad(rotations[1])
    car1TweenAngle = Timer.tween(duration, sprite, {
        angle = math.rad(rotations[2])
    }, "linear")
    car1Tween = tweenQuadPath(sprite, path, duration, {
        ease = "linear",
        onComplete = function()
            carInterruptable = true
        end
    })
end

function Stage:driveCarBack(sprite)
    if not car2Interruptable then return end
    car2Interruptable = false

    if car2Tween then
        Timer.cancel(car2Tween)
        car2Tween = nil
    end
    if car2TweenAngle then
        Timer.cancel(car2TweenAngle)
        car2TweenAngle = nil
    end

    local variant = love.math.random(1, 4)
    sprite:play("car" .. variant)

    local extraOffset = {0, 0}
    local duration = 2

    if variant == 1 then
        duration = randomFloat(1, 1.7)
    elseif variant == 2 then
        extraOffset = {20, -15}
        duration = randomFloat(0.6, 1.2)
    elseif variant == 3 then
        extraOffset = {30, 50}
        duration = randomFloat(1.5, 2.5)
    elseif variant == 4 then
        extraOffset = {10, 60}
        duration = randomFloat(1.5, 2.5)
    end

    sprite.offset.x = extraOffset[1]
    sprite.offset.y = extraOffset[2]

    local offset = {306.6, 168.3}

    local path = {
        {x = 3102 - offset[1], y = 1127 - offset[2] + 60},
        {x = 2400 - offset[1], y =  980 - offset[2] - 30},
        {x = 1570 - offset[1], y = 1049 - offset[2] - 10},
    }

    for i, point in ipairs(path) do
        path[i].y = point.y + 50
    end
    local rotations = {18, -8}
    sprite.angle = math.rad(rotations[1])
    car2TweenAngle = Timer.tween(duration, sprite, {
        angle = math.rad(rotations[2])
    }, "linear")
    car2Tween = tweenQuadPath(sprite, path, duration, {
        ease = "linear",
        onComplete = function()
            car2Interruptable = true
        end
    })
end

function Stage:resetStageValues()
    lastChange = 0
    changeInterval = 0
    local traffic = get("phillyTraffic")
    if traffic then
        traffic:play("togreen", true, false)
    end
    lightsStop = false
end

local t = 0
local function remap(value, from1, to1, from2, to2)
    return from2 + (value - from1) * (to2 - from2) / (to1 - from1)
end

function Stage:onUpdate(dt)
    if love.system.getOS() ~= "NX" then
        local inst = weeks:getAudio("inst")
        if inst then
            local currentMs = inst:tell("seconds") * 1000
            local totalMs = inst:getDuration("seconds") * 1000

            local remappedIntensityValue = remap(
                currentMs,
                0, totalMs,
                rainShaderStartIntensity,
                rainShaderEndIntensity
            )

            rainShaderIntensity = remappedIntensityValue
            shaders["rain"]:send("uIntensity", rainShaderIntensity)

            t = t + dt
            shaders["rain"]:send("uTime", t)
        end
    end
end

local function randomBool(chance)
    return love.math.random() < (chance / 100)
end

function Stage:onBeatHit(beat)
    if randomBool(10) and beat ~= (lastChange + changeInterval) and carInterruptable then
        if not lightsStop then
            self:driveCar(get("phillyCars"))
        else
            self:driveCarLights(get("phillyCars"))
        end
    end

    if randomBool(10) and beat ~= (lastChange + changeInterval) and car2Interruptable and not lightsStop then
        self:driveCarBack(get("phillyCars2"))
    end

    if beat == (lastChange + changeInterval) then
        self:changeLights(beat)
    end
end

function Stage:onSongRetry()
    self:resetCar(true, true)
    self:resetStageValues()
end

function Stage:addProp(prop, name)
    print(prop, name)
    if name:endsWith("_lightmap") then
        prop.alpha = 0.6
    elseif name == "puddle" then
        if love.system.getOS() ~= "NX" then
            shaders["rain"]:send("uPuddleScaleY", 0.3)
        end
    end
end
