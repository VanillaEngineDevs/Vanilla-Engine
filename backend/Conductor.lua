local BPMChangeEvent = Object:extend()
BPMChangeEvent.stepTime = 0
BPMChangeEvent.songTime = 0
BPMChangeEvent.bpm = 0
BPMChangeEvent.stepCrochet = 0

function BPMChangeEvent:new(stepTime, songTime, bpm, stepCrochet)
    local stepCrochet = stepCrochet or Conductor.stepCrochet
    self.stepTime = stepTime
    self.songTime = songTime
    self.bpm = bpm
    self.stepCrochet = stepCrochet
    return self
end

Conductor = {}

Conductor.bpm = 100
Conductor.crochet = ((60/Conductor.bpm)*1000)
Conductor.stepCrochet = Conductor.crochet/4
Conductor.songPosition = 0
Conductor.offset = 0

Conductor.safeZoneOffset = 0

Conductor.bpmChangeMap = {}

function Conductor.judgeNote(arr, diff)
    data = arr
    for i = 1, #data-1 do
        --print(diff, data[i].hitWindow)
        if diff <= data[i].hitWindow then
            return data[i]
        end
    end
    return data[#data]
end

function Conductor.getCrotchetAtTime(time)
    local lastChange = Conductor.getBPMFromSeconds(time)
    return lastChange.stepCrochet*4
end

function Conductor.getBPMFromSeconds(time)
    local lastChange = BPMChangeEvent(0, 0, Conductor.bpm, Conductor.stepCrochet)
    for i = 1, #Conductor.bpmChangeMap do
        if time >= Conductor.bpmChangeMap[i].songTime then
            lastChange = Conductor.bpmChangeMap[i]
        end
    end

    return lastChange
end

function Conductor.getBPMFromStep(step)
    local lastChange = bpmChangeEvent(0, 0, Conductor.bpm, Conductor.stepCrochet)
    for i = 1, #Conductor.bpmChangeMap do
        if Conductor.bpmChangeMap[i].stepTime <= step then
            lastChange = Conductor.bpmChangeMap[i]
        end
    end

    return lastChange
end

function Conductor.beatToSeconds(beat)
    local step = beat * 4
    local lastChange = Conductor.getBPMFromStep(step)
    return lastChange.songTime + ((step - lastChange.stepTime) / (lastChange.bpm / 60)/4) * 1000
end

function Conductor.getStep(time)
    local lastChange = Conductor.getBPMFromSeconds(time)
    return lastChange.stepTime + (time - lastChange.songTime) / lastChange.stepCrochet
end

function Conductor.getStepRounded(time)
    local lastChange = Conductor.getBPMFromSeconds(time)
    return lastChange.stepTime + math.floor(time - lastChange.songTime) / lastChange.stepCrochet
end

function Conductor.getBeat(time)
    return Conductor.getStep(time)/4
end

function Conductor.getBeatRounded(time)
    return math.floor(Conductor.getStepRounded(time)/4)
end

function Conductor.mapBPMChanges(song)
    Conductor.bpmChangeMap = {}

    local curBPM = song.bpm
    local totalSteps = 0
    local totalPos = 0
    for i = 1, #song.notes do
        if song.notes[i].changeBPM and song.notes[i].bpm ~= curBPM then
            curBPM = song.notes[i].bpm
            local event = BPMChangeEvent(totalSteps, totalPos, curBPM, Conductor.calculateCrochet(curBPM)/4)
            table.insert(Conductor.bpmChangeMap, event)
        end

        local deltaSteps = math.round(Conductor.getSectionBeats(song, i) * 4)
        totalSteps = totalSteps + deltaSteps
        totalPos = totalPos + ((60 / curBPM) * 1000 / 4) * deltaSteps
    end
end

function Conductor.getSectionBeats(song, section)
    local val = nil
    if song.notes[section] ~= nil then
        val = song.notes[section].sectionBeats
    end
    return val or 4
end

function Conductor.calculateCrochet(bpm)
    return ((60/bpm)*1000)
end

function Conductor.changeBPM(newBPM)
    Conductor.bpm = newBPM
    Conductor.crochet = Conductor.calculateCrochet(newBPM)
    Conductor.stepCrochet = Conductor.crochet/4

    return Conductor.bpm
end

return Conductor