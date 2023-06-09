function onEvent(n, v1)
    -- camGame screen shake. v1 is something like this:
    -- "1, 0.05", it goes "duration, intensity"

    doShake = true

    shakeDuration, shakeIntensity = string.match(v1, "(.*),(.*)")
    shakeDuration = tonumber(shakeDuration)
    shakeIntensity = tonumber(shakeIntensity)

    shakeX, shakeY = 0, 0
end

function onUpdate(elapsed)
    local elapsed = elapsed or 0
    if doShake then
        if shakeDuration > 0 then
            shakeDuration = shakeDuration - elapsed
            shakeIntensity = shakeIntensity - elapsed
            shakeX = love.math.random(-shakeIntensity, shakeIntensity)
            shakeY = love.math.random(-shakeIntensity, shakeIntensity)
        else
            shakeDuration = 0
            shakeIntensity = 0
            shakeX = 0
            shakeY = 0
            doShake = false
        end

        camGame.x = camGame.x + shakeX
        camGame.y = camGame.y + shakeY
    end
end