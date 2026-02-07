local Conductor = {}
Conductor.__index = Conductor

Conductor.ROWS_PER_BEAT = 48
Conductor.BEATS_PER_MEASURE = 4
Conductor.ROWS_PER_MEASURE = Conductor.ROWS_PER_BEAT * Conductor.BEATS_PER_MEASURE
Conductor.MAX_NOTE_ROW = bit.lshift(1, 30)

function Conductor.new(bpm)
    local self = setmetatable({}, Conductor)

    self.bpm = bpm or 100
    self.crotchet = (60 / self.bpm) * 1000
    self.stepCrotchet = self.crotchet / 4

    self.musicTime = 0

    self.curStep = 0
    self.curBeat = 0
    self.curDecStep = 0
    self.curDecBeat = 0

    self.stepsToDo = 0
    self.curSection = 0
    self.lastSongPos = 0
    self.offset = 0

    self.bpmChangeMap = {}

    self.onStep = false
    self.onBeat = false
    self.onSection = false

    return self
end

function Conductor.beatToRow(beat)
    return math.floor(beat * Conductor.ROWS_PER_BEAT + 0.5)
end

function Conductor.rowToBeat(row)
    return row / Conductor.ROWS_PER_BEAT
end

function Conductor.secsToRow(secs, conductor)
    return math.floor(conductor:getBeat(secs) * Conductor.ROWS_PER_BEAT + 0.5)
end

function Conductor.beatToNoteRow(beat)
    return math.floor(beat * Conductor.ROWS_PER_BEAT + 0.5)
end

function Conductor.noteRowToBeat(row)
    return row / Conductor.ROWS_PER_BEAT
end

function Conductor:calculateCrochet(bpm)
    return (60 / bpm) * 1000
end

function Conductor:getBeatLengthsMS()
    return (60 / self.bpm) * 1000
end

function Conductor:getStepLengthMs()
    return (60 / self.bpm) * 1000 / 4
end

function Conductor:changeBPM(newBpm)
    self.bpm = newBpm
    self.crotchet = self:calculateCrochet(newBpm)
    self.stepCrotchet = self.crotchet / 4
end

Conductor.setBPM = Conductor.changeBPM

function Conductor:getBPMFromSeconds(time)
    local lastChange = {
        stepTime = 0,
        songTime = 0,
        bpm = self.bpm,
        stepCrotchet = self.stepCrotchet
    }

    for _, change in ipairs(self.bpmChangeMap) do
        if time >= change.songTime then
            lastChange = change
        end
    end

    return lastChange
end

function Conductor:getBPMFromStep(step)
    local lastChange = {
        stepTime = 0,
        songTime = 0,
        bpm = self.bpm,
        stepCrotchet = self.stepCrotchet
    }

    for _, change in ipairs(self.bpmChangeMap) do
        if change.stepTime <= step then
            lastChange = change
        end
    end

    return lastChange
end

function Conductor:getStep(time)
    local lastChange = self:getBPMFromSeconds(time)
    return lastChange.stepTime + (time - lastChange.songTime) / lastChange.stepCrotchet
end

function Conductor:getStepRounded(time)
    local lastChange = self:getBPMFromSeconds(time)
    return lastChange.stepTime + math.floor((time - lastChange.songTime) / lastChange.stepCrotchet)
end

function Conductor:getBeat(time)
    return self:getStep(time) / 4
end

function Conductor:getBeatRounded(time)
    return math.floor(self:getStepRounded(time) / 4)
end

function Conductor:beatToSeconds(beat)
    local step = beat * 4
    local lastChange = self:getBPMFromStep(step)
    return lastChange.songTime
        + ((step - lastChange.stepTime) / (lastChange.bpm / 60) / 4) * 1000
end

function Conductor:mapBPMChangesLegacy(song)
    self.bpmChangeMap = {}

    local curBPM = song.bpm
    local totalSteps = 0
    local totalPos = 0

    for i, note in ipairs(song.notes) do
        if note.changeBPM and note.bpm ~= curBPM then
            curBPM = note.bpm
            table.insert(self.bpmChangeMap, {
                stepTime = totalSteps,
                songTime = totalPos,
                bpm = curBPM,
                stepCrotchet = self:calculateCrochet(curBPM) / 4
            })
        end

        local deltaSteps = math.floor(self:getSectionBeats(song, i) * 4)
        totalSteps = totalSteps + deltaSteps
        totalPos = totalPos + ((60 / curBPM) * 1000 / 4) * deltaSteps
    end
end

function Conductor:mapBPMChanges(meta)
    self.bpmChangeMap = {}
    local totalSteps = 0

    for _, bpmChange in ipairs(meta.timeChanges) do
        table.insert(self.bpmChangeMap, {
            stepTime = totalSteps,
            songTime = bpmChange.t,
            bpm = bpmChange.bpm,
            stepCrotchet = self:calculateCrochet(bpmChange.bpm) / 4
        })

        local beat = (bpmChange.t - meta.timeChanges[1].t) / (60 / bpmChange.bpm)
        totalSteps = math.floor(beat * 4)
    end
end

function Conductor:update(dt, localMusicTime)
    self.onSection = false
    self.onBeat = false
    self.onStep = false

    local oldStep = self.curStep
    if localMusicTime then
        self.musicTime = self.musicTime + dt * 1000
    end

    self:updateCurStep()
    self:updateBeat()

    if oldStep ~= self.curStep then
        if self.curStep > 0 then
            self:stepHit()
        end

        if weeks.SONG then
            if oldStep < self.curStep then
                self:updateSection()
            else
                self:rollbackSection()
            end
        end
    end
end

function Conductor:updateCurStep()
    local lastChange = self:getBPMFromSeconds(self.musicTime)
    local offsetPosition = self.musicTime - lastChange.songTime
    local stepTime = offsetPosition / lastChange.stepCrotchet

    self.curDecStep = lastChange.stepTime + stepTime
    self.curStep = lastChange.stepTime + math.floor(stepTime)
end

function Conductor:updateBeat()
    self.curBeat = math.floor(self.curStep / 4)
    self.curDecBeat = self.curDecStep / 4
end

function Conductor:getSectionBeats(song, section)
    return song.notes[section].sectionBeats or 4
end

function Conductor:getBeatsOnSection()
    if weeks.SONG and weeks.SONG.notes[self.curSection] then
        return weeks.SONG.notes[self.curSection].sectionBeats or 4
    end
    return 4
end

function Conductor:updateSection()
    if self.stepsToDo < 1 then
        self.stepsToDo = math.floor(self:getBeatsOnSection() * 4)
    end

    while self.curStep >= self.stepsToDo do
        self.curSection = self.curSection + 1
        local beats = self:getBeatsOnSection()
        self.stepsToDo = self.stepsToDo + math.floor(beats * 4)
        self:sectionHit()
    end
end

function Conductor:rollbackSection()
    if self.curStep < 0 then return end

    local lastSection = self.curSection
    self.curSection = 0
    self.stepsToDo = 0

    for i = 1, #weeks.SONG.notes do
        self.stepsToDo = self.stepsToDo + math.floor(self:getBeatsOnSection() * 4)
        if self.stepsToDo > self.curStep then break end
        self.curSection = self.curSection + 1
    end

    if self.curSection > lastSection then
        self:sectionHit()
    end
end

function Conductor:stepHit()
    self.onStep = true
    if self.curStep % 4 == 0 then
        self:beatHit()
    end
end

function Conductor:beatHit()
    self.onBeat = true
end

function Conductor:sectionHit()
    self.onSection = true
end

return Conductor
