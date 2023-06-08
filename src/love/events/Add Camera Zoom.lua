function onEvent(n, v1, v2)
    local v1 = tonumber(v1) or 0.03
    local v2 = tonumber(v2) or 0.015
    camera.zoom = camera.zoom + v1
    uiScale.zoom = uiScale.zoom + v2
end