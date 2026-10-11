local camTween

function Event:cancelCameraFocusTween()
    if camTween then
        Timer.cancel(camTween)
        camTween = nil
    end
end

function Event:on(time, v)
    local camera = weeks:getCamera()
    if not camera or camera.lockedMoving then return end

    local targetX, targetY = 0, 0
    local char

    if type(v) == "number" then
        char = v
    elseif type(v) == "table" then
        char = tonumber(v.char)
        if char == nil then char = tonumber(v.value) end
        if char == nil then char = 0 end

        targetX = tonumber(v.x) or 0
        targetY = tonumber(v.y) or 0
    else
        return
    end

    if type(v) == "table" and weeks:getSongID() == "2hot" then
        targetX, targetY = -targetX, -targetY
    end

    if char == -1 then
    elseif char == 0 then
        if not weeks.boyfriend then return end
        local point = weeks.boyfriend:getCameraPoint()
        targetX = targetX + point.x
        targetY = targetY + point.y

    elseif char == 1 then
        if not weeks.enemy then return end
        local point = weeks.enemy:getCameraPoint()
        targetX = targetX + point.x
        targetY = targetY + point.y

    elseif char == 2 then
        if not weeks.girlfriend then return end
        local point = weeks.girlfriend:getCameraPoint()
        targetX = targetX + point.x
        targetY = targetY + point.y

    else
        print("Unknown camera focus: " .. tostring(char))
        return
    end

    self:cancelCameraFocusTween()

    local followPoint = weeks:getCameraLerpPoint()
    followPoint.x = targetX
    followPoint.y = targetY

    if type(v) == "number" then
        camera.IS_CLASSIC_MOVEMENT = true
        return
    end

    local duration = tonumber(v.duration)
    if duration == nil then duration = 4 end

    local ease = v.ease or "CLASSIC"
    local easeDir = v.easeDir or "InOut"

    if ease == "CLASSIC" then
        camera.IS_CLASSIC_MOVEMENT = true
        return
    end

    local scrollX = targetX
    local scrollY = targetY

    if ease == "INSTANT" or duration <= 0 then
        camera.x = scrollX
        camera.y = scrollY
        camera.IS_CLASSIC_MOVEMENT = true
        return
    end

    local easeName = ease
    if ease ~= "linear" then
        easeName = ease .. easeDir
    end

    local easeFunction =
        CONSTANTS.WEEKS.EASING_TYPES[easeName]
        or CONSTANTS.WEEKS.EASING_TYPES[ease]
        or CONSTANTS.WEEKS.EASING_TYPES.linear

    local durSeconds = (weeks.conductor:getStepLengthMs() * duration) / 1000

    camera.IS_CLASSIC_MOVEMENT = false

    camTween = TweenManager:tween(
        camera,
        {
            x = scrollX,
            y = scrollY
        },
        durSeconds,
        {
            ease = easeFunction,
            onComplete = function()
                camTween = nil
                camera.IS_CLASSIC_MOVEMENT = true
            end
        }
    )
end