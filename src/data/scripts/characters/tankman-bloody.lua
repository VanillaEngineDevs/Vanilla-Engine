function Character:onCreate()
    self.isBloody = false
end

function Character:play(name, forced, loop)
    if self.isBloody then
        self.data:play(name .. "-bloody", forced, loop)
    else
        self.data:play(name, forced, loop)
    end

    if name == "redheadsAnim" then
        self.isBloody = true
    end

    if name == "stressPicoEnding" then
        -- the ending !!!
    end
end

function Character:onNoteHit(event)
    if event.noteType == "ugh" then
        self.data:play("ugh", true, false)
    elseif event.noteType == "hehPrettyGood" then
        self.data:play("good", true, false)
    end
end
