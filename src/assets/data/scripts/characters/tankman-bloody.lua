local picoEndSound

function Character:onCreate()
    self.isBloody = false

    picoEndSound = picoEndSound or love.audio.newSource(EXTEND_LIBRARY_SFX("week7:erect/endCutscene.ogg"), "static")
end

function Character:play(name, forced, loop)
    if name == "hehPrettyGood-bloody" then
        self.isBloody = false
    end
    if self.isBloody and name ~= "stressPicoEnding" and name ~= "redheadsAnim" and name ~= "hehPrettyGood-bloody" then
        self.data:play(name .. "-bloody", forced, loop)
    else
        self.data:play(name, forced, loop)
        if name == "hehPrettyGood-bloody" then
            self.isBloody = true
        end
    end

    if name == "redheadsAnim" then
        self.isBloody = true
    end

    if name == "stressPicoEnding" then
        audio.playSound(picoEndSound)
        self.data:play("stressPicoEnding", forced, false)
    end
end

function Character:onNoteHit(event)
    if event.noteType == "ugh" then
        self.data:play("ugh", true, false)
    elseif event.noteType == "hehPrettyGood" then
        self.data:play("good", true, false)
    end
end
