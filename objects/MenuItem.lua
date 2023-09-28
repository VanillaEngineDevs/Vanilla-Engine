local MenuItem = Sprite:extend()

MenuItem.targetY = 0
MenuItem.flashingInt = 0
MenuItem.isFlashing = false

function MenuItem:new(x, y, weekName)
    local weekName = weekName or ""

    self.super.new(self, x, y)

    self.targetY = 0
    self.flashingInt = 0
    self.isFlashing = false

    self:load("menu/storymenu/" .. weekName)
end

function MenuItem:startFlashing()
    self.isFlashing = true
end

function MenuItem:update(dt)
    self.super.update(self, dt)

    local fakeFramerate = math.round((1/dt) / 10)

    self.y = math.lerp(self.y, ((self.targetY+1) * 120) + 480, math.bound(dt * 10.2, 0, 1))

    if self.isFlashing then
        self.flashingInt = self.flashingInt + 1
    end

    if self.flashingInt % fakeFramerate >= math.floor(fakeFramerate / 2) then
        self.color = hexToColor(0xFF33FFFF)
    else
        self.color = hexToColor(0xFFFFFFFF)
    end
end

return MenuItem
