local PhillyGlowParticle = Sprite:extend()

PhillyGlowParticle.lifeTime = 0
PhillyGlowParticle.decay = 0
PhillyGlowParticle.originalScale = 1

function PhillyGlowParticle:new(x, y)
    self.lifeTime = 0
    self.decay = 0
    self.originalScale = 1

    self.super.new(self, x, y)

    self:load("stages/philly/particle")
    self.lifeTime = love.math.randomFloat(0.6, 0.9)
    self.decay = love.math.randomFloat(0.8, 1)
    self.originalScale = love.math.randomFloat(0.75, 1)
    self.scale.x, self.scale.y = self.originalScale, self.originalScale

    self.scrolFactor = {
        x = love.math.randomFloat(0.3, 0.75),
        y = love.math.randomFloat(0.65, 0.75)
    }
    self.velocity = {
        x = love.math.randomFloat(-40, 40),
        y = love.math.randomFloat(-175, 250)
    }
    self.acceleration = {
        x = love.math.randomFloat(-10, 10),
        y = 25
    }
end

function PhillyGlowParticle:update(dt) 
    self.lifeTime = self.lifeTime - dt
    if self.lifeTime < 0 then
        self.lifeTime = 0
        self.alpha = self.alpha - dt * self.decay
        if self.alpha > 0 then
            self.scale.x = self.originalScale * self.alpha
            self.scale.y = self.originalScale * self.alpha
        end
    end
    self.super.update(self, dt)
end

return PhillyGlowParticle