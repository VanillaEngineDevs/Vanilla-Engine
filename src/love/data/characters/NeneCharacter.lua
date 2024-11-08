local Nene = BaseCharacter:extend()

ABOT_IMAGE = nil
local abotVisualizers = {}
local MAX_ABOT_VIZ = 7
local VIS_TIME_MAX = 0.033333333333333333
local deltaCurTime = 0
local vizFrameWidth = 0

function Nene:new()
    self.abot = graphics.newImage(graphics.imagePath("weekend1/abot"))
    self.abotBack = graphics.newImage(graphics.imagePath("weekend1/stereoBG"))
    self.soundData = nil
    self.bars = {0, 0, 0, 0, 0, 0, 0}

    abotVisualizers = {}
    BaseCharacter.new(self, "sprites/characters/nene.lua")

    self.name = "nene"

    self.STATE_DEFAULT = 0
    self.STATE_PRE_RAISE = 1
    self.STATE_RAISE = 2
    self.STATE_READY = 3
    self.STATE_LOWER = 4
    self.currentState = self.STATE_DEFAULT

    self.MIN_BLINK_DELAY = 3
    self.MAX_BLINK_DELAY = 7
    self.blinkCountdown = self.MIN_BLINK_DELAY

    self.animationFinished = false

    ABOT_IMAGE = love.graphics.newImage(graphics.imagePath("weekend1/aBotViz"))

    for i = 1, MAX_ABOT_VIZ do
        local viz = love.filesystem.load("sprites/weekend1/abotViz.lua")()
        --viz:animate(tostring(i) .. "_1", false)
        vizFrameWidth = viz:getFrameWidth()/2
        viz.x = -170 + (vizFrameWidth + 25) * i
        viz.y = 0--stageImages["abot"].y + 120
        --print(viz.x)
        table.insert(abotVisualizers, viz)
    end
end

function Nene:update(dt)
    BaseCharacter.update(self, dt)

    deltaCurTime = deltaCurTime + dt

    self.abot.x, self.abot.y = self.x + 48, self.y + 250
    self.abotBack.x, self.abotBack.y = self.x + 48, self.y + 250

    for i = 1, MAX_ABOT_VIZ do
        abotVisualizers[i].x, abotVisualizers[i].y = self.x + -180 + (vizFrameWidth + 25) * i, self.y + 270
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

                averageAmplitude = averageAmplitude + math.abs(leftSample + rightSample) * 0.5
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

function Nene:draw(debug)
    if not self.visible then return end

    self.abotBack:draw()
    if curOS ~= "NX" and not debug and self.soundData then
        for i = 1, MAX_ABOT_VIZ do
            local barHeight = self.bars[i]
            local animNum = math.floor(math.remap(math.remap(barHeight, 0, 6, 0, 1), 0, 1, 1, 6))
            abotVisualizers[i]:animate(tostring(i) .. "_" .. tostring(animNum), false)
            abotVisualizers[i]:draw()
        end
    end
    graphics.setColor(1, 1, 1, 1)
    ---12, -270
    love.graphics.rectangle("fill", self.x + -327, self.y + 300, 120, 60)
    self.abot:draw()

    self.spr:draw()
end

function Nene:release()
    for _, v in pairs(abotVisualizers) do
        v = nil
    end
    ABOT_IMAGE = nil
end

return Nene