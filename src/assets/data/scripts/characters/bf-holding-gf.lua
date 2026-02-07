function Character:onAnimationFrame(name, frameNumber, _)
    if name == "firstDeath" and frameNumber == 28 then
        hapticUtil:vibrate(0, 0.1, 0.1, 1)
    end

    if name == "deathLoop" and (frameNumber == 1 or frameNumber == 19) then
        hapticUtil:vibrate(0, 0.1, 0.1, 1)
    end
end

function Character:getDeathQuote()
    local dadID = enemy and enemy._data and enemy.id or "dad"

    if dadID == "tankman" then
        return "assets/week7/sounds/jeffGameover/jeffGameover-" .. love.math.random(1, 25) .. ".ogg"
    else
        return nil
    end
end
