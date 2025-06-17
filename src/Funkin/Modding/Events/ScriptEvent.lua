ScriptEvent = Class:extend()

function ScriptEvent:new(type, cancelable)
    self.cancelable = cancelable or false
    self.type = type
    self.shouldPropogate = true
    self.eventCanceled = false
end

function ScriptEvent:cancelEvent()
    if self.cancelable then
        self.eventCanceled = true
    end
end

function ScriptEvent:cancel()
    self:cancelEvent()
end

function ScriptEvent:stopPropagation()
    self.shouldPropogate = false
end

function ScriptEvent:__tostring()
    return "ScriptEvent(type=" .. self.type .. ", cancelable=" .. tostring(self.cancelable) .. ")"
end

SongLoadScriptEvent = ScriptEvent:extend("SongLoadScriptEvent")

function SongLoadScriptEvent:new(id, difficulty, notes, events)
    SongLoadScriptEvent.super.new(self, "SONG_LOADED")
    
    self.id = id
    self.difficulty = difficulty
    self.notes = notes
    self.events = events
end

function SongLoadScriptEvent:__tostring()
    return "SongLoadScriptEvent(notes=" .. #self.notes .. ", id=" .. self.id .. ", difficulty=" .. self.difficulty .. ")"
end
