local eventCreator = {}

-- our base event class
local baseEvent = Object:extend()
function baseEvent:new()
    self.cancelled = false
end

function baseEvent:cancel()
    self.cancelled = true
end

-- the real event creator shit

function eventCreator:countdownStart()
    return baseEvent()
end

function eventCreator:countdownTick()
    return baseEvent()
end

function eventCreator:endSong()
    return baseEvent()
end

function eventCreator:noteHit(type, direction, data, healthChange, judgement)
    local event = baseEvent()
    event.noteType = type
    event.direction = direction
    event.data = data
    event.healthChange = healthChange
    event.judgement = judgement

    return event
end

function eventCreator:noteMiss(type, direction, data, healthChange)
    local event = baseEvent()
    event.noteType = type
    event.direction = direction
    event.data = data
    event.healthChange = healthChange
    event.judgement = 'miss'
    event.isPlayer = true

    return event
end

return eventCreator
