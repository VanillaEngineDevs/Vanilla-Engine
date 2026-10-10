function Character:onNoteHit(event)
    if event.noteType == "mom" then
        self.data.holdTimer = 0
        self.data:play(CONSTANTS.WEEKS.ANIM_LIST[event.direction] .. "-alt", true, false)
    end
end
