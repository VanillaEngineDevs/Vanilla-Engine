local class = {
  --[[
  _NAME = "Class",
  _VERSION = "1.0.0",
  _DESCRIPTION = "A simple class implementation",
  _CREATOR = "GuglioIsStupid",
  _LICENSE = [[
      MIT LICENSE
  ]] -- No need to take up lua memory with this
}

class.__index = class
class.__ID = "Class: 0x0000000000000000"

-- Recreate smth like "Table: 0x0000000000000000"
local idChars = "0123456789abcdef"

--- Creates a new instance of the class. To be called as: Class(...)
--- ```lua
--- local MyClass = Class()
--- ```
---@param ... any
---@return any
function class:new(...) end

--- Creates a new class that extends the current class
--- ```lua
--- local MyClass = Class()
--- local MySubClass = MyClass:extend()
--- ```
---@return table --[[In reality, this is a table. But for the sake of the documentation, it's a class.]]
function class:extend()
    local cls = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            cls[k] = v
        end
    end
    cls.__index = cls
    cls.super = self
    cls.__ID = "Class: 0x"
    for _ = 1, 4 do
        cls.__ID = cls.__ID .. idChars:sub(love.math.random(1, #idChars), love.math.random(1, #idChars))
    end
    setmetatable(cls, self)
    return cls
end

--- Implements a class into the current class
--- ```lua
--- local MyClass = Class()
--- local MySubClass = MyClass:extend()
--- MySubClass:implement(SomeClass)
--- ```
---@param ... table
---@return nil
function class:implement(...) 
    -- copy over all VALUES from the given class to the current class
    for _, cls in ipairs({...}) do
        if type(cls) ~= "table" then
            error("Expected a table, got " .. type(cls), 2)
        end
        for k, v in pairs(cls) do
            if k:find("__") ~= 1 then
                self[k] = v
                --printf("Implementing %s.%s into %s", cls.__ID, k, self.__ID)
            end
        end
    end
    return nil
end

--- Checks if the current class is an instance of the given class
--- ```lua
--- local MyClass = Class()
--- local MySubClass = MyClass:extend()
--- local inst = MySubClass()
--- print(inst:isInstanceOf(MyClass)) -- true
---@param cls table
---@return boolean
function class:isInstanceOf(cls)
    local m = getmetatable(self)
    while m do
        if m == cls then return true end
        m = m.super
    end
    return false
end

--- Returns the class ID
---@return string
function class:__tostring()
    return self.__ID
end

--- Creates a new instance of the class
--- ```lua
--- local MyClass = Class()
--- local inst = MyClass()
--- ```
---@param ... any
---@return any
function class:__call(...)
    local inst = setmetatable({}, self)
    -- also extend it
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            inst[k] = v
        end
    end
    inst:new(...)
    inst.__ID = "Class: 0x"
    for _ = 1, 4 do
        inst.__ID = inst.__ID .. idChars:sub(love.math.random(1, #idChars), love.math.random(1, #idChars))
    end
    return inst
end

return class