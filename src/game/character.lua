local character = Object:extend()

local DEFAULT_DANCE_EVERY = 1
local DEFAULT_SING_TIME = 8

X_OFFSET_AMOUNT_FOR_SPITES = 25
Y_OFFSET_AMOUNT_FOR_SPRITES = 30

function character.getCharacter(id)
    local data = json.decode(love.filesystem.read("data/characters/" .. id .. ".json"))
    if not data.renderType then
        data.renderType = "sparrow"
    end

    local char

    if data.renderType == "sparrow" then
        char = SparrowCharacter(data)
    elseif data.renderType == "multisparrow" then
        char = MultiSparrowCharacter(data)
    elseif data.renderType == "animateatlas" then
        char = AnimateAtlasCharacter(data)
    elseif data.renderType == "multianimateatlas" then
        char = MultiAnimateAtlasCharacter(data)
    elseif data.renderType == "packer" then
    end

    char._data = data
    char.id = id
    char.name = char.id

    char.danceEvery = data.danceEvery or DEFAULT_DANCE_EVERY
    char.singTime = data.singTime or DEFAULT_SING_TIME
    char.offsets = data.offsets or {0, 0}
    char.scale = {x = data.scale or 1, y = data.scale or 1}

    char.script = nil

    char:setAntialiasing(not data.isPixel)

    local characterLuaChunk = love.filesystem.getInfo("data/scripts/characters/" .. char.id .. ".lua")
    local env = setmetatable({
        Character = {
            data = char,
        },
        add = function(obj)
            weeks:add(obj)
        end,
        remove = function(obj)
            weeks:remove(obj)
        end,
    }, {__index = _G})
    if characterLuaChunk then
        local chunk = love.filesystem.load("data/scripts/characters/" .. char.id .. ".lua")
        
        setfenv(chunk, env)
        chunk()
        char.script = env.Character
    end

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
        return self.script[funcName](self.script, ...)
    end
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
            self:dance(true)
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
    return self.sprite and self.sprite.curAnim and
        self.sprite.curAnim.name:startsWith("sing") and not self.sprite.curAnim.name:endsWith("-end")
end

function character:onBeatHit(beat) end

function character:dance(force)
    if self.isDead then return end
    if not force then
        if self:isSinging() then
            return
        end

        if self.sprite and self.sprite.curAnim then
            local currentAnimation = self.sprite.curAnim.name
            -- if not dance and not idle and not finishged, return
            if not currentAnimation:startsWith("dance") and not currentAnimation:startsWith("idle") and not self.sprite.animFinished then
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

return character