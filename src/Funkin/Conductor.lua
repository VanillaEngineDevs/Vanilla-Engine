---@diagnostic disable: undefined-doc-name
--- FNF Conductor class
---@class Conductor
---@field private prevTimestamp number 
Conductor = {}
--[[
    onBeatHit is called every quarter note
    onStepHit is called every sixteenth note
    4/4 = 4 beats per measure = 16 steps per measure
        120 BPM = 120 quarter notes per minute = 2 onBeatHit per second
        120 BPM = 480 sixteenth notes per minute = 8 onStepHit per second
        60 BPM = 60 quarter notes per minute = 1 onBeatHit per second
        60 BPM = 240 sixteenth notes per minute = 4 onStepHit per second
    3/4 = 3 beats per measure = 12 steps per measure
        (IDENTICAL TO 4/4 but shorter measure length)
        120 BPM = 120 quarter notes per minute = 2 onBeatHit per second
        120 BPM = 480 sixteenth notes per minute = 8 onStepHit per second
        60 BPM = 60 quarter notes per minute = 1 onBeatHit per second
        60 BPM = 240 sixteenth notes per minute = 4 onStepHit per second
    7/8 = 3.5 beats per measure = 14 steps per measure
]]

Conductor.measureHit = Signal()   ---@type Signal
Conductor.onMeasureHit = Signal() ---@type Signal
Conductor.beatHit = Signal()      ---@type Signal
Conductor.onBeatHit = Signal()    ---@type Signal
Conductor.stepHit = Signal()      ---@type Signal
Conductor.onStepHit = Signal()    ---@type Signal

Conductor.timeChanges = {}

Conductor.currentTimeChange = nil

---@alias float number

---@type float
Conductor.songPosition = 0.0

---@type float
---@private
Conductor.prevTimestamp = 0.0

---@type float
---@private
Conductor.prevTime = 0.0

---@type float
Conductor.bpm = 0.0

---@return float
function Conductor.get_bpm()
    if Conductor.bpmOverride ~= nil then return Conductor.bpmOverride end

    if Conductor.currentTimeChange ~= nil then return Constants.DEFAULT_BPM end

    return Conductor.bpm
end

---@type float
Conductor.startingBPM = 0.0

---@return float
function Conductor.get_startingBPM()
    if Conductor.bpmOverride ~= nil then return Conductor.bpmOverride end

    local timechange = Conductor.timeChanges[1]
    if timechange == nil then return Constants.DEFAULT_BPM end

    return timechange.bpm
end

---@type (float | nil)
Conductor.bpmOverride = nil

function Conductor.get_measureLengthsMs()
    return Conductor.get_beatLengthMs() * Conductor.get_timeSignatureNumerator()
end

function Conductor.get_beatLengthMs()
    return (Constants.SECS_PER_MIN / Conductor.get_bpm()) * Constants.MS_PER_SEC
end

function Conductor.get_timeSignatureNumerator()
    if Conductor.currentTimeChange == nil then return Constants.DEFAULT_TIME_SIGNATURE_NUM end

    ---@diagnostic disable-next-line: undefined-field
    return Conductor.currentTimeChange.timeSignatureNum
end

function Conductor.get_stepLengthMs()
    return Conductor.get_beatLengthMs() / Conductor.get_timeSignatureNumerator()
end

function Conductor.get_timeSignatureDenominator()
    if Conductor.currentTimeChange == nil then return Constants.DEFAULT_TIME_SIGNATURE_DEN end

    ---@diagnostic disable-next-line: undefined-field
    return Conductor.currentTimeChange.timeSignatureDen
end

Conductor.currentMeasure = 0
Conductor.currentBeat = 0
Conductor.currentStep = 0
Conductor.currentBeatTime = 0
Conductor.currentStepTime = {}
Conductor.instrumentalOffset = 0

function Conductor.get_instrumentalOffsetSteps()
    local startingStepLengthMs = ((Constants.SECS_PER_MIN / Conductor.startingBPM) * Constants.MS_PER_SEC) / Conductor.get_timeSignatureNumerator()

    return Conductor.instrumentalOffset / startingStepLengthMs
end

Conductor.inputOffset = 0
Conductor.formatOffset = 0
Conductor.audioVisualOffset = 0 

function Conductor.get_beatsPerMeasure()
    return Conductor.get_stepsPerMeasure() / Constants.STEPS_PER_BEAT
end

function Conductor.get_stepsPerMeasure()
    return math.floor(Conductor.get_timeSignatureNumerator() / Conductor.get_timeSignatureDenominator() * Constants.STEPS_PER_BEAT * Constants.STEPS_PER_BEAT)
end

function Conductor:dispatchMeasureHit()
    Conductor.measureHit:dispatch()
end

function Conductor:dispatchBeatHit()
    Conductor.beatHit:dispatch()
end

function Conductor:dispatchStepHit()
    Conductor.stepHit:dispatch()
end

Conductor.onBeatHit:add(Conductor.dispatchBeatHit, Conductor)
Conductor.onStepHit:add(Conductor.dispatchStepHit, Conductor)
Conductor.onMeasureHit:add(Conductor.dispatchMeasureHit, Conductor)

---@param bpm? (float|nil)
function Conductor:forceBPM(bpm)
    if bpm ~= nil then
        print("FORCING BPM TO " .. bpm)
    else
        print("RESETTING BPM TO DEFAULT")
    end
    self.bpmOverride = bpm or Constants.DEFAULT_BPM
end

function Conductor:update(songPos, applyOffsets, forceDispatch)
    local songPos = songPos or Game.sound.music and Game.sound.music:tell() * 1000 or 0

    songPos = songPos + (applyOffsets and (self.instrumentalOffset + self.formatOffset + self.audioVisualOffset) or 0)

    local oldMeasure = self.currentMeasure
    local oldBeat = self.currentBeat
    local oldStep = self.currentStep

    self.songPosition = songPos
    self.currentTimeChange = self.timeChanges[1]
    if self.songPosition > 0 then
        for i = 1, #self.timeChanges do
            if self.songPosition >= self.timeChanges[i].timeStamp then
                self.currentTimeChange = self.timeChanges[i]
            end

            if self.songPosition < self.timeChanges[i].timeStamp then break end
        end
    end

    if self.currentTimeChange ~= nil and Game.sound.music ~= nil then
        self.currentStepTime = (self.currentTimeChange.beatTime * Constants.STEPS_PER_BEAT) + (self.songPosition - self.currentTimeChange.timeStamp) / self.get_stepLengthMs()
        self.currentBeatTime = self.currentStepTime / Constants.STEPS_PER_BEAT
        self.currentMeasureTime = self.currentStepTime / self.currentBeatTime
        self.currentStep = math.floor(self.currentStepTime)
        self.currentBeat = math.floor(self.currentBeatTime)
        self.currentMeasure = math.floor(self.currentMeasureTime)
    end

    if self.currentStep ~= oldStep then
        self.onStepHit:dispatch()
    end
    if self.currentBeat ~= oldBeat then
        self.onBeatHit:dispatch()
    end
    if self.currentMeasure ~= oldMeasure then
        self.onMeasureHit:dispatch()
    end

    if self.prevTime ~= self.songPosition then
        self.prevTime = self.songPosition
        self.prevTimestamp = math.floor(love.timer.getTime() * 1000)
    end
end

function Conductor:mapTimeChanges(songTimeChanges)
    local songTimeChanges = songTimeChanges.timeChanges
    self.timeChanges = {}

    table.sort(songTimeChanges, function(a, b)
        return a.t > b.t
    end)

    for _, songTimeChange in ipairs(songTimeChanges) do
        songTimeChange.timeStamp = songTimeChange.t
        songTimeChange.beatTime = songTimeChange.b
        songTimeChange.timeSignatureNum = songTimeChange.n
        songTimeChange.timeSignatureDen = songTimeChange.d
        if songTimeChange.timeStamp < 0 then songTimeChange = 0 end

        if songTimeChange.timeStamp <= 0 then
            songTimeChange.beatTime = 0
        else
            songTimeChange.beatTime = 0

            local prevTimeChange = self.timeChanges[#self.timeChanges]
            songTimeChange.beatTime = prevTimeChange.beatTime + ((songTimeChange.timeStamp - prevTimeChange.timeStamp) * prevTimeChange.bpm / Constants.SECS_PER_MIN / Constants.MS_PER_SEC)
        end

        table.insert(self.timeChanges, songTimeChange)
    end

    if #self.timeChanges > 0 then
        print("Done mapping time changes: " .. #self.timeChanges)
    end

    self:update(self.songPosition, false)
end

return Conductor