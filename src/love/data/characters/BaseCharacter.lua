local Character = Object:extend()

function Character:new(luaPath)
    self.spr = love.filesystem.load(luaPath)()
    self.x, self.y = 0, 0
    self.orientation = 0
    self.sizeX, self.sizeY = 1, 1
    self.offsetX, self.offsetY = 0, 0
    self.shearX, self.shearY = 0, 0
    self.optionsTable = self.spr.optionsTable
    self.icon = self.optionsTable.icon
    self.flipX, self.flipY = false, false
    self.holdTimer = 0
    self.maxHoldTimer = self.spr.maxHoldTimer

    self.visible = true
end

function Character:update(dt)
    self.spr:update(dt)

    self.spr.x, self.spr.y = self.x, self.y
    self.spr.orientation = self.orientation
    self.spr.sizeX, self.spr.sizeY = self.sizeX, self.sizeY
    self.spr.offsetX, self.spr.offsetY = self.spr.offsetX, self.spr.offsetY
    self.spr.shearX, self.spr.shearY = self.shearX, self.shearY
    self.spr.flipX, self.spr.flipY = self.flipX, self.flipY

    self.spr.shader = self.shader

    self.spr.holdTimer = self.holdTimer

    self.spr.alpha = self.alpha or 1
end

function Character:draw()
    if not self.visible then return end

    self.spr:draw()
end

function Character:udraw(sx, sy)
    if not self.visible then return end
    self.spr:udraw(sx, sy)
end

function Character:beat(beat)
    self.spr:beat(beat)
end

function Character:animate(...)
    self.spr:animate(...)
end

function Character:isAnimated()
    return self.spr:isAnimated()
end

function Character:getAnimName()
    return self.spr:getAnimName()
end

function Character:setAnimSpeed(speed)
    self.spr:setAnimSpeed(speed)
end

return Character