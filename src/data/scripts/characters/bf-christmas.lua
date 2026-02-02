function Character:onNoteHit(event)
    if event.noteType == "censor" then
        self.data:play(CONSTANTS.WEEKS.ANIM_LIST[event.direction] .. "-censor", true, false)
    elseif event.noteType == "hey" then
        self.data.holdTimer = 0
        self.data:play("hey", true, false)
    end
end
