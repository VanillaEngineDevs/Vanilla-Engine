local MusicBeatState = Object:extend()

MusicBeatState.curSection = 1
MusicBeatState.stepsToDo = 0
MusicBeatState.curStep = 0
MusicBeatState.curBeat = 0

MusicBeatState.curDecStep = 0
MusicBeatState.curDecBeat = 0

MusicBeatState.camBeat = nil

MusicBeatState.timePassedOnState = 0

MusicBeatState.fadeTimer = nil
MusicBeatState.fade = {}

function MusicBeatState:enter() 
    self.curSection = 1
    self.stepsToDo = 0
    self.curStep = 0
    self.curBeat = 0

    self.curDecStep = 0
    self.curDecBeat = 0

    self.timePassedOnState = 0
    self.camBeat = nil

    self.timePassedOnState = 0
end

function MusicBeatState:update(dt)
    local oldStep = self.curStep
    self.timePassedOnState = self.timePassedOnState + dt

    self:updateCurStep()
    self:updateBeat()

    if oldStep ~= self.curStep then
        if self.curStep > 0 then
            self:stepHit()
        end

        if PlayState.SONG ~= nil then
            if oldStep < self.curStep then
                self:updateSection()
            else
                self:rollbackSection()
            end
        end
    end
end

function MusicBeatState:switchState(nextState)
    if not nextState then nextState = Gamestate.current() end
    
    Gamestate.switch(nextState)
end

function MusicBeatState:fadeIn(duration, callback)
    if self.fadeTimer then Timer.cancel(self.fadeTimer) end

    self.fade = {
        height = push.getHeight() * 2,
        graphic = CoolUtil.newGradient("vertical", {0, 0, 0, 0}, {0, 0, 0}, {0, 0, 0})
    }

    self.fade.y = -self.fade.height / 2
    self.fadeTimer = Timer.tween(duration * 2, self.fade, {y = self.fade.height}, "linear", function()
        self.fade.graphic:release()
        self.fade = {}
        if callback then callback() end
    end)
end

function MusicBeatState:fadeOut(duration, callback)
    if self.fadeTimer then Timer.cancel(self.fadeTimer) end

    self.fade = {
        height = push.getHeight() * 2,
        graphic = CoolUtil.newGradient("vertical", {0, 0, 0}, {0, 0, 0}, {0, 0, 0, 0})
    }

    self.fade.y = -self.fade.height / 2
    self.fadeTimer = Timer.tween(duration, self.fade, {y = 0}, "linear", function()
        self.fade.graphic:release()
        self.fade = {}
        if callback then callback() end
    end)
end

function MusicBeatState:updateSection()
    if self.stepsToDo < 1 then self.stepsToDo = math.round(self:getBeatsOnSection() * 4) end
    while self.curStep >= self.stepsToDo do
        self.curSection = self.curSection + 1
        local beats = self:getBeatsOnSection()
        self.stepsToDo = self.stepsToDo + math.round(beats * 4)
        self:sectionHit()
    end
end

function MusicBeatState:rollbackSection()
    if self.curStep < 0 then return end

    local lastSection = self.curSection
    self.curSection = 0
    self.stepsToDo = 0
    for i = 1, #PlayState.SONG.notes do
        if PlayState.SONG.notes[i] ~= nil then
            self.stepsToDo = self.stepsToDo + math.round(self:getBeatsOnSection() * 4)
            if self.stepsToDo > self.curStep then break end

            self.curSection = self.curSection + 1
        end
    end
end

function MusicBeatState:updateBeat()
    self.curBeat = math.floor(self.curStep / 4)
    self.curDecBeat = self.curDecStep / 4
end

function MusicBeatState:updateCurStep()
    local lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition)

    local shit = ((Conductor.songPosition) - lastChange.songTime) / lastChange.stepCrochet
    self.curDecStep = lastChange.stepTime + shit
    self.curStep = lastChange.stepTime + math.floor(shit)
end

function MusicBeatState:stepHit()
    if self.curStep % 4 == 0 then
        self:beatHit()
    end
end

function MusicBeatState:beatHit()
end

function MusicBeatState:sectionHit()
end

function MusicBeatState:getBeatsOnSection()
    local val = 4
    if PlayState.SONG ~= nil and PlayState.SONG.notes[self.curSection] ~= nil then
        val = PlayState.SONG.notes[self.curSection].sectionBeats
    end
    return val or 4
end

return MusicBeatState