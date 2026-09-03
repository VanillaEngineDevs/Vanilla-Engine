function Event:on(t, v)
    local camera = weeks:getCamera()
    local uiCam = getCamera()

    local rate = tonumber(v.rate) or CONSTANTS.DEFAULT_ZOOM_RATE
    local offset = tonumber(v.rate) or CONSTANTS.DEFAULT_ZOOM_OFFSET
    local intensity = tonumber(v.rate) or 1

    camera.bopIntensity = (CONSTANTS.DEFAULT_BOP_INTENSITY - 1) * intensity + 1
    uiCam.bopIntensity = (CONSTANTS.DEFAULT_BOP_INTENSITY - 1) * intensity * 2
    camera.zoomRate = rate
    camera.zoomRateOffset = offset
end
