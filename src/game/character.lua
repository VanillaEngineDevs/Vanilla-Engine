local character = Object:extend()

local DEFAULT_DANCE_EVERY = 1
local DEFAULT_SING_TIME = 8

X_OFFSET_AMOUNT_FOR_SPITES = 25
Y_OFFSET_AMOUNT_FOR_SPRITES = 30

function character.getCharacter(id)
    print("Loading character: " .. id)
    local data = json.decode(love.filesystem.read("data/characters/" .. id .. ".json"))
    if not data.renderType then
        data.renderType = "sparrow"
    end

    local char

    print("Creating character of type: " .. data.renderType, id)

    local characterLuaChunk = love.filesystem.getInfo("data/scripts/characters/" .. id .. ".lua")
    local env = setmetatable({
        Character = {
            --[[ data = char, ]]
        },
        add = function(obj)
            weeks:add(obj)
        end,
        remove = function(obj)
            weeks:remove(obj)
        end,
    }, {__index = _G})
    if characterLuaChunk then
        local chunk = love.filesystem.load("data/scripts/characters/" .. id .. ".lua")
        
        setfenv(chunk, env)
        chunk()
        --char.script = env.Character
    end

    local _atlasSettings = {}
    if env.Character and env.Character.getAtlasSettings then
        _atlasSettings = env.Character:getAtlasSettings()
    else
        _atlasSettings = {}
    end

    if data.renderType == "sparrow" then
        char = SparrowCharacter(data)
    elseif data.renderType == "multisparrow" then
        char = MultiSparrowCharacter(data)
    elseif data.renderType == "animateatlas" then
        char = AnimateAtlasCharacter(data, _atlasSettings)
    elseif data.renderType == "multianimateatlas" then
        char = MultiAnimateAtlasCharacter(data, _atlasSettings)
    elseif data.renderType == "packer" then
    end

    -- set Character.data now
    env.Character.data = char
    char.script = env.Character

    char.onFrameChange = signal.new()
    char.onAnimationFinished = signal.new()

    char.onFrameChange:connect(function(name, frameNumber, frameIndex)
        char:call("onAnimationFrame", name, frameNumber, frameIndex)
    end)
    char.onAnimationFinished:connect(function(name)
        char:call("onAnimationFinished", name)
    end)

    char._data = data
    char.id = id
    char.name = char.id

    char.danceEvery = data.danceEvery or DEFAULT_DANCE_EVERY
    char.singTime = data.singTime or DEFAULT_SING_TIME
    char.offsets = data.offsets or {0, 0}
    char.scale = {x = data.scale or 1, y = data.scale or 1}

    char:setAntialiasing(not data.isPixel)

    char:call("onCreate")

    return char
end

CHARACTER_TYPE = {
    DAD = "dad",
    BF = "bf",
    GF = "gf",
    OTHER = "other"
}

function character:call(funcName, ...)
    if self.script and self.script[funcName] and type(self.script[funcName]) == "function" then
        self.inScriptCall = true
        local result = self.script[funcName](self.script, ...)
        self.inScriptCall = false
        return result
    end
end

function character:isFunction(name)
    return self.script and self.script[name] and type(self.script[name]) == "function"
end

function character:new()
    self.danceEvery = 0
    self.shouldAlternate = nil
    self.animOffsets = {}
    self.idleSuffix = ""
    self.isPixel = false
    self.shouldBop = false
    self.globalOffsets = {0, 0}
    self.hasDanced = false
    self.characterType = CHARACTER_TYPE.BF

    self.x = 0
    self.y = 0
    self.origin = {x = 0, y = 0}
    self.cameraOffsets = {x = 0, y = 0}
    self.scroll = {x = 1, y = 1}
    self.curAnimOffset = {0, 0}

    self.holdTimer = 0
    self.danceEvery = 2
    self.singTime = 8
    self.offsets = {0, 0}
    self.visible = true

    self.flipX = false
    self.flipY = false

    self.zIndex = 0
end

function character:update(dt)
    if self.characterType == CHARACTER_TYPE.BF and self:justPressedNote() then
        self.holdTimer = 0
    end

    if self.sprite.animFinished
            and self.sprite.curAnim
            and not self.sprite.curAnim.name:endsWith("-hold")
        and self.sprite:hasAnimation(self.sprite.curAnim.name .. "-hold") then

        self:play(self.sprite.curAnim.name .. "-hold", true, true)
    end

    if self:isSinging() then
        self.holdTimer = self.holdTimer + dt
        local singTimeSec = self.singTime * Conductor.getBeatLengthsMS() / 1000
        singTimeSec = singTimeSec / 10 + 0.2

        if self.sprite and self.sprite.curAnim and self.sprite.curAnim.name:endsWith("-miss") then
            singTimeSec = singTimeSec * 2
        end

        -- should stop should default to true if not boyfriend
        local shouldstop = true
        if self.characterType == CHARACTER_TYPE.BF then
            local isHolding = self:isHoldingNote()
            shouldstop = not isHolding
        end
        if self.holdTimer >= singTimeSec and shouldstop then
            self.holdTimer = 0

            local currentAnimation = self.sprite and self.sprite.curAnim and self.sprite.curAnim.name or ""
            if currentAnimation:endsWith("-hold") then
                currentAnimation = currentAnimation:sub(1, #currentAnimation - #(" -hold"))
            end
            local endAnimation = currentAnimation .. "-end"
            --self:dance(false)
        end
    else
        self.holdTimer = 0
    end
end

function character:isHoldingNote()
    local inputLeft = input:down("gameLeft")
    local inputDown = input:down("gameDown")
    local inputUp = input:down("gameUp")
    local inputRight = input:down("gameRight")

    return inputLeft or inputDown or inputUp or inputRight
end

function character:justPressedNote()
    local inputLeft = input:pressed("gameLeft")
    local inputDown = input:pressed("gameDown")
    local inputUp = input:pressed("gameUp")
    local inputRight = input:pressed("gameRight")

    return inputLeft or inputDown or inputUp or inputRight
end

function character:onStepHit(step)
    if (self.danceEvery > 0 and (step % (self.danceEvery * CONSTANTS.STEPS_PER_BEAT) == 0)) then
        if not self.sprite.animFinished and self.sprite.curAnim then
            local isidledance = self.sprite.curAnim.name:startsWith("dance") or self.sprite.curAnim.name:startsWith("idle")

            if not isidledance then
                return
            end
        end
        self:dance(self.shouldBop)
    end
end

function character:getCameraPoint()
    local centerX = self.x + self.width/2
    local centerY = self.y + self.height/2

    return {
        x = centerX + self.cameraOffsets.x,
        y = centerY + self.cameraOffsets.y
    }
end

function character:isSinging()
    if not self.sprite or not self.sprite.curAnim then
        return false
    end

    if self.sprite.curAnim.name:endsWith("-hold") then
        return false
    end

    if self.sprite.curAnim.name:startsWith("sing") and not self.sprite.curAnim.name:endsWith("-end") then
        if self.sprite.animFinished then return false end

        return true
    end

    if not self.sprite.curAnim.name:startsWith("sing") and self.sprite.animFinished then
        return false
    end

    return true
end

function character:onBeatHit(beat) end

function character:dance(force)
    if self:isFunction("dance") and not self.inScriptCall then
        self:call("dance", force)
        return
    end

    if self.isDead then return end

    if not force then
        if self:isSinging() then
            return
        end

        if self.sprite and self.sprite.curAnim then
            local currentAnimation = self.sprite.curAnim.name
            if not currentAnimation:startsWith("dance") and not currentAnimation:startsWith("idle") and not
                currentAnimation:endsWith("-hold") and not self.sprite.animFinished
            and not currentAnimation == "__raw__" then
                return
            end
        end
    end

    if self.shouldAlternate then
        if self.hasDanced then
            self:play("danceRight" .. self.idleSuffix, force, false)
        else
            self:play("danceLeft" .. self.idleSuffix, force, false)
        end
        self.hasDanced = not self.hasDanced
    else
        self:play("idle", force, false)
    end
end

function character:getDeathCameraOffsets()
    if self._data.death and self._data.death.cameraOffsets then
        return self._data.death.cameraOffsets
    end

    return {0, 0}
end

function character:getDeathCameraZoom()
    if self._data.death and self._data.death.cameraZoom then
        return self._data.death.cameraZoom
    end
    return 1
end

function character:getDeathPreTransitionDelay()
    if self._data.death and self._data.death.preTransitionDelay then
        return self._data.death.preTransitionDelay
    end
    return 0
end

function character:hasAnimation(name)
    return self.sprite:hasAnimation(name)
end

function character:getDeathQuote()
    -- the script for getDeathQuote() CAN return something!
    -- its like char:call("getDeathQuote"), but we can get what is returned
    if self:isFunction("getDeathQuote") then
        return self.script["getDeathQuote"](self.script)
    end

    return nil
end

--[[ function character:getAtlasSettings()
    if self:isFunction("getAtlasSettings") then
        return self:call("getAtlasSettings")
    end
end ]]

return character