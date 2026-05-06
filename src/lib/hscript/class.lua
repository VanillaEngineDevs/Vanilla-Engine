local class = {}
class.__index = class

--- Create a new class that extends the current one
---@param name string?
---@return table
function class:extend(name)
    local cls = {}
    for k, v in pairs(self) do
        if k:find("__", 1, true) == 1 then
            cls[k] = v
        end
    end
    cls.__index = cls
    cls.super = self
    --[[ cls.__ID = generateID() ]]
    local id = tostring(cls)
    id = id:sub(id:find(":") + 2)
    cls.__ID = name or ("Class: " .. id)
    cls._NAME = name or "Class"
    setmetatable(cls, self)
    return cls
end

--- Mixin/Implement methods from other classes
---@param ... table
function class:implement(...)
    for _, cls in pairs({...}) do
        for k, v in pairs(cls) do
            if self[k] == nil and type(v) == "function" then
                self[k] = v
            end
        end
    end
end

--- Check if self is an instance of given class
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

--- To string override to return class ID
---@return string
function class:__tostring()
    return self.__ID
end

--- Instantiate the class if needed and call a named method on it
---@param name string
---@param ... any
---@return any
function class:call(name, ...)
    local fn = self[name]
    if type(fn) ~= "function" then
        --error("Unknown callable member: " .. tostring(name), 0)
        return function() end
    end

    local receiver = self.script or self
    return fn(receiver, ...)
end

--- Instantiate a new object of the class
---@param ... any
---@return any
function class:__call(...)
    local inst = setmetatable({}, self)
    --[[ inst.__ID = generateID() ]]
    inst.__ID = self.__ID .. " Instance"
    if inst.new then inst:new(...) end
    return inst
end

return class
