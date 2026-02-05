local PUPIL_STATE_NORMAL = 0
local PUPIL_STATE_LEFT = 1

local pupilState = PUPIL_STATE_NORMAL

local abot, abotViz, stereoBG, head, speaker

local VULTURE_THRESHOLD = 0.25 * 2

local STATE_DEFAULT = 0
local STATE_PRE_RAISE = 1
local STATE_RAISE = 2
local STATE_READY = 3
local STATE_LOWER = 4

local state = STATE_DEFAULT

local MIN_BLINK_DELAY = 3
local MAX_BLINK_DELAY = 8

local blinkCooldown = MIN_BLINK_DELAY


local animationFinished = false

local refreshed = false

function Character:onCreate()
end

function Character:postCreate()
    self.data.x = self.data.x
    self.data.y = self.data.y - 200

    stereoBG = graphics.newSparrowAtlas()
    stereoBG:load(EXTEND_LIBRARY("shared:characters/abotPixel/aBotPixelBack", false))
    stereoBG.scale.x = 6
    stereoBG.scale.y = 6

    head = graphics.newSparrowAtlas()
    head:load(EXTEND_LIBRARY("shared:characters/abotPixel/abotHead", false))
    head.scale.x = 6
    head.scale.y = 6

    speaker = graphics.newSparrowAtlas()
    speaker:load(EXTEND_LIBRARY("shared:characters/abotPixel/aBotPixelSpeaker", false))
    speaker.scale.x = 6
    speaker.scale.y = 6
    speaker.origin.x = self.data.origin.x
    speaker.origin.y = self.data.origin.y

    abot = graphics.newSparrowAtlas()
    abot:load(EXTEND_LIBRARY("shared:characters/abotPixel/aBotPixelBody", false))
    abot.scale.x = 6
    abot.scale.y = 6
    abot.origin.x = self.data.origin.x
    abot.origin.y = self.data.origin.y

    abot:addAnimByPrefix("danceLeft", "danceLeft", 24, false)
    abot:addAnimByPrefix("danceRight", "danceRight", 24, false)
    abot:addAnimByPrefix("lowerKnife", "return", 24, false)
end

function Character:onSongEvent(event)
    if event.name == "FocusCamera" then
        local char = tonumber(event.value.char or "0") or 0
        if char == 0 and pupilState ~= PUPIL_STATE_NORMAL then
            pupilState = PUPIL_STATE_NORMAL
        elseif char == 1 and pupilState ~= PUPIL_STATE_LEFT then
            pupilState = PUPIL_STATE_LEFT
        end
    end
end

function Character:dance(force)
    if state == STATE_DEFAULT then
        if self.data.hasDanced then
            self.data:play("danceRight", true)
            if abot then abot:play("danceRight", true) end
        else
            self.data:play("danceLeft", true)
            if abot then abot:play("danceLeft", true) end
        end
        self.data.hasDanced = not self.data.hasDanced
    elseif state == STATE_PRE_RAISE then
        self.data:play("danceLeft", false)
        self.data.hasDanced = false
    elseif state == STATE_READY then
        if blinkCooldown == 0 then
            self.data:play("idleKnife", false)
            blinkCooldown = love.math.random(MIN_BLINK_DELAY, MAX_BLINK_DELAY)
        else
            blinkCooldown = blinkCooldown - 1
        end
    elseif state == STATE_LOWER then
        if self.data.sprite.curAnim.name ~= "lowerKnife" then
            self.data:play("lowerKnife", false)
        end
    end
end

function Character:setRefresh(val)
    refreshed = val or false
end

function Character:onUpdate(dt)
    if self:shouldTransitionState() then
        self:transitionState()
    end

    if not refreshed then
        abot.x = self.data.x + 0 - (self.data.offsets[1])
        abot.y = self.data.y + 212 - (self.data.offsets[2])
        abot.zIndex = self.data.zIndex - 10

        stereoBG.x = abot.x+200
        stereoBG.y = abot.y+130
        stereoBG.zIndex = abot.zIndex - 2

        speaker.x = abot.x - 144
        speaker.y = abot.y + 9
        speaker.zIndex = abot.zIndex -3

        head.x = abot.x - 325
        head.y = head.y + 72

        weeks:add(abot)
        weeks:add(stereoBG)
        weeks:add(speaker)
        weeks:add(head)

        weeks:sort()

        refreshed = true
    end
end

function Character:shouldTransitionState()
    if not boyfriend then return true end

    return (boyfriend.id or "") ~= "pico-blazin"
end

function Character:onAnimationFinished(name)
    if state == STATE_RAISE or state == STATE_LOWER then
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

function Character:transitionState()
    if state == STATE_DEFAULT then
        if health <= VULTURE_THRESHOLD then
            state = STATE_PRE_RAISE
        else
            state = STATE_DEFAULT
        end
    elseif state == STATE_PRE_RAISE then
        if health > VULTURE_THRESHOLD then
            state = STATE_DEFAULT
        elseif animationFinished then
            state = STATE_RAISE
            self.data:play("raiseKnife")
            animationFinished = false
        end
    elseif state == STATE_RAISE then
        if animationFinished then
            state = STATE_READY
            animationFinished = false
        end
    elseif state == STATE_READY then
        if health > VULTURE_THRESHOLD then
            state = STATE_LOWER
        end
    elseif state == STATE_LOWER then
        if animationFinished then
            state = STATE_DEFAULT
            animationFinished = false
        end
    else
        state = STATE_DEFAULT
    end
end