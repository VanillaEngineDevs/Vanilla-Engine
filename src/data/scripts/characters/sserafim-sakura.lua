local LipSyncSprite = require("data.scripts.props.sserafimLipSyncSprite")
local lipSyncSprite = nil

function Character:onCreate()
    self.data.sprite:play("idle", true, false)
    lipSyncSprite = LipSyncSprite(-200, -200, '')
    lipSyncSprite.active = false
    lipSyncSprite.flipX = false
    self.data.sprite.lipSync = lipSyncSprite

    self.data.sprite:addElementToFrames("mouth edit", lipSyncSprite.sprite)
end

function Character:onUpdate(dt)
    if not lipSyncSprite then return end
    lipSyncSprite.shouldSing = self.data.characterType == CHARACTER_TYPE.BF
    lipSyncSprite:update(dt)
end

local offsets = {
    idle = {
        offset = {0, 0},
        angle = -14
    },
    singUP = {
        offset = {0, 0},
        angle = -15
    },
    singRIGHT = {
        offset = {0, 0},
        angle = -15
    },
    singDOWN = {
        offset = {0, 0},
        angle = -14
    },
    singLEFT = {
        offset = {0, 0},
        angle = -14
    },
    ["singUP-joint"] = {
        offset = {0, 0},
        angle = -14
    },
    ["singRIGHT-joint"] = {
        offset = {0, 0},
        angle = -15
    },
    ["singDOWN-joint"] = {
        offset = {0, 0},
        angle = -15
    },
    ["singLEFT-joint"] = {
        offset = {0, 0},
        angle = -16
    },
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

function Character:onNoteHit(event)
    if event.noteType == "sakura-joint" then
        self.data:play(CONSTANTS.WEEKS.ANIM_LIST[event.direction] .. "-joint", true, false)
    elseif event.noteType == "sakura-bf1" then
        self.data:play(CONSTANTS.WEEKS.ANIM_LIST[event.direction] .. "-bf1", true, false)
    elseif event.noteType == "sakura-bf2" then
        self.data:play(CONSTANTS.WEEKS.ANIM_LIST[event.direction] .. "-bf2", true, false)
    end
end
