--- SCRIPT_EVENT
ScriptEvent = Class:extend()

function ScriptEvent:new(type, cancelable)
    self.cancelable = cancelable or false
    self.type = type
    self.shouldPropogate = true
    self.eventCanceled = false

    local t = type
    if (
        t == "CREATE" or
        t == "DESTROY" or
        t == "UPDATE"
    ) then
        self.IScriptedClass = true
    elseif (
        t == "NOTE_INCOMING" or
        t == "NOTE_HIT" or
        t == "NOTE_MISS" or
        t == "NOTE_HOLD_DROP"
    ) then
        self.INoteScriptedClass = true
    elseif (
        t == "SONG_STEP_HIT" or
        t == "SONG_BEAT_HIT"
    ) then
        self.IBPMSyncedScriptedClass = true
    elseif (
        t == "SONG_LOADED" or
        t == "SONG_EVENT"
    ) then
        self.ISongScriptedClass = true
    elseif (
        t == "DIALOGUE_START" or
        t == "DIALOGUE_LINE" or
        t == "DIALOGUE_COMPLETE_LINE" or
        t == "DIALOGUE_SKIP" or
        t == "DIALOGUE_END"
    ) then
        self.IDialogueScriptedClass = true
    elseif (
        t == "ADDED" or
        t == "REMOVED"
    ) then
        self.IStateStageProp = true
    elseif (
        t == "STATE_CHANGE_BEGIN" or
        t == "STATE_CHANGE_END" or
        t == "SUB_STATE_OPEN_BEGIN" or
        t == "SUB_STATE_OPEN_END" or
        t == "SUB_STATE_CLOSE_BEGIN" or
        t == "SUB_STATE_CLOSE_END" or
        t == "FOCUS_LOST" or
        t == "FOCUS_GAINED"
    ) then
        self.IStateChangingScriptedClass = true
    elseif (
        t == "NOTE_GHOST_MISS"
    ) then
        self.IGhostMissNoteScriptedClass = true
    end
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
