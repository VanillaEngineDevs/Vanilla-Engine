---@class State : Container
local State = Container:extend()

function State:new()
    self.persistentUpdate = false
    self.persistentDraw = true
    self.destroySubstate = true
    self.bgColor = 0x00000000

    self.subState = nil

    Container.new(self, 0)
end

function State:create()

end

function State:draw()
    if self.persistentDraw or self.subState == nil then
        Container.draw(self)
    end

    if self.subState ~= nil then
        self.subState:draw()
    end
end

function State:destroy()
    if self.subState ~= nil then
        self.subState:destroy()
        self.subState = nil
    end

    Container.destroy(self)
end

---@param onOutroComplete (function|nil)
function State:startOutro(onOutroComplete)
    local onOutroComplete = onOutroComplete or function() end
    onOutroComplete()
end

function State:onFocusLost()

end

function State:onFocus()

end

---@param Width integer
---@param Height integer
function State:onResize(Width, Height)

end

---@param dt number
function State:tryUpdate(dt)
    if self.persistentUpdate or self.subState == nil then
        Container.update(self, dt)
    end

    if self.subState ~= nil then
        self.subState:tryUpdate(dt)
    end
end

function State:closeSubState() 
end

return State