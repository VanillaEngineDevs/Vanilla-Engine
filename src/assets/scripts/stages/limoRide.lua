local carSequence
local sequenceTime = 0
local sequenceStep = 0

local doCarHaptics = false

local fastCarCanDrive = false

function Stage:build()
    carSequence = {
        {time = 1, callback = function() doCarHaptics = true end},
        {time = 1.4, callback = function() doCarHaptics = false end},
        {time = 2, callback = function() self:resetFastCar() end}
    }

    self:resetFastCar()
end

function Stage:onUpdate(dt)
    if doCarHaptics then hapticUtil:vibrate(0, 0.05, 0.25, 0) end

    if sequenceStep > 0 then
        sequenceTime = sequenceTime + dt

        while true do
            local step = carSequence[sequenceStep]
            if not step or sequenceTime < step.time then
                break
            end

            step.callback()
            sequenceStep = sequenceStep + 1
        end
    end

    local fastCar = get("fastCar")
    if fastCar then
        fastCar.x = fastCar.x + ((fastCar.velX or 0) * dt)
    end
end

local function randomBool(chance)
    return love.math.random() < (chance / 100)
end

function Stage:onBeatHit(beat)
    if randomBool(10) and fastCarCanDrive then
        self:fastCarDrive()
    end
end

function Stage:resetFastCar()
    local fastCar = get("fastCar")
    if not fastCar then return end

    fastCar.x = -15000
    fastCar.y = love.math.random(140, 250)
    fastCarCanDrive = true
    fastCar.velX = 0
end

local carSound
function Stage:fastCarDrive()
    carSound = carSound or love.audio.newSource(EXTEND_LIBRARY_SFX("week4:carPass"..love.math.random(0,1)..".ogg", true), "stream")
    local fastCar = get("fastCar")
    fastCar.velX = 15000
    fastCarCanDrive = false

    sequenceStep = 1
    sequenceTime = 0
    --[[ carSound:play() ]]
    audio.playSound(carSound)
end

function Stage:onSongRetry()
    self:resetFastCar()
end

function Stage:onCountdownStart(event)
    self:resetFastCar()
end