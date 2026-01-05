---@diagnostic disable: need-check-nil
local stage = Object:extend()

local defaultBF = {
    zIndex = 300,
    position = {989.5, 885},
    cameraOffsets = {-100, -100},
    scale = {1, 1},
    scroll = {1, 1}
}

local defaultEnemy = {
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
    s.version = data.version or "1.0.0"
    s.characters = data.characters or {}
    s.characters.bf = data.characters.bf or {}
    for k, v in pairs(defaultBF) do
        if s.characters.bf[k] == nil then
            s.characters.bf[k] = v
        end
    end
    s.characters.enemy = data.characters.enemy or {}
    for k, v in pairs(defaultEnemy) do
        if s.characters.enemy[k] == nil then
            s.characters.enemy[k] = v
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

    local stageLuaChunk = love.filesystem.getInfo("stages/" .. s.id .. ".lua")
    if stageLuaChunk then
        local chunk = love.filesystem.load("stages/" .. s.id .. ".lua")
        chunk()(s)
    end

    enemy.x = s.characters.enemy.position[1]
    enemy.y = s.characters.enemy.position[2]
    enemy.scroll = {
        x = s.characters.enemy.scroll[1],
        y = s.characters.enemy.scroll[2]
    }
    enemy.scale = {
        x = s.characters.enemy.scale[1],
        y = s.characters.enemy.scale[2]
    }
    enemy.cameraOffsets = {
        x = s.characters.enemy.cameraOffsets[1],
        y = s.characters.enemy.cameraOffsets[2]
    }
    enemy.zIndex = s.characters.enemy.zIndex

    boyfriend.x = s.characters.bf.position[1]
    boyfriend.y = s.characters.bf.position[2]
    boyfriend.scroll = {
        x = s.characters.bf.scroll[1],
        y = s.characters.bf.scroll[2]
    }
    boyfriend.scale = {
        x = s.characters.bf.scale[1],
        y = s.characters.bf.scale[2]
    }
    boyfriend.cameraOffsets = {
        x = s.characters.bf.cameraOffsets[1],
        y = s.characters.bf.cameraOffsets[2]
    }
    boyfriend.zIndex = s.characters.bf.zIndex

    girlfriend.x = s.characters.gf.position[1]
    girlfriend.y = s.characters.gf.position[2]
    girlfriend.scroll = {
        x = s.characters.gf.scroll[1],
        y = s.characters.gf.scroll[2]
    }
    girlfriend.scale = {
        x = s.characters.gf.scale[1],
        y = s.characters.gf.scale[2]
    }
    girlfriend.cameraOffsets = {
        x = s.characters.gf.cameraOffsets[1],
        y = s.characters.gf.cameraOffsets[2]
    }
    girlfriend.zIndex = s.characters.gf.zIndex

    for i, propitem in ipairs(s._props) do
        local prop = nil
        local type = propitem.animType or defaultProps.animType
        if type == "sparrow" then
            prop = graphics.newSparrowAtlas()
            local assetPath = propitem.assetPath
            if not assetPath:startsWith("#") then
                assetPath = s.directory .. "/images/" .. propitem.assetPath
            end
            print(assetPath)
            prop:load(assetPath)
            for _, anim in ipairs(propitem.animations or {}) do
                if #anim.indiceFrames > 0 then
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

        prop.x = propitem.position[1]
        prop.y = propitem.position[2]
        prop.scale.x = propitem.scale[1]
        prop.scale.y = propitem.scale[2]
        prop.alpha = propitem.alpha or 1
        ---@diagnostic disable-next-line: inject-field
        prop.zIndex = propitem.zIndex
        prop:play(propitem.startingAnimation or "idle", true)

        s.props[propitem.name] = prop

        weeks:add(prop)
    end

    weeks:sort()

    return s
end

function stage:new()
    self.props = {}
end

return stage