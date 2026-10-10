function Character:onNoteHit(event)
    if event.noteType == "ugh" then
        self.data:play("ugh", true, false)
    elseif event.noteType == "hehPrettyGood" then
        self.data:play("good", true, false)
    end
end
