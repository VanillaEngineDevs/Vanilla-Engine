local Camera = Object:extend()

function Camera:new(x, y, w, h)
    local x = x or 0
    local y = y or 0
    local w = w or push:getWidth()
    local h = h or push:getHeight()

    self.x = x
    self.y = y
    self.target = nil
    self.width = w
    self.height = h
    self.zoom = 1
end

function Camera:getPosition(x, y)
    return x - (not self.target and 0 or self.target.x) + self.width / 2, y (not self.target and 0 or self.target.y) + self.height / 2
end

function Camera:attach()
    love.graphics.push()

    local w, h = self.width / 2, self.height / 2
    love.graphics.scale(self.zoom)
    love.graphics.translate(w / self.zoom - w, h / self.zoom - h)
    love.graphics.translate(-self.x, -self.y)
    love.graphics.translate(w, h)
    love.graphics.rotate(-self.angle)
    love.graphics.translate(-w, -h)
end

function Camera:detach()
    love.graphics.pop()
end

return Camera