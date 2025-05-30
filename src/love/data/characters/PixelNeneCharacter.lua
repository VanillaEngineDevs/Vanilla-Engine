local Nene = BaseCharacter:extend()

ABOT_IMAGE = nil
local abotVisualizers = {}
local MAX_ABOT_VIZ = 7
local VIS_TIME_MAX = 0.033333333333333333
local deltaCurTime = 0
local vizFrameWidth = 0

function Nene:new()
    self.abotHead = love.filesystem.load("sprites/characters/abot/abotHead.lua")()
    self.abot = love.filesystem.load("sprites/characters/abot/abotPixel.lua")()
    self.abotBody = love.filesystem.load("sprites/characters/abot/abotPixelBody.lua")()
    self.abotSpeaker = love.filesystem.load("sprites/characters/abot/abotPixelSpeaker.lua")()
    self.abotBack = graphics.newImage(graphics.imagePath("characters/pixel/aBotPixelBack"))
    self.soundData = nil
    self.bars = {0, 0, 0, 0, 0, 0, 0}

    abotVisualizers = {}
    local path = "sprites/characters/nene-pixel.lua"
    BaseCharacter.new(self, path)

    self.name = "nene"
    self.isPixel = true

    self.STATE_DEFAULT = 0
    self.STATE_PRE_RAISE = 1
    self.STATE_RAISE = 2
    self.STATE_READY = 3
    self.STATE_LOWER = 4
    self.currentState = self.STATE_DEFAULT

    self.MIN_BLINK_DELAY = 3
    self.MAX_BLINK_DELAY = 7
    self.blinkCountdown = self.MIN_BLINK_DELAY
    self.multiplier = 1

    self.animationFinished = false

    ABOT_IMAGE = love.graphics.newImage(graphics.imagePath("weekend1/aBotViz"))

    local viz = love.filesystem.load("sprites/characters/abot/aBotVizPixel.lua")
    for i = 1, MAX_ABOT_VIZ do
        spr = viz()
        spr:animate("viz" .. tostring(i) .. "_6", false)
        vizFrameWidth = spr:getFrameWidth()/2
        spr.x = 100 + (vizFrameWidth + 100) * i
        spr.y = -5
        table.insert(abotVisualizers, spr)
    end
end

function Nene:setY() 
    self.abotBody.x, self.abotBody.y = self.x + 125, self.y + 245
    self.abotBack.x, self.abotBack.y = self.x + 50, self.y + 250
    self.abotSpeaker.x, self.abotSpeaker.y = self.x + 50, self.y + 265
    self.abotHead.x, self.abotHead.y = self.x - 280, self.y + 320
end

function Nene:update(dt)
    BaseCharacter.update(self, dt)

    deltaCurTime = deltaCurTime + dt

    self.abotBody:update(dt)
    self.abotSpeaker:update(dt)
    self.abotHead:update(dt)

    abotVisualizers[1].x = self.x + -160 + (vizFrameWidth + 42) * 1
    abotVisualizers[2].x = self.x + -160 + (vizFrameWidth + 42) * 2
    abotVisualizers[3].x = self.x + -160 + (vizFrameWidth + 42) * 3
    abotVisualizers[4].x = self.x + -160 + (vizFrameWidth + 46) * 4
    abotVisualizers[5].x = self.x + -160 + (vizFrameWidth + 49) * 5
    abotVisualizers[6].x = self.x + -160 + (vizFrameWidth + 49) * 6
    abotVisualizers[7].x = self.x + -160 + (vizFrameWidth + 49) * 7
    for i = 1, MAX_ABOT_VIZ do
        abotVisualizers[i].y = self.y + 240
    end

    if self.soundData and love.system.getOS() ~= "NX" then
        local curSample = math.floor(inst:tell("samples"))
        local totalSamples = self.soundData:getSampleCount()
        local count = 0
        local samplesPerBarInv = 1 / 5
        for i = 1, MAX_ABOT_VIZ do
            local averageAmplitude = 0
            local baseSample = curSample + i * 5
            for j = 1, 50 do
                local sample = (baseSample + j) % totalSamples
                local sampleIndex = sample * 2

                local leftSample = self.soundData:getSample(sampleIndex) or 0
                local rightSample = self.soundData:getSample(sampleIndex + 1) or 0

                averageAmplitude = averageAmplitude + math.abs(leftSample + rightSample) * 0.5 * self.multiplier
            end

            averageAmplitude = averageAmplitude * samplesPerBarInv
            self.bars[i] = (self.bars[i] + 0.03 * (averageAmplitude - self.bars[i]))
            count = count + 1
        end
    end
end

function Nene:transitionState()
    if self.currentState == self.STATE_DEFAULT then
        if health <= 0.5 then
            self.currentState = self.STATE_PRE_RAISE
        else
            self.currentState = self.STATE_DEFAULT
        end
    elseif self.currentState == self.STATE_PRE_RAISE then
        if health > 0.5 then
            self.currentState = self.STATE_DEFAULT
        elseif self.animationFinished then
            self.currentState = self.STATE_RAISE
            self:animate("knifeRaise", false, function()
                self:transitionState()
                self.animationFinished = true
            end)
            self.animationFinished = false
        end
    elseif self.currentState == self.STATE_RAISE then
        if self.animationFinished then
            self.currentState = self.STATE_READY
            self.animationFinished = false
        end
    elseif self.currentState == self.STATE_READY then
        if health > 0.5 then
            self.currentState = self.STATE_LOWER
            self:animate("knifeLower", false, function()
                self:transitionState()
                self.animationFinished = true
            end)
        end
    elseif self.currentState == self.STATE_LOWER then
        if self.animationFinished then
            self.currentState = self.STATE_DEFAULT
            self.animationFinished = false
        end
    else 
        self.currentState = self.STATE_DEFAULT
    end
end

function Nene:updateOverride(dt)
    self:transitionState()

    if self.currentState == self.STATE_PRE_RAISE then
        if self:getAnimName() == "danceLeft" and self:getFrameFromCurrentAnim() == self:getFrameCountFromCurrentAnim()-2 then
            self.animationFinished = true
            self:transitionState()
        end
    end
end

function Nene:beat(beat)
    local beat = math.floor(beat) or 0

    if Conductor.onBeat then
        if beat % self.spr.danceSpeed == 0 then
            -- animate abot
            self.abotBody:animate("bop")
            self.abotSpeaker:animate("bop")
            self.spr.danced = not self.spr.danced
            
            if self.currentState == self.STATE_DEFAULT then
                if self.spr.danced then
                    self:animate("danceLeft", false)
                else
                    self:animate("danceRight", false)
                end	
            elseif self.currentState == self.STATE_PRE_RAISE then
                self:animate("danceLeft")
                self.spr.danced = true
            elseif self.currentState == self.STATE_READY then
                if self.blinkCountdown == 0 then
                    self:animate("knifeIdle", false)
                    self.blinkCountdown = love.math.random(self.MIN_BLINK_DELAY, self.MAX_BLINK_DELAY)
                else
                    self.blinkCountdown = self.blinkCountdown - 1
                end
            end
        end
    end
end

function Nene:udraw(sx, sy, rimShaderGF, speakerShader)
    if not self.visible then return end

    local lastShader = love.graphics.getShader()
    love.graphics.setShader(speakerShader)
    self.abotSpeaker:udraw()
    self.abotBack:udraw()
    if curOS ~= "NX" and self.soundData then
        for i = 1, MAX_ABOT_VIZ do
            local barHeight = self.bars[i]
            local animNum = math.floor(math.remap(math.remap(barHeight, 0, 6, 0, 1), 0, 1, 1, 6))
            -- reverse it so its 6-1
            animNum = 7 - animNum
            abotVisualizers[i]:animate("viz" .. tostring(i) .. "_" .. tostring(animNum), false)
            abotVisualizers[i]:udraw()
        end
    end
    self.abotHead:udraw()
    self.abotBody:udraw()
    
    graphics.setColor(1, 1, 1, 1)

    love.graphics.setShader(rimShaderGF)
    self.spr:udraw()
    love.graphics.setShader(lastShader)
end

function Nene:release()
    for _, v in pairs(abotVisualizers) do
        v = nil
    end
    ABOT_IMAGE = nil
end

return Nene