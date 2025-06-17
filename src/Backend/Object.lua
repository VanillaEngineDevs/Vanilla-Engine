---@diagnostic disable: undefined-doc-name, undefined-doc-class
---@class Object : Basic
local Object = Basic:extend()

---@param x integer
---@param y integer
---@param width integer
---@param height integer
function Object:new(x, y, width, height)
    self.x = x or 0
    self.y = y or 0
    self.width = width or 0
    self.height = height or 0

    self.angle = 0

    self.scrollFactor = Point(1, 1)
    self.scale = Point(1, 1)
    self.origin = Point()

    self.last = Point()

    self.pixelPerfectPosition = true

    Basic.new(self)
end

function Object:destroy()
    Basic.destroy(self)
end

---@param dt number
function Object:update(dt)
    Basic.update(self, dt)

    self.last:set(self.x, self.y)
end

function Object:draw()
    Basic.draw(self)
end

---@param result Point
---@param camera Camera
---@return Point
function Object:getScreenPosition(result, camera)
    if result == nil then
        result = Point()
    end

    if camera == nil then
        camera = Camera
    end

    result:set(self.x, self.y)
    if self.pixelPerfectPosition then
        result:floor()
    end

    if camera then
        result:subtract(camera.scroll.x * self.scrollFactor.x, camera.scroll.y * self.scrollFactor.y)
    end

    return result
end

---@param result Point
---@return Point
function Object:getPosition(result)
    if result == nil then
        result = Point()
    end

    result:set(self.x, self.y)
    return result
end

---@param point Point
---@return Point
function Object:getMidpoint(point)
    if point == nil then
        point = Point()
    end

    point:set(self.x + self.width * 0.5, self.y + self.height * 0.5)
    return point
end

---@param x number
---@param y number
function Object:reset(x, y)
    self:setPosition(x or 0, y or 0)
    self.last:set(self.x, self.y)
    self:revive()
end

---@param axes? string: Default: "XY"
function Object:screenCenter(axes)
    local axes = axes or "XY"
    if axes:find("X") then
        self.x = (Config.GameWidth - self.width) / 2
    end
    if axes:find("Y") then
        self.y = (Config.GameHeight - self.height) / 2
    end
end

---@param x number
---@param y number
function Object:setPosition(x, y)
    self.x = x or 0
    self.y = y or 0
end

---@param width number
---@param height number
function Object:setSize(width, height)
    self.width = width or 1
    self.height = height or 1
end

return Object