local camZoomTween

function Event:cancelCameraZoomTween()
    if camZoomTween then
        Timer.cancel(camZoomTween)
        camZoomTween = nil
    end
end

function Event:tweenCameraZoom(zoom, durSeconds, isDirectMode, easeFunction)
    zoom = zoom or 1
    duration = duration or 1
    direct = direct or false
    self:cancelCameraZoomTween()

    local target = zoom * (direct and weeks:getCamera().defaultZoom or weeks.stage.cameraZoom)

    if duration == 0 then
        weeks:getcamera().currentZoom = target
    else
        camZoomTween = Timer.tween(duration, camera, { currentZoom = target }, ease or "linear")
    end
end

function Event:on(t, v)
    local zoom = tonumber(v.zoom) or 1
    local duration = tonumber(v.duration) or 4
    local mode = v.mode or "direct"
    local isDirect = mode == "direct"
    local ease = v.ease or "linear"
    local easeDir = v.ease or "In"

    if ease == "INSTANT" then
        self:tweenCameraZoom(zoom, 0, isDirect)
    else
        local durSeconds = (weeks.conductor:getStepLengthMs() * duration) / 1000
        local easeFunction = CONSTANTS.WEEKS.EASING_TYPES[ease .. easeDir] or CONSTANTS.WEEKS.EASING_TYPES.linear
        self:tweenCameraZoom(zoom, durSeconds, isDirect, easeFunction)
    end
end
