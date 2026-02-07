local LipSyncSprite = require("assets.data.scripts.props.sserafimLipSyncSprite")
local lipSyncSprite = nil

function Character:onCreate()
    lipSyncSprite = LipSyncSprite(-67, -140, '-yunjin')
    lipSyncSprite.active = false
    lipSyncSprite.angle = math.rad(23)

    self.data.sprite:addElementToFrames("mouth yunjin", lipSyncSprite.sprite)
end

function Character:onUpdate(dt)
    if not lipSyncSprite then return end
    lipSyncSprite.shouldSing = self.data.characterType == CHARACTER_TYPE.BF
    lipSyncSprite:update(dt)
end

local offsets = {
    idle = {
        offset = {0, 0},
        angle = 23
    },
    singUP = {
        offset = {0, 0},
        angle = 22
    },
    singRIGHT = {
        offset = {0, 0},
        angle = 23
    },
    singDOWN = {
        offset = {0, 0},
        angle = 23
    },
    singLEFT = {
        offset = {0, 0},
        angle = 23
    }
}

function Character:play(name, force, loop)
    self.data:play(name, force, loop)

    if offsets[name] then
        lipSyncSprite.offsets = offsets[name].offset
        lipSyncSprite.angle = math.rad(offsets[name].angle)
    else
        lipSyncSprite.offsets = {0, 0}
        lipSyncSprite.angle = 0
    end
end
