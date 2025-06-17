---@class Basic
local Basic = Class:extend()

Basic.idEnumerator = 0
if Config.Debug then
    Basic.activeCount = 0
    Basic.visibleCount = 0
end

function Basic:new()
    Basic.idEnumerator = Basic.idEnumerator + 1

    self.ID = Basic.idEnumerator

    self.active = true
    self.visible = true
    self.alive = true
    self.exists = true
    self.cameras = nil

    self.container = nil
end

function Basic:destroy()
    if self.container ~= nil then
        self.container:remove(self)
    end
    self.container = nil
    self.exists = false
    self.cameras = nil
end

function Basic:kill()
    self.alive = false
    self.exists = false
end

function Basic:revive()
    self.alive = true
    self.exists = true
end

function Basic:update(dt)
    if Config.Debug then
        Basic.activeCount = Basic.activeCount + 1
    end
end

function Basic:draw()
    if Config.Debug then
        Basic.visibleCount = Basic.visibleCount + 1
    end

    for _, camera in ipairs(self.cameras or Camera._defaultCameras) do
        if camera.visible and camera.exists then
            table.insert(camera.renders, self)
        end
    end
end

function Basic:getCameras()
    return (
        self.cameras ~= nil and self.cameras
        or self.cameras == nil and self.container ~= nil and self.container:getCameras()
        or Camera._defaultCameras
    )
end

return Basic