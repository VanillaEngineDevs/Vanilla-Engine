local BaseStage = Object:extend()

BaseStage.game = PlayState

BaseStage.onPlayState = false

BaseStage.paused = false
BaseStage.songName = ""
BaseStage.isStoryMode = false
BaseStage.seenCutscene = true
BaseStage.inCutscene = false
BaseStage.canPause = true
BaseStage.members = {}

BaseStage.boyfriend = nil
BaseStage.dad = nil
BaseStage.gf = nil
BaseStage.boyfriend = nil
BaseStage.dad = nil
BaseStage.gf = nil

BaseStage.camGame = nil
BaseStage.camHUD = nil
BaseStage.camOther = nil

BaseStage.defaultCamZoom = 1.05
BaseStage.camFollow = nil

function BaseStage:new()
    self.game = PlayState
    --self.game = MusicBeatState:getState()
    self:create()
end

function BaseStage:create() end
function BaseStage:createPost() end
function BaseStage:countdownTick(count, num) end

BaseStage.curBeat = 0
BaseStage.curDecBeat = 0
BaseStage.curStep = 0
BaseStage.curDecStep = 0
BaseStage.curSection = 0

function BaseStage:update(dt) end

function BaseStage:beatHit() end
function BaseStage:stepHit() end
function BaseStage:sectionHit() end

function BaseStage:closeSubstate() end
function BaseStage:openSubstate(substate) end

function BaseStage:eventCalled(eventName, value1, value2, flValue1, flValue2, strumTime) end
function BaseStage:eventPushed(event) end
function BaseStage:eventPushedUnique(event) end

function BaseStage:add(object) self.game:add(object) end
function BaseStage:remove(object) self.game:remove(object) end
function BaseStage:insert(position, object) self.game:insert(position, object) end

function BaseStage:addBehindGF(object)
    -- get index of gf
    local gfIndex = 0
    for i, member in ipairs(self.game.members) do
        if member == PlayState.gf then
            gfIndex = i
            break
        end
    end

    -- insert object behind gf
    self:insert(gfIndex, object)
end

function BaseStage:addBehindBF(obj)
    local bfIndex = 0
    for i, member in ipairs(self.game.members) do
        if member == PlayState.boyfriend then
            bfIndex = i
            break
        end
    end

    self:insert(bfIndex, obj)
end

function BaseStage:addBehindDad(obj)
    local dadIndex = 0
    for i, member in ipairs(self.game.members) do
        if member == PlayState.dad then
            dadIndex = i
            break
        end
    end

    self:insert(dadIndex, obj)
end

function BaseStage:setDefaultGF(name)
    local gfVersion = PlayState.SONG.gfVersion
    if not gfVersion or #gfVersion < 1 then
        gfVersion = name
        PlayState.SONG.gfVersion = gfVersion
    end
end

return BaseStage