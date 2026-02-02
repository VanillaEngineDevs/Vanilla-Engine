function Character:onAnimationFrame(name, frameNumber, _)
    if name == "firstDeath" and frameNumber == 28 then
        hapticUtil:vibrate(0, 0.1, 0.1, 1)
    end

    if name == "deathLoop" and (frameNumber == 1 or frameNumber == 19) then
        hapticUtil:vibrate(0, 0.1, 0.1, 1)
    end
end
