local LipSyncSprite = require("data.scripts.props.sserafimLipSyncSprite")
local lipSyncSprite = nil

function Character:onCreate()
    lipSyncSprite = LipSyncSprite(113, -120, '')
    lipSyncSprite.active = false
    lipSyncSprite.flipX = true
    lipSyncSprite.angle = math.rad(10)

    self.data.sprite:addElementToFrames("mouth default", lipSyncSprite.sprite)
end

function Character:onUpdate(dt)
    if not lipSyncSprite then return end
    lipSyncSprite.shouldSing = self.data.characterType == CHARACTER_TYPE.BF
    lipSyncSprite:update(dt)
end

local offsets = {
    idle = {
        offset = {0, 0},
        angle = 10
    },
    singUP = {
        offset = {0, -2},
        angle = 10
    },
    singRIGHT = {
        offset = {0, 0},
        angle = 10
    },
    singDOWN = {
        offset = {0, 0},
        angle = 10
    },
    singLEFT = {
        offset = {0, 0},
        angle = 10
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
