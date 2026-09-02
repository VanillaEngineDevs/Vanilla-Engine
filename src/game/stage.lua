---@diagnostic disable: need-check-nil, inject-field
local stage = Object:extend()

local defaultBF = {
    zIndex = 300,
    position = {989.5, 885},
    cameraOffsets = {-100, -100},
    scale = {1, 1},
    scroll = {1, 1}
}

local defaultDad = {
    zIndex = 200,
    position = {335, 885},
    cameraOffsets = {160, -100},
    scale = {1, 1},
    scroll = {1, 1}
}

local defaultGF = {
    zIndex = 100,
    position = {751.5, 787},
    cameraOffsets = {0, 0},
    scale = {1, 1},
    scroll = {1, 1}
}

local defaultProps = {
    danceEvery = 0,
    zIndex = 1,
    position = {0, 0},
    scale = {1, 1},
    animType = "sparrow",
    name = "prop",
    isPixel = false,
    assetPath = "prop",
    scroll = {1, 1},
    animations = {
        {
          name = "bgtrees",
          prefix = "bgtrees",
          looped = true,
          indiceFrames = {},
          frameRate = 5
        }
    },
    startingAnimation = "bgtrees"
}

function stage.getStage(id)
    local data = json.decode(love.filesystem.read("data/stages/" .. id .. ".json"))

    local s = stage()
    s._data = data
    s.id = id
    s.name = data.name or id
    s.directory = (data.directory or "stages/")

    s.cameraZoom = data.cameraZoom or 1
    camera.currentZoom = s.cameraZoom
    s.version = data.version or "1.0.0"
    s.characters = data.characters or {}
    s.characters.bf = data.characters.bf or {}
    -- set all missing values
    for k, v in pairs(defaultBF) do
        if s.characters.bf[k] == nil then
            s.characters.bf[k] = v
        end
    end
    s.characters.dad = data.characters.dad or {}
    for k, v in pairs(defaultDad) do
        if s.characters.dad[k] == nil then
            s.characters.dad[k] = v
        end
    end
    s.characters.gf = data.characters.gf or {}
    for k, v in pairs(defaultGF) do
        if s.characters.gf[k] == nil then
            s.characters.gf[k] = v
        end
    end

    s._props = data.props or {}
    for i, propitem in ipairs(s.props) do
        for k, v in pairs(defaultProps) do
            if propitem[k] == nil then
                propitem[k] = v
            end
        end
    end

    s.props = {}
    s.script = nil

    local stageLuaChunk = love.filesystem.getInfo("scripts/stages/" .. s.id .. ".lua")
    -- environment that holds ALL of global and defines Stage as self
    local env = setmetatable({
        Stage = {
            data = s,
        },
        add = function(obj)
            weeks:add(obj)
        end,
        remove = function(obj)
            weeks:remove(obj)
        end,
        getBoyfriend = function()
            return weeks.boyfriend
        end,
        getGirlfriend = function()
            return weeks.girlfriend
        end,
        getEnemy = function()
            return weeks.enemy
        end,
        get = function(name)
            for _, obj in ipairs(weeks.objects) do
                if obj.name == name then
                    return obj
                end
            end

            for _, prop in pairs(s.props) do
                if prop.name == name then
                    return s.props[name]
                end
            end
        end,
        getCamera = function()
            return camera
        end,
        getCameraLerpPoint = function()
            return weeks:getCameraLerpPoint()
        end,
    }, {__index = _G})
    if stageLuaChunk then
        local chunk = love.filesystem.load("scripts/stages/" .. s.id .. ".lua")
        setfenv(chunk, env)
        chunk()
        s.script = env.Stage
    --[[else
        local hscriptChunk = love.filesystem.getInfo("scripts/stages/" .. s.id .. ".hxc")
        if hscriptChunk then
            local hscriptCode = love.filesystem.read("scripts/stages/" .. s.id .. ".hxc")
            local ast = HScript.mainParser:parseString(hscriptCode)
            if ast then
                HScript.setGlobals()
                HScript.setImports()
                local result, err = HScript.main:execute(ast)
                if err then
                    print("Error executing HScript for stage " .. s.id .. ": " .. err)
                else
                    s.script = result
                end
            else
                print("Error parsing HScript for stage " .. s.id)
            end
        end
    --]]
    end

    weeks.enemy.x = s.characters.dad.position[1]
    weeks.enemy.y = s.characters.dad.position[2]
    weeks.enemy.scroll = {
        x = s.characters.dad.scroll[1],
        y = s.characters.dad.scroll[2]
    }
    if type(weeks.enemy.scale) == "number" then
        weeks.enemy.scale = {
            x = s.characters.dad.scale * weeks.enemy.scale,
            y = s.characters.dad.scale * weeks.enemy.scale
        }
    else
        if type(s.characters.dad.scale) == "number" then
            weeks.enemy.scale = {
                x = s.characters.dad.scale * weeks.enemy.scale.x,
                y = s.characters.dad.scale * weeks.enemy.scale.y
            }
        else
            weeks.enemy.scale = {
                x = s.characters.dad.scale[1] * weeks.enemy.scale.x,
                y = s.characters.dad.scale[2] * weeks.enemy.scale.y
            }
        end
    end
    weeks.enemy.cameraOffsets = {
        x = weeks.enemy.cameraOffsets[1] + s.characters.dad.cameraOffsets[1],
        y = weeks.enemy.cameraOffsets[2] + s.characters.dad.cameraOffsets[2]
    }
    weeks.enemy.zIndex = s.characters.dad.zIndex

    weeks.boyfriend.x = s.characters.bf.position[1]
    weeks.boyfriend.y = s.characters.bf.position[2]
    weeks.boyfriend.scroll = {
        x = s.characters.bf.scroll[1],
        y = s.characters.bf.scroll[2]
    }
    if type(weeks.boyfriend.scale) == "number" then
        weeks.boyfriend.scale = {
            x = s.characters.bf.scale * weeks.boyfriend.scale,
            y = s.characters.bf.scale * weeks.boyfriend.scale
        }
    else
        if type(s.characters.bf.scale) == "number" then
            weeks.boyfriend.scale = {
                x = s.characters.bf.scale * weeks.boyfriend.scale.x,
                y = s.characters.bf.scale * weeks.boyfriend.scale.y
            }
        else
            weeks.boyfriend.scale = {
                x = s.characters.bf.scale[1] * weeks.boyfriend.scale.x,
                y = s.characters.bf.scale[2] * weeks.boyfriend.scale.y
            }
        end
    end
    weeks.boyfriend.cameraOffsets = {
        x = weeks.boyfriend.cameraOffsets[1] + s.characters.bf.cameraOffsets[1],
        y = weeks.boyfriend.cameraOffsets[2] + s.characters.bf.cameraOffsets[2]
    }
    weeks.boyfriend.zIndex = s.characters.bf.zIndex

    if weeks.girlfriend then
        weeks.girlfriend.x = s.characters.gf.position[1]
        weeks.girlfriend.y = s.characters.gf.position[2]
        weeks.girlfriend.scroll = {
            x = s.characters.gf.scroll[1],
            y = s.characters.gf.scroll[2]
        }
        if type(weeks.girlfriend.scale) == "number" then
            weeks.girlfriend.scale = {
                x = s.characters.gf.scale * weeks.girlfriend.scale,
                y = s.characters.gf.scale * weeks.girlfriend.scale
            }
        else
            if type(s.characters.gf.scale) == "number" then
                weeks.girlfriend.scale = {
                    x = s.characters.gf.scale * weeks.girlfriend.scale.x,
                    y = s.characters.gf.scale * weeks.girlfriend.scale.y
                }
            else
                weeks.girlfriend.scale = {
                    x = s.characters.gf.scale[1] * weeks.girlfriend.scale.x,
                    y = s.characters.gf.scale[2] * weeks.girlfriend.scale.y
                }
            end
        end
        weeks.girlfriend.cameraOffsets = {
            x = weeks.girlfriend.cameraOffsets[1] + s.characters.gf.cameraOffsets[1],
            y = weeks.girlfriend.cameraOffsets[2] + s.characters.gf.cameraOffsets[2]
        }
        weeks.girlfriend.zIndex = s.characters.gf.zIndex
    end

    return s
end

function stage:build()
    --[[ self:call("onCreate") ]]
    for _, propitem in ipairs(self._props) do
        local prop = nil
        local _type = type
        local type = propitem.animType or defaultProps.animType
        if type == "sparrow" or type == "packer" then
            prop = graphics.newSparrowAtlas()
            local assetPath = propitem.assetPath
            if not assetPath:startsWith("#") then
                assetPath = self.directory .. "/images/" .. propitem.assetPath
            end
            prop:load(assetPath)
            prop:setAntialiasing(not propitem.isPixel)
            for _, anim in ipairs(propitem.animations or {}) do
                if type == "sparrow" then
                    if not prop.flipXAnims then
                        prop.flipXAnims = {}
                        prop.flipYAnims = {}
                    end
                    prop.flipXAnims[anim.name] = anim.flipX or false
                    prop.flipYAnims[anim.name] = anim.flipY or false

                    if anim.indiceFrames and #anim.indiceFrames > 0 then
                        prop:addAnimByIndices(
                            anim.name,
                            anim.prefix,
                            anim.indiceFrames,
                            anim.frameRate,
                            anim.looped
                        )
                    else
                        prop:addAnimByPrefix(
                            anim.name,
                            anim.prefix,
                            anim.frameRate,
                            anim.looped
                        )
                    end
                else
                    -- use addAnimByFrames(name, frames, framerate, loop)
                    prop:addAnimByFrames(
                        anim.name,
                        anim.frameIndices,
                        anim.frameRate,
                        anim.looped
                    )
                end
            end
        elseif type == "animateatlas" then
            prop = graphics.newTextureAtlas()
            local assetPath = propitem.assetPath
            if not assetPath:startsWith("#") then
                assetPath = "" .. self.directory .. "/images/" .. propitem.assetPath
            end
            prop:load(assetPath)
            --prop:setAntialiasing(not propitem.isPixel)
            for _, anim in ipairs(propitem.animations or {}) do
                if anim.animType == "symbol" then
                    -- not prefix
                    if anim.indiceFrames and #anim.indiceFrames > 0 then
                        prop:addAnimBySymbolIndices(
                            anim.name,
                            anim.prefix,
                            anim.indiceFrames,
                            anim.frameRate,
                            anim.looped
                        )
                    else
                        prop:addAnimBySymbol(
                            anim.name,
                            anim.prefix,
                            anim.frameRate,
                            anim.looped
                        )
                    end
                else
                    if anim.indiceFrames and #anim.indiceFrames > 0 then
                        prop:addAnimByIndices(
                            anim.name,
                            anim.prefix,
                            anim.indiceFrames,
                            anim.frameRate,
                            anim.looped
                        )
                    else
                        prop:addAnimByPrefix(
                            anim.name,
                            anim.prefix,
                            anim.frameRate,
                            anim.looped
                        )
                    end
                end
            end
        end
        
        if not prop then
            goto continue
        end

        prop.x = propitem.position[1]
        prop.y = propitem.position[2]
        if _type(propitem.scale) == "number" then
            prop.scale.x = propitem.scale
            prop.scale.y = propitem.scale
        else
            prop.scale.x = propitem.scale and propitem.scale[1] or 1
            prop.scale.y = propitem.scale and propitem.scale[2] or 1
        end
        prop.alpha = propitem.alpha or 1
        prop.zIndex = propitem.zIndex
        prop.name = propitem.name
        prop.thefuckinganim = propitem.startingAnimation
        prop:play(propitem.startingAnimation or "idle", true)
        prop.bopper = true

        prop:updateHitbox()

        self.props[propitem.name] = prop

        ::continue::
        --[[ weeks:add(prop) ]]
    end

    self:call("onCreate")

    self:call("build")

    for _, prop in pairs(self.props) do
        weeks:add(prop)
        self:call("addProp", prop, prop.name or "")
    end

    self:call("postCreate")

    weeks:sort()
end

function stage:new()
    self.props = {}
end

function stage:call(funcName, ...)
    if self.script and self.script[funcName] and type(self.script[funcName]) == "function" then
        return self.script[funcName](self.script, ...)
    end
    --HScript.main:call(funcName, ...)
    -- call Stage (class) fnname from interp
    --HScript.main:getClass("Stage"):call(funcName, ...)
end

return stage