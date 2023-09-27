local State = Group:extend()

function State:new()
    self.super.new(self)
end

function State:enter()

end

function State:update(dt)
    self.super.update(self, dt)
end

function State:draw()
    self.super.draw(self)
end

function State:destroy()
    self.super.destroy(self)
end

return State