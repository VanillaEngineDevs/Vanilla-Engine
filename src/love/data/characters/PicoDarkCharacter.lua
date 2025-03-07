local PicoDark = BaseCharacter:extend()

function PicoDark:new()
    BaseCharacter.new(self, "sprites/characters/pico-player-dark.lua")

    self.child = love.filesystem.load("sprites/characters/pico-player.lua")()
    self.child.alpha = 1
end

function PicoDark:update(dt)
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

function PicoDark:draw()
    if not self.visible then return end

    self.child:draw()
    self.spr:draw()
end

function PicoDark:udraw(sx, sy)
    if not self.visible then return end

    self.child:udraw(sx, sy)
    self.spr:udraw(sx, sy)
end

function PicoDark:beat(beat)
    self.child:beat(beat)
    self.spr:beat(beat)
end

function PicoDark:animate(...)
    self.child:animate(...)
    self.spr:animate(...)
end

function PicoDark:isAnimated()
    return self.spr:isAnimated()
end

function PicoDark:getAnimName()
    return self.spr:getAnimName()
end

function PicoDark:setAnimSpeed(speed)
    self.child:setAnimSpeed(speed)
    self.spr:setAnimSpeed(speed)
end

return PicoDark