---@deprecated 
---This module is deprecated and will no longer be updated. Please consider using the `Conductor` class instead as this is here simply for compatibility reasons.
beatHandler = {}
beatHandler.beat = 0
beatHandler.beatTime = 0
beatHandler.bpm = 100
beatHandler.curStep = 0 -- 1/4 of a beat
beatHandler.stepTime = 0

beatHandler.crochet = (60/beatHandler.bpm) * 1000
beatHandler.stepCrochet = beatHandler.crochet / 4

beatHandler.isBeatHit = false
beatHandler.isStepHit = false

function beatHandler.setBPM(bpm)
    bpm = bpm or 100
    beatHandler.bpm = bpm
    beatHandler.crochet = (60/bpm) * 1000
    beatHandler.stepCrochet = beatHandler.crochet / 4
end

function beatHandler.getBeat()
    return beatHandler.beat
end

function beatHandler.getBeatTime()
    return beatHandler.beatTime
end

function beatHandler.getCrochet()
    return beatHandler.crochet
end

function beatHandler.getStepCrochet()
    return beatHandler.stepCrochet
end

function beatHandler.update(dt)
    -- check for step
    beatHandler.stepTime = beatHandler.stepTime + dt * 1000
    if beatHandler.stepTime >= beatHandler.stepCrochet then
        beatHandler.stepTime = 0
        beatHandler.curStep = beatHandler.curStep + 1
        beatHandler.isStepHit = true
    else
        beatHandler.isStepHit = false
    end

    -- check for beat
    beatHandler.beatTime = beatHandler.beatTime + dt * 1000
    if beatHandler.beatTime >= beatHandler.crochet then
        beatHandler.beatTime = 0
        beatHandler.beat = beatHandler.beat + 1
        beatHandler.isBeatHit = true
    else
        beatHandler.isBeatHit = false
    end
end

function beatHandler.reset()
    beatHandler.beat = 0
    beatHandler.beatTime = 0
    beatHandler.curBeat = 0
    beatHandler.isBeatHit = false
    beatHandler.curStep = 0
    beatHandler.stepTime = 0
    beatHandler.curStep = 0
    beatHandler.isStepHit = false
end

function beatHandler.onBeat()
    return beatHandler.isBeatHit
end

function beatHandler.setBeat(beat)
    beatHandler.beat = beat
    beatHandler.beatTime = 0
    beatHandler.curStep = beat * 4
    beatHandler.stepTime = 0
end

function beatHandler.onStep()
    return beatHandler.isStepHit
end

return beatHandler