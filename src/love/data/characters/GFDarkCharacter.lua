local GFDark = BaseCharacter:extend()

function GFDark:new()
    BaseCharacter.new(self, "sprites/characters/girlfriend-dark.lua")

    self.child = love.filesystem.load("sprites/characters/girlfriend.lua")()
    self.child.alpha = 1
end

function GFDark:update(dt)
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

    self.child:setAnimFrame(self.spr:getAnimFrame())
end

function GFDark:draw()
    if not self.visible then return end

    self.child:draw()
    self.spr:draw()
end

function GFDark:udraw(sx, sy)
    if not self.visible then return end

    self.child:udraw(sx, sy)
    self.spr:udraw(sx, sy)
end

function GFDark:beat(beat)
    self.child:beat(beat)
    self.spr:beat(beat)
end

function GFDark:animate(name, ...)
    if name == "sad" then return end

    self.child:animate(name, ...)
    self.spr:animate(name,...)
end

function GFDark:isAnimated()
    return self.spr:isAnimated()
end

function GFDark:getAnimName()
    return self.spr:getAnimName()
end

function GFDark:setAnimSpeed(speed)
    self.child:setAnimSpeed(speed)
    self.spr:setAnimSpeed(speed)
end

return GFDark