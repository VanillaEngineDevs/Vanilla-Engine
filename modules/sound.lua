local sound = {}

function sound.play(sound)
    if not sound then return end
    sound:stop()
    sound:play()
end

return sound