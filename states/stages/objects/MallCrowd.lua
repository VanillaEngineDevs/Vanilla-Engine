local MallCrowd = BGSprite:extend()

MallCrowd.heyTimer = 0

function MallCrowd:new(x, y, sprite, idle, hey)
    local x = x or 0
    local y = y or 0
    local sprite = sprite or "stages/christmas/bottomBop"
    local idle = idle or "Bottom Level Boppers Idle"
    local hey = hey or "Bottom Level Boppers HEY"
    self.super.new(self, sprite, x, y, 0.9, 0.9, {idle})
    self:addByPrefix("hey", hey, 24, false)
    self.heyTimer = 0
end

function MallCrowd:update(dt)
    self.super.update(self, dt)

    if self.heyTimer > 0 then
        self.heyTimer = self.heyTimer - dt
        if self.heyTimer <= 0 then
            self:dance(true)
            self.heyTimer = 0
        end
    end
end

function MallCrowd:dance(forceplay)
    if self.heyTimer > 0 then
        return
    end
    self.super.dance(self, forceplay)
end

return MallCrowd