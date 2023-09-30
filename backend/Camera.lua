local Camera = Object:extend()

function Camera:new(x, y, w, h)
    local x = x or 0
    local y = y or 0
    local w = w or push:getWidth()
    local h = h or push:getHeight()

    self.x = x
    self.y = y
    self.angle = 0
    self.target = nil
    self.width = w
    self.height = h
    self.zoom = 1
    self.visible = true

    self._fade = 0
    self.fadeColour = hexToColor(0xFFFFFFFF)
    
    self._flash = 0
    self.flashColour = hexToColor(0xFFFFFFFF)
end

function Camera:getPosition(x, y)
    return x - (not self.target and 0 or self.target.x) + self.width / 2, y - (not self.target and 0 or self.target.y) + self.height / 2
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

function Camera:fade(colour, time, out, callback)
    self._fade = 0
    self.fadeColour = colour
    Timer.tween(time, self, {_fade = out and 1 or 0}, "linear", function()
        if callback then callback() end
    end)
end

function Camera:update(dt)

end

function Camera:draw()
    if self._flash > 0 then
        love.graphics.setColor(self.flashColour)
        love.graphics.rectangle("fill", -self.width, -self.height, self.width * 3, self.height * 3)
    end

    if self._fade > 0 then
        print("bbg.... daddys home... hello princess")
        love.graphics.setColor(self.fadeColour)
        love.graphics.rectangle("fill", -self.width, -self.height, self.width * 3, self.height * 3)
    end
end

return Camera