local sounds = {}

function Character:onCreate()
    for _, snd in ipairs({"Darnell_Lighter", "Kick_Can_UP", "Kick_Can_FORWARD"}) do
        sounds[snd] = love.audio.newSource("assets/weekend1/sounds/" .. snd .. ".ogg", "static")
    end
end

function Character:onNoteHit(event)
    if event.noteType == "weekend-1-lightcan" then
        self.data.holdTimer = 0
        self:playLightCanAnim()
    elseif event.noteType == "weekend-1-kickcan" then
        self.data.holdTimer = 0
        self:playKickCanAnim()
    elseif event.noteType == "weekend-1-kneecan" then
        self.data.holdTimer = 0
        self:playKneeCanAnim()
    end
end

function Character:onNoteIncoming(event)
    if event.mustHit and (self.data.characterType == CHARACTER_TYPE.BF or self.data.characterType == CHARACTER_TYPE.DAD) then
        local msTilStrum = event.data.time - weeks.conductor.musicTime

        if event.noteType == "weekend-1-lightcan" then
            self:scheduleLightCanSound((msTilStrum - 65)/1000)
        elseif event.noteType == "weekend-1-kickcan" then
            self:scheduleKickCanSound((msTilStrum-50)/1000)
        elseif event.noteType == "weekend-1-kneecan" then
            self:scheduleKneeCanSound9((msTilStrum-22)/100)
        end
    end
end

function Character:playLightCanAnim()
    self.data:play("lightCan", true, false)
end

function Character:playKickCanAnim()
    self.data:play("kickCan", true, false)
end

function Character:playKneeCanAnim()
    self.data:play("kneeCan", true, false)
end

function Character:scheduleLightCanSound(timeToPlay)
    Timer.after(timeToPlay, function()
        audio.playSound(sounds["Darnell_Lighter"])
    end)
end

function Character:scheduleKickCanSound(timeToPlay)
    Timer.after(timeToPlay, function()
        audio.playSound(sounds["Kick_Can_UP"])
    end)
end

function Character:scheduleKneeCanSound(timeToPlay)
    Timer.after(timeToPlay, function()
        audio.playSound(sounds["Kick_Can_FORWARD"])
    end)
end