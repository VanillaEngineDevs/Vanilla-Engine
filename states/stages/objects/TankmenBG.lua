local TankmenBG = Sprite:extend()

TankmenBG.animationNotes = {}
TankmenBG.tankSpeed = 0
TankmenBG.endingOffset = 0
TankmenBG.goingRight = false
TankmenBG.strumTime = 0

function TankmenBG:new(x, y, facingRight)
    self.tankSpeed = 0.7
    self.strumTime = 0
    self.goingRight = facingRight
    self.super.new(self, x, y)

    self:setFrames(Paths.getAtlas("stages/tank/tankmanKilled1", "assets/images/png/stages/tank/tankmanKilled1.xml"))
    self:addByPrefix("run", "tankman running", 24, false)
    self:addByPrefix("shot", "John Shot " .. love.math.random(1, 2), 24, false) -- rip John
    self:play("run")
    self.curFrame = love.math.random(1, #self.curAnim.frames)

    self.scale = {x = 0.8, y = 0.8}
    self:updateHitbox()
end

function TankmenBG:resetShit(x, y, goingRight)
    self.x = x
    self.y = y
    self.goingRight = goingRight
    self.endingOffset = love.math.randomFloat(50, 200)
    self.tankSpeed = love.math.randomFloat(0.6, 1)
    self.flipX = goingRight
end

function TankmenBG:update(dt)
    self.super.update(self, dt)

    self.visible = (self.x > -0.5 * push:getWidth() and self.x < 1.2 * push:getWidth())

    if self.curAnim.name == "run" then
        local speed = (Conductor.songPosition - self.strumTime) * self.tankSpeed
        if self.goingRight then
            self.x = (0.02 * push:getWidth() - self.endingOffset) + speed
        else
            self.x = (0.74 * push:getWidth() + self.endingOffset) - speed
        end
    elseif self.curAnim.name == "shot" and self.animFinished then
        self.visible = false
        self.alive = false
    end

    if Conductor.songPosition > self.strumTime then
        self:play("shot")
        if self.goingRight then
            self.offset.x = 300
            self.offset.y = 200
        end
    end
end

return TankmenBG