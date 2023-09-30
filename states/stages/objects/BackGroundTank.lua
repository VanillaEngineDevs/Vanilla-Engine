local BackGroundTank = BGSprite:extend() -- kills the game for some reason?? idfk

function BackGroundTank:new()
    self.offsetX = 400
    self.offsetY = 1300
    self.tankSpeed = 0
    self.tankAngle = 0

    self.super:new("stages/tank/tankRolling", 0, 0, 0.5, 0.5, {"BG tank w lighting"}, true)

    self.camera = PlayState.camGame
    
    return self
end

function BackGroundTank:update(dt)
    self.super.update(self, dt)

    self.tankAngle = self.tankAngle + dt * self.tankSpeed
    self.angle = self.tankAngle - 90 + 15
    self.x = self.offsetX + 1500 * math.cos(math.pi/180 * (self.tankAngle + 180))
    self.y = self.offsetY + 1100 * math.sin(math.pi/180 * (self.tankAngle + 180))
end

return BackGroundTank