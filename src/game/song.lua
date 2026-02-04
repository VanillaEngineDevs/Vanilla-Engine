local songscript = Object:extend()

function songscript.getSong(id)
    print("Loading song script: " .. id)
    local s = songscript()

    local songLuaChunk = love.filesystem.getInfo("data/scripts/songs/" .. id .. ".lua")
    local env = setmetatable({
        Song = {
        },
        add = function(obj)
            weeks:add(obj)
        end,
        remove = function(obj)
            weeks:remove(obj)
        end,
        getBoyfriend = function()
            return boyfriend
        end,
        getGirlfriend = function()
            return girlfriend
        end,
        getEnemy = function()
            return enemy
        end,
        get = function(name)
            return weeks:get(name)
        end,
        getCamera = function()
            return camera
        end,
        getCameraLerpPoint = function()
            return CAM_LERP_POINT
        end,
    }, {__index = _G})
    if songLuaChunk then
        local chunk = love.filesystem.load("data/scripts/songs/" .. id .. ".lua")

        setfenv(chunk, env)
        chunk()
    end

    s.script = env.Song

    return s
end

function songscript:call(funcName, ...)
    if self.script and self.script[funcName] and type(self.script[funcName]) == "function" then
        self.inScriptCall = true
        local result = self.script[funcName](self.script, ...)
        self.inScriptCall = false
        return result
    end
end

function songscript:isFunction(name)
    return self.script and self.script[name] and type(self.script[name]) == "function"
end

function songscript:new()
    self.inScriptCall = false
end

function songscript:update(dt)
end

return songscript