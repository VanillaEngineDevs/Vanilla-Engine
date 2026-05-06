local PUPIL_STATE_NORMAL = 0
local PUPIL_STATE_LEFT = 1

local pupilState = PUPIL_STATE_NORMAL

local abot, abotViz, stereoBG, eyeWhites, pupil

local VULTURE_THRESHOLD = 0.25 * 2

local STATE_DEFAULT = 0
local STATE_PRE_RAISE = 1
local STATE_RAISE = 2
local STATE_READY = 3
local STATE_LOWER = 4
local STATE_HAIR_BLOWING = 5
local STATE_HAIR_FALLING = 6
local STATE_HAIR_BLOWING_RAISE = 7
local STATE_HAIR_FALLING_RAISE = 8

local state = STATE_DEFAULT

local MIN_BLINK_DELAY = 3
local MAX_BLINK_DELAY = 8

local blinkCooldown = MIN_BLINK_DELAY

local trainPassing = false

local animationFinished = false

local refreshed = false

function Character:setRefreshed(v)
    refreshed = v
end

function Character:onCreate()
end

function Character:setTrainPassing(passing)
    trainPassing = passing
end

function Character:postCreate()
    self.data.x = self.data.x + 300
    self.data.y = self.data.y + 60

    stereoBG = graphics.newSparrowAtlas()
    stereoBG:load(EXTEND_LIBRARY("shared:characters/abot/stereoBG", false))
    eyeWhites = graphics.newSparrowAtlas()
    eyeWhites:load("#FFFFFF")
    eyeWhites.scale.x = 120
    eyeWhites.scale.y = 60

    pupil = graphics.newTextureAtlas()
    pupil:load(EXTEND_LIBRARY("shared:characters/abot/systemEyes", true))
    pupil.x = self.data.x
    pupil.y = self.data.y
    pupil.zIndex = self.data.zIndex - 5
    pupil:playSymbol("", true, false, 18)
    pupil.onFrameChange:connect(function(_, frameNumber, _)
        if frameNumber == 17 then
            pupil:pause()
        end
    end)
    pupil.onAnimationFinished:connect(function(name)
        pupil:pause()
    end)

    abot = graphics.newTextureAtlas()
    abot:load(EXTEND_LIBRARY("shared:characters/abot/abotSystem", true))

    abot:playSymbol("", true, false, 1)
end

function Character:onSongEvent(event)
    if event.name == "FocusCamera" then
        local char = tonumber(event.value.char or "0") or 0
        if char == 0 and pupilState ~= PUPIL_STATE_NORMAL then
            pupil:playSymbol("", true, false, 17) -- look right
            pupilState = PUPIL_STATE_NORMAL
        elseif char == 1 and pupilState ~= PUPIL_STATE_LEFT then
            pupil:playSymbol("", true, false, 0) -- look left
            pupilState = PUPIL_STATE_LEFT
        end
    end
end

function Character:dance(force)
    if abot then
        abot:playSymbol("", true, false, 1)
    end

    if state == STATE_DEFAULT then
        if self.data.hasDanced then
            self.data:play("danceRight", force, false)
        else
            self.data:play("danceLeft", force, false)
        end
        self.data.hasDanced = not self.data.hasDanced
    elseif state == STATE_PRE_RAISE then
        self.data:play("danceLeft", false, false)
        self.data.hasDanced = false
    elseif state == STATE_READY then
        if blinkCooldown == 0 then
            self.data:play("idleKnife", false, false)
            blinkCooldown = love.math.random(MIN_BLINK_DELAY, MAX_BLINK_DELAY)
        else
            blinkCooldown = blinkCooldown - 1
        end
    elseif state == STATE_LOWER then
        if self.data.sprite.curAnim.name ~= "lowerKnife" then
            self.data:play("lowerKnife", false, false)
        end
    end
end

function Character:onUpdate(dt)
    if self:shouldTransitionState() then
        self:transitionState()
    end

    if not refreshed then
        abot.x = self.data.x - 290 - (-self.data.offsets[1])
        abot.y = self.data.y + 175 - (-self.data.offsets[2])
        abot.zIndex = self.data.zIndex - 10
        weeks:add(abot)

        -- abotViz

        eyeWhites.x = abot.x + 40
        eyeWhites.y = abot.y + 250
        eyeWhites.zIndex = abot.zIndex - 10
        weeks:add(eyeWhites)

        pupil.x = abot.x + 60
        pupil.y = abot.y + 238
        pupil.zIndex = eyeWhites.zIndex + 5
        weeks:add(pupil)

        stereoBG.x = abot.x + 150
        stereoBG.y = abot.y + 30
        stereoBG.zIndex = eyeWhites.zIndex - 8
        weeks:add(stereoBG)

        abot.shader = self.data.shader
        eyeWhites.shader = self.data.shader
        pupil.shader = self.data.shader
        stereoBG.shader = self.data.shader

        weeks:sort()

        refreshed = true
    end
end

function Character:shouldTransitionState()
    if not boyfriend then return true end

    return (boyfriend.id or "") ~= "pico-blazin"
end

function Character:onAnimationFinished(name)
    if state == STATE_RAISE or state == STATE_LOWER or state == STATE_HAIR_BLOWING or state == STATE_HAIR_FALLING or state == STATE_HAIR_BLOWING_RAISE or state == STATE_HAIR_FALLING_RAISE then
        animationFinished = true
    end
end

function Character:onAnimationFrame(name, frameNumber, _)
    if state == STATE_PRE_RAISE then
        if name == "danceLeft" and frameNumber == 13 then
            animationFinished = true
            self:transitionState()
        end
    end
end

function Character:checkTrainPassing(raised)
    if not trainPassing then return end

    if raised then
        state = STATE_HAIR_BLOWING_RAISE
        self.data:play("hairBlowKnife", true, false)
        animationFinished = false
    else
        state = STATE_HAIR_BLOWING
        self.data:play("hairBlow", true, false)
        animationFinished = false
    end
end

function Character:transitionState()
    if state == STATE_DEFAULT then
        if health <= VULTURE_THRESHOLD then
            state = STATE_PRE_RAISE
        else
            state = STATE_DEFAULT
        end
        self:checkTrainPassing()
    elseif state == STATE_PRE_RAISE then
        if health > VULTURE_THRESHOLD then
            state = STATE_DEFAULT
        elseif animationFinished then
            state = STATE_RAISE
            self.data:play("raiseKnife", true, false)
            animationFinished = false
        end
        self:checkTrainPassing()
    elseif state == STATE_RAISE then
        if animationFinished then
            state = STATE_READY
            animationFinished = false
        end
        self:checkTrainPassing(true)
    elseif state == STATE_READY then
        if health > VULTURE_THRESHOLD then
            state = STATE_LOWER
        end
        self:checkTrainPassing(true)
    elseif state == STATE_LOWER then
        if animationFinished then
            state = STATE_DEFAULT
            animationFinished = false
        end
        self:checkTrainPassing()
    elseif state == STATE_HAIR_BLOWING then
        if not trainPassing then
            state = STATE_HAIR_FALLING
            self.data:play("hairFallNormal", true, false)
            animationFinished = false
        elseif animationFinished then
            self.data:play("hairBlowNormal", true, false)
            animationFinished = false
        end
    elseif state == STATE_HAIR_FALLING then
        if animationFinished then
            state = STATE_DEFAULT
            animationFinished = false
        end
    elseif state == STATE_HAIR_BLOWING_RAISE then
        if not trainPassing then
            state = STATE_HAIR_FALLING_RAISE
            self.data:play("hairFallKnife", true, false)
            animationFinished = false
        elseif animationFinished then
            self.data:play("hairBlowKnife", true, false)
            animationFinished = false
        end
    elseif state == STATE_HAIR_FALLING_RAISE then
        if animationFinished then
            state = STATE_READY
            animationFinished = false
        end
    else
        state = STATE_DEFAULT
    end
end