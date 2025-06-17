-- Based off of haxeflixel's FlxPoint class
---@class Point
---@diagnostic disable-next-line: assign-type-mismatch
local Point = Class:extend()

---@param x integer
---@param y integer
---@return Point
function Point:new(x, y)
    self.x = x or 0
    self.y = y or 0

    self.__name = "Point"
    
    return self
end

---@return any, any
function Point:get()
    return self.x or 0, self.y or 0
end

---@return string
function Point:__tostring()
    return "[POINT] : " .. self.x .. ", " .. self.y
end

---@param other Point
---@return Point
function Point:__add(other)
    return Point(self.x + other.x, self.y + other.y)
end

---@param other Point
---@return Point
function Point:__sub(other)
    return Point(self.x - other.x, self.y - other.y)
end


---@param other Point
---@return Point
function Point:__mul(other)
    return Point(self.x * other.x, self.y * other.y)
end

---@param other Point
---@return Point
function Point:__div(other)
    return Point(self.x / other.x, self.y / other.y)
end

---@param other Point
---@return boolean
function Point:__eq(other)
    return self.x == other.x and self.y == other.y
end

---@param other Point
---@return boolean
function Point:__lt(other)
    return self.x < other.x and self.y < other.y
end

---@param other Point
---@return boolean
function Point:__le(other)
    return self.x <= other.x and self.y <= other.y 
end

---comment
---@return Point
function Point:__unm()
    return Point(-self.x, -self.y)
end

---@param other Point
---@return string
function Point:__concat(other)
    return tostring(self) .. tostring(other)
end

---@param x integer
---@param y integer
function Point:set(x, y)
    local x = x or 0
    local y = y or x

    self.x, self.y = x, y
end

---@param x integer
---@param y integer
function Point:subtract(x, y)
    local x = x or 0
    local y = y or 0

    self.x, self.y = self.x - x, self.y - y
end

function Point:floor()
    self.x = math.floor(self.x)
    self.y = math.floor(self.y)
end

return Point