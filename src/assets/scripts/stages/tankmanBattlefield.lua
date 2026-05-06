local tankAngle = -90
local tankSpeed = 5

local tankMoving = false
local tankX = 400

local function randomFloat(min, max)
    return min + love.math.random() * (max - min)
end

function Stage:build()
    tankAngle = love.math.random(-90, 45)
    tankSpeed = love.math.random(5, 7)
end

function Stage:onSongRetry()
    self:moveTank(0)
end

function Stage:onUpdate(dt)
    self:moveTank(dt)
end

function Stage:moveTank(dt)
    local angleOffset = 1
    tankAngle = tankAngle + dt * tankSpeed

    local tankRolling = get("tankRolling")
    tankRolling.angle = math.rad(tankAngle - 90 + 15)
    tankRolling.x = tankX + math.cos(math.rad((tankAngle * angleOffset) + 180)) * 1500
    tankRolling.y = 1300 + math.sin(math.rad((tankAngle * angleOffset) + 180)) * 1100
end
