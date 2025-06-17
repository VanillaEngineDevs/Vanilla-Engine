---@class Camera : Object
Camera = Object:extend()
Camera.res = 1

Camera._defaultCameras = {}
Camera.defaultZoom = 1

---@param x number
---@param y number
---@param width number
---@param height number
function Camera:new(x, y, width, height)
    self.scroll = Point()
    self.rotation = 0
    self.angle = 0
    self.zoom = 1
    self.target = nil
    self.followLerp = 0
    self.res = 1
    
    self.color = {0, 0, 0, 0}

    self.x, self.y, self.width, self.height = x, y, width, height

    self.renders = {}

    Object.new(self, x, y, width, height)
end

function Camera:renderAllObjects()
    for i, object in ipairs(self.renders) do
        if object.render then
            object:render(self)
        end
        self.renders[i] = nil
    end
end

---@param target Basic|Object|Sprite
---@param lerp? number
function Camera:follow(target, lerp)
    if not target then return end

    self.target = target
    self.followLerp = lerp or 0
end

function Camera:unfollow()
    self.target = nil
    self.followLerp = nil
end

---@param object Basic|Object|Sprite
function Camera:snapTo(object)
    local object = object or self.target

    self.scroll.x = object.x - self.width/2
    self.scroll.y = object.y - self.height/2
end

---@param object Basic|Object|Sprite
function Camera:focusOn(object)
    self:follow(object)
    self:snapTo(object)
end

---@param width? number
---@param height? number
---@param res? number
function Camera:resize(width, height, res)
    res = res or Camera.res
    
    self.width, self.height = width or 1, height or 1
    self.res = res or 1
end

---@param dt number
function Camera:update(dt)
    if self.target then
        local targetX, targetY = self.target.x - self.width / 2, self.target.y - self.height/2

        if self.followLerp then
            local lerp = 1 - math.exp(-dt * self.followLerp)
            targetX, targetY = math.lerp(self.scroll.x, targetX, lerp), math.lerp(self.scroll.y, targetY, lerp)
        end

        self.scroll.x, self.scroll.y = targetX, targetY
    end
end

function Camera:getInfo()
    return self.x, self.y, self.width, self.height
end

function Camera:draw()
    if self.visible or self.exists then
        local lastColor = {love.graphics.getColor()}
        local blend, alphaMode = love.graphics.getBlendMode()

        local x, y, w, h = self:getInfo()
        local sx, sy = self.scale:get()
        local halfW, halfH = w/2, h/2

        love.graphics.push()

            love.graphics.translate(halfW + x, halfH + y)
            love.graphics.scale(self.zoom * sx, self.zoom * sy)
            love.graphics.rotate(math.rad(self.angle + self.rotation))
            love.graphics.translate(-halfW, -halfH)

            love.graphics.setBlendMode("alpha", "alphamultiply")
            self:renderAllObjects()

        love.graphics.pop()

        love.graphics.setColor(lastColor)
        love.graphics.setBlendMode(blend, alphaMode)
    end
end

function Camera:applyTransform()
    local x, y, w, h = self:getInfo()
    local sx, sy = self.scale:get()
    local halfW, halfH = w/2, h/2

    love.graphics.translate(halfW + x, halfH + y)
    love.graphics.scale(self.zoom * sx, self.zoom * sy)
    love.graphics.rotate(math.rad(self.angle + self.rotation))
    love.graphics.translate(-halfW, -halfH)
end

return Camera