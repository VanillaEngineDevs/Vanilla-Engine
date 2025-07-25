local BFDark = BaseCharacter:extend()

function BFDark:new()
    BaseCharacter.new(self, "sprites/characters/boyfriend-dark.lua")

    self.child = love.filesystem.load("sprites/characters/boyfriend.lua")()
    self.child.alpha = 1
end

function BFDark:update(dt)
    BaseCharacter.update(self, dt)
    
    self.child:update(dt)

    self.child.x, self.child.y = self.x, self.y
    self.child.orientation = self.orientation
    self.child.sizeX, self.child.sizeY = self.sizeX, self.sizeY
    self.child.offsetX, self.child.offsetY = self.child.offsetX, self.child.offsetY
    self.child.shearX, self.child.shearY = self.shearX, self.shearY
    self.child.flipX, self.child.flipY = self.flipX, self.flipY

    self.child.shader = self.shader

    self.child.holdTimer = self.holdTimer
end

function BFDark:draw()
    if not self.visible then return end

    self.child:draw()
    self.spr:draw()
end

function BFDark:udraw(sx, sy)
    if not self.visible then return end

    self.child:udraw(sx, sy)
    self.spr:udraw(sx, sy)
end

function BFDark:beat(beat)
    self.child:beat(beat)
    self.spr:beat(beat)
end

function BFDark:animate(...)
    self.child:animate(...)
    self.spr:animate(...)
end

function BFDark:isAnimated()
    return self.spr:isAnimated()
end

function BFDark:getAnimName()
    return self.spr:getAnimName()
end

function BFDark:setAnimSpeed(speed)
    self.child:setAnimSpeed(speed)
    self.spr:setAnimSpeed(speed)
end

return BFDark