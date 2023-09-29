local PhillyGlowGradient = Sprite:extend()

PhillyGlowGradient.originalY = 0
PhillyGlowGradient.originalHeight = 400
PhillyGlowGradient.intendedAlpha = 1

function PhillyGlowGradient:new(x, y)
    self.originalY = y
    self.originalHeight = 400
    self.intendedAlpha = 1

    self.super.new(self, x, y)
    self:load("stages/philly/gradient")
    self.scrollFactor = {x=0, y=0.75}
    self:setGraphicSize(2000, self.originalHeight)
    self:updateHitbox()
end

function PhillyGlowGradient:update(dt)
    local newHeight = math.round(self.height - 1000 * dt)
    --print(newHeight)
    if newHeight > 0 then
        self.alpha = self.intendedAlpha
        self:setGraphicSize(2000, newHeight)
        self:updateHitbox()
        self.y = self.originalY + (self.originalHeight - newHeight)
    else
        self.alpha = 0
        self.y = -5000
    end

    self.super.update(self, dt)
end

function PhillyGlowGradient:bop()
    self:setGraphicSize(2000, self.originalHeight)
    self:updateHitbox()
    self.y = self.originalY
    self.alpha = self.intendedAlpha
end

return PhillyGlowGradient