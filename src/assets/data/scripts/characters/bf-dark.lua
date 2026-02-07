local normalChar

function Character:onAnimationFrame(name, frameNumber, _)
    if name == "firstDeath" and frameNumber == 28 then
        hapticUtil:vibrate(0, 0.1, 0.1, 1)
    end

    if name == "deathLoop" and (frameNumber == 1 or frameNumber == 19) then
        hapticUtil:vibrate(0, 0.1, 0.1, 1)
    end
end

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

function Character:play(name, force, loop)
    self.data:play(name, force, loop)

    if normalChar then
        normalChar:play(name, force, loop)
        normalChar.x = self.data.x - 1
        normalChar.y = self.data.y - 11
    end
end

function Character:postCreate()
    normalChar = Character.getCharacter("bf")
    normalChar.zIndex = 199
    normalChar.alpha = 0
    normalChar.flipX = false
    normalChar.characterType = CHARACTER_TYPE.BF

    weeks:add(normalChar)
    weeks:sort()
end