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

return eventCreator
