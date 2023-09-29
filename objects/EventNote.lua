local EventNote = Object:extend()

function EventNote:new(strumTime, event, value1, value2)
    self.strumTime = strumTime
    self.event = event
    self.value1 = value1
    self.value2 = value2
end

return EventNote