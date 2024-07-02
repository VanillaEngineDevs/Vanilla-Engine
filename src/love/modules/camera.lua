local camera = {}
local camTimer
camera.x = 0
camera.y = 0
camera.zoom = 1
camera.defaultZoom = 1
camera.zooming = true
camera.locked = false
camera.camBopIntensity = 1
camera.camBopInterval = 4
camera.lockedMoving = false

camera.esizeX = 1
camera.esizeY = 1

camera.flash = 0
camera.col = {1, 1, 1}
camera.points = {}

camera.mustHit = true

function camera:moveToMain(time, x, y)
    if camera.locked then return end
    if camTimer then 
        Timer.cancel(camTimer)
    end
    camTimer = Timer.tween(time, camera, {x = x, y = y}, "out-quad")
end

function camera:reset()
    camera.x = 0
    camera.y = 0
    camera.zoom = 1
    camera.esizeX = 1
    camera.esizeY = 1
end

function camera:flash(time, x, col)
    camera.color = col or {1, 1, 1}
    if camTimer then 
        Timer.cancel(camTimer)
    end
    camTimer = Timer.tween(time, camera, {flash = x}, "in-bounce")
end

function camera:removePoint(name)
    camera.points[name] = nil
end

function camera:addPoint(name, x, y)
    camera.points[name] = {x = x, y = y}
end

function camera:moveToPoint(time, name, mustHit)
    if camera.locked then return end
    if camTimer then 
        Timer.cancel(camTimer)
    end
    mustHit = mustHit or true 
    camera.mustHit = mustHit
    camTimer = Timer.tween(time, camera, {x = camera.points[name].x, y = camera.points[name].y}, "out-quad")
end

function camera:drawCameraPoints()
    for k, v in pairs(camera.points) do
        love.graphics.circle("fill", -v.x, -v.y, 10)
        -- print the name under the circle
        love.graphics.print(k, -v.x, -v.y + 10)
    end
end

function camera:drawPoint(name)
    love.graphics.circle("fill", -camera.points[name].x, -camera.points[name].y, 10)
    -- print the name under the circle
    love.graphics.print(name, -camera.points[name].x, -camera.points[name].y + 10)
end

function camera:getPoint(name)
    return camera.points[name]
end

return camera