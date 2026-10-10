function Character:onAnimationFrame(name, frameNumber, _)
    if name == "firstDeath" and frameNumber == 28 then
        hapticUtil:vibrate(0, 0.1, 0.1, 1)
    end

    if name == "deathLoop" and (frameNumber == 1 or frameNumber == 19) then
        hapticUtil:vibrate(0, 0.1, 0.1, 1)
    end
end

function Character:onNoteHit(event)
    if event.noteType == "censor" then
        self.data:play(CONSTANTS.WEEKS.ANIM_LIST[event.direction] .. "-censor", true, false)
    elseif event.noteType == "hey" then
        self.data.holdTimer = 0
        self.data:play("hey", true, false)
    end
end
