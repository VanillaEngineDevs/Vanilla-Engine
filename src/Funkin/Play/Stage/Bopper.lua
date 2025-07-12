local Bopper = StageProp:extend("Bopper")
Bopper:implement(IPlayStateScriptedClass)

function Bopper:new(danceEvery)
    StageProp.new(self, "Bopper")

    self.danceEvery = danceEvery or 0
    self.shouldAlternate = nil
    self.idleSuffix = ""

    self.isPixel = false
    self.shouldBop = false
    self.globalOffsets = {0, 0}
    self.originalPosition = Point(0, 0)

    self.hasDanced = false
end

function Bopper:set_idleSuffix(v)
    self.idleSuffix = v or ""
    self:dance()
end

function Bopper:resetPosition()
end

function Bopper:update_shouldAlternate()
    self.shouldAlternate = self:getAnimByName("danceLeft") ~= nil
end

function Bopper:onStepHit(e)
    if self.danceEvery > 0 and (e.step % (self.danceEvery * Constants.STEPS_PER_BEAT)) == 0 then
        self:dance(self.shouldBop)
    end
end

function Bopper:dance(forceRestart)
    if self.curAnim == nil then
        return
    end

    if self.shouldAlternate == nil then
        self:update_shouldAlternate()
    end

    if self.shouldAlternate then
        if self.hasDanced then
            self:playAnimation("danceLeft" .. self.idleSuffix, forceRestart)
        else
            self:playAnimation("danceRight" .. self.idleSuffix, forceRestart)
        end
    else
        self:playAnimation("idle" .. self.idleSuffix, forceRestart)
    end
end

function Bopper:playAnimation(name, restart, ignoreOther, reversed)
    self:play(name, restart)
end

return Bopper