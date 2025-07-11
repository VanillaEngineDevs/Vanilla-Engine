---@class MusicBeatState : TransitionableState
local MusicBeatState = TransitionableState:extend()

function MusicBeatState:new()
    self.leftWatermarkText = nil
    self.rightWatermarkText = nil
    self.ConductorInUse = nil

    TransitionableState.new(self)

    --[[ self:initCallbacks() ]]
end

function MusicBeatState:create()
    TransitionableState.create(self)

    self:createWatermarkText()

    Conductor.beatHit:add(self.beatHit, self)
    Conductor.stepHit:add(self.stepHit, self)
end

function MusicBeatState:destroy()
    TransitionableState.destroy(self)

    Conductor.beatHit:remove(self.beatHit)
    Conductor.stepHit:remove(self.stepHit)
end

---@param dt number
function MusicBeatState:update(dt)
    TransitionableState.update(self, dt)
end

function MusicBeatState:createWatermarkText()
    -- TODO: Implement FlxText
end

function MusicBeatState:dispatchEvent(event)
    ModuleHandler:callEvent(event)
end

function MusicBeatState:stepHit()
    local event = SongTimeScriptEvent("SONG_STEP_HIT", Conductor.currentBeat, Conductor.currentStep)
    self:dispatchEvent(event)

    if event.eventCanceled then return false end

    return true
end

function MusicBeatState:beatHit()
    local event = SongTimeScriptEvent("SONG_BEAT_HIT", Conductor.currentBeat, Conductor.currentStep)

    self:dispatchEvent(event)

    if event.eventCanceled then return false end

    return true
end

return MusicBeatState