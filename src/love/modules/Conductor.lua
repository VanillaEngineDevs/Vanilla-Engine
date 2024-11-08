Conductor = {}
Conductor.bpm = 100
Conductor.crotchet = (60 / Conductor.bpm) * 1000
Conductor.stepCrotchet = Conductor.crotchet / 4
musicTime = 0
Conductor.curStep = 0
Conductor.curBeat = 0
Conductor.curDecStep = 0
Conductor.curDecBeat = 0
Conductor.stepsToDo = 0
Conductor.curSection = 0
Conductor.lastSongPos = 0
Conductor.offset = 0

Conductor.ROWS_PER_BEAT = 48 
Conductor.BEATS_PER_MEASURE = 4
Conductor.ROWS_PER_MEASURE = Conductor.ROWS_PER_BEAT * Conductor.BEATS_PER_MEASURE
Conductor.MAX_NOTE_ROW = bit.lshift(1, 30)

Conductor.bpmChangeMap = {}

function Conductor.new()
    local self = setmetatable({}, { __index = Conductor })
    return self
end

function Conductor.beatToRow(beat)
    return math.floor(beat * Conductor.ROWS_PER_BEAT + 0.5)
end

function Conductor.rowToBeat(row)
    return row / Conductor.ROWS_PER_BEAT
end

function Conductor.secsToRow(secs)
    return math.floor(Conductor.getBeat(secs) * Conductor.ROWS_PER_BEAT + 0.5)
end

function Conductor.beatToNoteRow(beat)
    return math.floor(beat * Conductor.ROWS_PER_BEAT + 0.5)
end

function Conductor.noteRowToBeat(row)
    return row / Conductor.ROWS_PER_BEAT
end

function Conductor.timeSinceLastBPMChange(time)
    local lastChange = Conductor.getBPMFromSeconds(time)
    return time - lastChange.songTime
end

function Conductor.getBeatInMeasure(time)
    local lastChange = Conductor.getBPMFromSeconds(time)
    return (time - lastChange.songTime) / (lastChange.stepCrotchet * 4)
end

function Conductor.getCrotchetAtTime(time)
    local lastChange = Conductor.getBPMFromSeconds(time)
    return lastChange.stepCrotchet * 4
end

function Conductor.getBPMFromSeconds(time)
    local lastChange = {
        stepTime = 0,
        songTime = 0,
        bpm = Conductor.bpm,
        stepCrotchet = Conductor.stepCrotchet
    }
    for _, change in ipairs(Conductor.bpmChangeMap) do
        if time >= change.songTime then
            lastChange = change
        end
    end
    return lastChange
end

function Conductor.getBPMFromStep(step)
    local lastChange = {
        stepTime = 0,
        songTime = 0,
        bpm = Conductor.bpm,
        stepCrotchet = Conductor.stepCrotchet
    }
    for _, change in ipairs(Conductor.bpmChangeMap) do
        if change.stepTime <= step then
            lastChange = change
        end
    end
    return lastChange
end

function Conductor.beatToSeconds(beat)
    local step = beat * 4
    local lastChange = Conductor.getBPMFromStep(step)
    return lastChange.songTime + ((step - lastChange.stepTime) / (lastChange.bpm / 60) / 4) * 1000
end

function Conductor.getStep(time)
    local lastChange = Conductor.getBPMFromSeconds(time)
    return lastChange.stepTime + (time - lastChange.songTime) / lastChange.stepCrotchet
end

function Conductor.getStepRounded(time)
    local lastChange = Conductor.getBPMFromSeconds(time)
    return lastChange.stepTime + math.floor((time - lastChange.songTime) / lastChange.stepCrotchet)
end

function Conductor.getBeat(time)
    return Conductor.getStep(time) / 4
end

function Conductor.getBeatRounded(time)
    return math.floor(Conductor.getStepRounded(time) / 4)
end

function Conductor.mapBPMChangesLegacy(song)
    Conductor.bpmChangeMap = {}

    local curBPM = song.bpm
    local totalSteps = 0
    local totalPos = 0

    for i, note in ipairs(song.notes) do
        if note.changeBPM and note.bpm ~= curBPM then
            curBPM = note.bpm
            local event = {
                stepTime = totalSteps,
                songTime = totalPos,
                bpm = curBPM,
                stepCrotchet = Conductor.calculateCrochet(curBPM) / 4
            }
            table.insert(Conductor.bpmChangeMap, event)
        end

        local deltaSteps = math.floor(Conductor.getSectionBeats(song, i) * 4)
        totalSteps = totalSteps + deltaSteps
        totalPos = totalPos + ((60 / curBPM) * 1000 / 4) * deltaSteps
    end
end

function Conductor.mapBPMChanges(meta)
    local totalSteps = 0
    for _, bpmChange in ipairs(meta.timeChanges) do
        -- new fnf's bpm changes show it in seconds, so we need to convert it to stepTime
        local event = {
            stepTime = totalSteps,
            songTime = bpmChange.t,
            bpm = bpmChange.bpm,
            stepCrotchet = Conductor.calculateCrochet(bpmChange.bpm) / 4
        }
        table.insert(Conductor.bpmChangeMap, event)

        -- there are no sections in the new format, so we need to calculate the steps manually
        -- convert our time to steps manually
        -- so first we convert it to beats
        local beat = (bpmChange.t - meta.timeChanges[1].t) / (60 / bpmChange.bpm)
        -- then we convert it to steps (1/4 of a beat)
        totalSteps = math.floor(beat * 4)
    end

end

function Conductor.update(dt)
    Conductor.onSection, Conductor.onBeat, Conductor.onStep = false, false, false
    local oldStep = Conductor.curStep

    Conductor.updateCurStep()
    Conductor.updateBeat()

    if oldStep ~= Conductor.curStep then
        if Conductor.curStep > 0 then
            Conductor.stepHit()
        end

        if weeks.SONG ~= nil then
            if oldStep < Conductor.curStep then
                Conductor.updateSection()
            else
                Conductor.rollbackSection()
            end
        end
    end
end

function Conductor.getSectionBeats(song, section)
    return song.notes[section].sectionBeats or 4
end

function Conductor.calculateCrochet(bpm)
    return (60 / bpm) * 1000
end

function Conductor.changeBPM(newBpm)
    Conductor.bpm = newBpm
    Conductor.crotchet = Conductor.calculateCrochet(newBpm)
    Conductor.stepCrotchet = Conductor.crotchet / 4
end

function Conductor.updateSection()
    if Conductor.stepsToDo < 1 then
        Conductor.stepsToDo = math.floor(Conductor.getBeatsOnSection() * 4)
    end
    while Conductor.curStep >= Conductor.stepsToDo do
        Conductor.curSection = Conductor.curSection + 1
        local beats = Conductor.getBeatsOnSection()
        Conductor.stepsToDo = Conductor.stepsToDo + math.floor(beats * 4)
        Conductor.sectionHit()
    end
end

function Conductor.rollbackSection()
    if Conductor.curStep < 0 then return end

    local lastSection = Conductor.curSection
    Conductor.curSection = 0
    Conductor.stepsToDo = 0
    for i = 1, #weeks.SONG.notes do
        if weeks.SONG.notes[i] ~= nil then
            Conductor.stepsToDo = Conductor.stepsToDo + math.floor(Conductor.getBeatsOnSection() * 4)
            if Conductor.stepsToDo > Conductor.curStep then
                break
            end
            Conductor.curSection = Conductor.curSection + 1
        end
    end

    if Conductor.curSection > lastSection then
        Conductor.sectionHit()
    end
end

function Conductor.updateBeat()
    Conductor.curBeat = math.floor(Conductor.curStep / 4)
    Conductor.curDecBeat = Conductor.curDecStep / 4
end

function Conductor.updateCurStep()
    local lastChange = Conductor.getBPMFromSeconds(musicTime)

    local offsetPosition = musicTime - lastChange.songTime
    local stepTime = offsetPosition / lastChange.stepCrotchet
    Conductor.curDecStep = lastChange.stepTime + stepTime
    Conductor.curStep = lastChange.stepTime + math.floor(stepTime)
end

function Conductor.getBeatsOnSection()
    local val = 4  -- Default value

    -- Check if the current section exists and has sectionBeats
    if weeks.SONG ~= nil and weeks.SONG.notes[Conductor.curSection] ~= nil then
        val = weeks.SONG.notes[Conductor.curSection].sectionBeats or 4
    end

    return val
end

function Conductor.stepHit()
    Conductor.onStep = true
    if Conductor.curStep % 4 == 0 then
        Conductor.beatHit()
    end
end

function Conductor.beatHit()
    Conductor.onBeat = true
end

function Conductor.sectionHit()
    Conductor.onSection = true
end

return Conductor