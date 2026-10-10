local normalChar

function Character:setAlpha(v)
    self.data.alpha = v
    if normalChar then
        if v ~= 1 then
            normalChar.alpha = 1
        else
            normalChar.alpha = 0
        end
    end
end

function Character:onNoteHit(event)
    if not event.mustHit and self.data.characterType == CHARACTER_TYPE.DAD then
        if event.noteType == "cheer" then
            self.data.holdTimer = 0
            self:play("cheer", true, false)
        end
    end
end

function Character:play(name, force, loop)
    self.data:play(name, force, loop)

    if normalChar then
        normalChar:play(name, force, loop)
        normalChar.x = self.data.x
        normalChar.y = self.data.y
    end
end

function Character:postCreate()
    normalChar = Character.getCharacter("spooky")
    normalChar.zIndex = 199
    normalChar.alpha = 0
    normalChar.flipX = false
    normalChar.characterType = CHARACTER_TYPE.DAD

    weeks:add(normalChar)
    weeks:sort()
end