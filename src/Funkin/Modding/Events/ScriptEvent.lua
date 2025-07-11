--- SCRIPT_EVENT
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

--- NOTE_SCRIPT_EVENT
NoteScriptEvent = ScriptEvent:extend("NoteScriptEvent")

function NoteScriptEvent:new(type, note, healthChange, comboCount, cancelable)
    ScriptEvent.new(self, type, cancelable)
    self.note = note
    self.comboCount = comboCount or 0
    self.playSound = cancelable == nil and false or cancelable
    self.healthChange = healthChange or 0
end

--- HIT_NOTE_SCRIPT_EVENT
HitNoteScriptEvent = NoteScriptEvent:extend("HitNoteScriptEvent")

function HitNoteScriptEvent:new(note, healthChange, score, judgement, isComboBreak, comboCount, hitDiff, doesNotesplash)
    NoteScriptEvent.new(self, "NOTE_HIT", note, healthChange, comboCount, true)
    self.score = score or 0
    self.judgement = judgement or "NONE"
    self.isComboBreak = isComboBreak or false
    self.hitDiff = hitDiff or 0
    self.doesNotesplash = doesNotesplash == nil and false or doesNotesplash
end

--- GHOST_MISS_NOT_SCRIPT_EVENT
GhostMissNoteScriptEvent = ScriptEvent:extend("GhostMissNoteScriptEvent")
function GhostMissNoteScriptEvent:new(dir, hasPossibleNotes, healthChange, scoreChange)
    ScriptEvent.new(self, "NOTE_GHOST_MISS", true)
    self.dir = dir
    self.hasPossibleNotes = hasPossibleNotes or false
    self.healthChange = healthChange or 0
    self.scoreChange = scoreChange or 0
    self.playSound = true
    self.playAnim = true
end

--- HOLD_NOTE_SCRIPT_EVENT
HoldNoteScriptEvent = NoteScriptEvent:extend("HoldNoteScriptEvent")
function HoldNoteScriptEvent:new(type, holdNote, healthChange, score, isComboBreak, cancelable)
    NoteScriptEvent.new(self, type, nil, healthChange, 0, true)
    self.holdNote = holdNote
    self.score = score or 0
    self.isComboBreak = isComboBreak or false
end

--- SONG_LOAD_SCRIPT_EVENT
SongLoadScriptEvent = ScriptEvent:extend("SongLoadScriptEvent")

function SongLoadScriptEvent:new(id, difficulty, notes, events)
    print("SongLoadScriptEvent created with id: " .. id .. ", difficulty: " .. difficulty)
    SongLoadScriptEvent.super.new(self, "SONG_LOADED")
    self.id = id
    self.difficulty = difficulty
    self.notes = notes
    oPrint(#self.notes .. " notes loaded for song " .. id .. " with difficulty " .. difficulty)
    self.events = events
end

function SongLoadScriptEvent:__tostring()
    return "SongLoadScriptEvent(notes=" .. #self.notes .. ", id=" .. self.id .. ", difficulty=" .. self.difficulty .. ")"
end

-- SONG_EVENT_SCRIPT_EVENT
SongEventScriptEvent = ScriptEvent:extend("SongEventScriptEvent")
function SongEventScriptEvent:new(eventData)
    ScriptEvent.new(self, "SONG_EVENT", true)
    self.eventData = eventData or {}
end

-- UPDATE_SCRIPT_EVENT
UpdateScriptEvent = ScriptEvent:extend("UpdateScriptEvent")
function UpdateScriptEvent:new(dt)
    ScriptEvent.new(self, "UPDATE", true)
    self.dt = dt or 0
end

-- SONG_TIME_SCRIPT_EVENT
SongTimeScriptEvent = ScriptEvent:extend("SongTimeScriptEvent")
function SongTimeScriptEvent:new(type, beat, step)
    ScriptEvent.new(self, type, true)
    self.beat = beat or 0
    self.step = step or 0
end

--- COUNTDOWN_SCRIPT_EVENT
CountdownScriptEvent = ScriptEvent:extend("CountdownScriptEvent")
function CountdownScriptEvent:new(type, step, cancelable)
    ScriptEvent.new(self, type, cancelable)
    self.step = step or 0
end
