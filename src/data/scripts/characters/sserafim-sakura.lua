function Character:onNoteHit(event)
    if event.noteType == "sakura-joint" then
        self.data:play(CONSTANTS.WEEKS.ANIM_LIST[event.direction] .. "-joint", true, false)
    elseif event.noteType == "sakura-bf1" then
        self.data:play(CONSTANTS.WEEKS.ANIM_LIST[event.direction] .. "-bf1", true, false)
    elseif event.noteType == "sakura-bf2" then
        self.data:play(CONSTANTS.WEEKS.ANIM_LIST[event.direction] .. "-bf2", true, false)
    end
end