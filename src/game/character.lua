local character = Object:extend()

local DEFAULT_DANCE_EVERY = 1
local DEFAULT_SING_TIME = 8

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

    return char
end

CHARACTER_TYPE = {
    DAD = "dad",
    BF = "bf",
    GF = "gf"
}

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
    self.scale = {x = 1, y = 1}
    self.cameraOffsets = {x = 0, y = 0}
    self.scroll = {x = 1, y = 1}
    self.curAnimOffset = {0, 0}
end

function character:update(dt)
end

function character:onStepHit(step)
    if self.danceEvery > 0 then
        local interval = self.danceEvery * CONSTANTS.STEPS_PER_BEAT
        -- Only dance on exact multiples of interval
        if step % interval == 0 then
            self:dance(self.shouldBop)
        end
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

function character:onBeatHit(beat) end

function character:dance(forceRestart)
    forceRestart = false
    if self.shouldAlternate then
        if self.hasDanced then
            print("GOING RIGHT")
            self:play("danceRight" .. self.idleSuffix, forceRestart, false)
        else
            print("GOING LEFT")
            self:play("danceLeft" .. self.idleSuffix, forceRestart, false)
        end
        self.hasDanced = not self.hasDanced
    else
        self:play("idle", forceRestart, false)
    end
end

return character