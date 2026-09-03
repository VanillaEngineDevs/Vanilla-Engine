local camTween

function Event:on(time, v)
    local camera = weeks:getCamera()
    if camera.lockedMoving then return end

    camera.IS_CLASSIC_MOVEMENT = false

    if type(v) == "number" then
        local targetX, targetY = 0, 0
        if v == 0 then -- Boyfriend
            if not weeks.boyfriend then return end
            local bfpoint = weeks.boyfriend:getCameraPoint()
            targetX = bfpoint.x
            targetY = bfpoint.y
        elseif v == 1 then -- Enemy
            if not weeks.enemy then return end
            local dadpoint = weeks.enemy:getCameraPoint()
            targetX = dadpoint.x
            targetY = dadpoint.y
        elseif v == 2 then -- Girlfriend
            if not weeks.girlfriend then return end
            local gfpoint = weeks.girlfriend:getCameraPoint()
            targetX = gfpoint.x
            targetY = gfpoint.y
        end

        if camTween then 
            Timer.cancel(camTween)
        end

        camera.IS_CLASSIC_MOVEMENT = true
        weeks:getCameraLerpPoint().x = targetX
        weeks:getCameraLerpPoint().y = targetY
    elseif type(v) == "table" then
        local char = tonumber(v.char) or tonumber(v.value) or 0
        local x = tonumber(v.x) or 0
        local y = tonumber(v.y) or 0

        local duration = tonumber(v.duration) or 4
        local ease = v.ease or "CLASSIC"

        local targetX, targetY = x, y
        if weeks:getSongID() == "2hot" then
            targetX, targetY = -targetX, -targetY
        end

        if char == -1 then
        elseif char == 0 then
            if not weeks.boyfriend then return end
            local bfpoint = weeks.boyfriend:getCameraPoint()
            targetX = targetX + bfpoint.x
            targetY = targetY + bfpoint.y
        elseif char == 1 then
            if not weeks.enemy then return end
            local dadpoint = weeks.enemy:getCameraPoint()
            targetX = targetX + dadpoint.x
            targetY = targetY + dadpoint.y
        elseif char == 2 then
            if not weeks.girlfriend then return end
            local gfpoint = weeks.girlfriend:getCameraPoint()
            targetX = targetX + gfpoint.x
            targetY = targetY + gfpoint.y
        else
            print("Unknown char for FocusCamera event: " .. tostring(char))
        end

        if ease == "CLASSIC" then
            if camTween then 
                Timer.cancel(camTween)
            end
            camera.IS_CLASSIC_MOVEMENT = true
            weeks:getCameraLerpPoint().x = targetX
            weeks:getCameraLerpPoint().y = targetY
            camera.x = targetX
            camera.y = targetY
        else
            local time = (weeks.conductor:getStepLengthMs() * duration) / 1000
            if camTween then 
                Timer.cancel(camTween)
            end

            camTween = Timer.tween(
                time,
                camera,
                {
                    x = targetX,
                    y = targetY
                },
                CONSTANTS.WEEKS.EASING_TYPES[ease or "linear"]
            )
        end
    end
end
