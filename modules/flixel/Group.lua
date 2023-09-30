local Group = Object:extend()

Group.members = {}
Group.visible = true

function Group:new()
    self.members = {}
    self.visible = true
end

function Group:add(object)
    table.insert(self.members, object)
end

function Group:remove(object)
    for i, member in ipairs(self.members) do
        if member == object then
            table.remove(self.members, i)
            return
        end
    end
    return
end

function Group:clear()
    self.members = {}
end

function Group:update(dt)
    for i, member in ipairs(self.members) do
        if member.update then member:update(dt) end
    end
end

function Group:draw()
    for i, member in ipairs(self.members) do
        if self.antialiasing ~= nil then member.antialiasing = self.antialiasing end
        if member.draw and self.visible then member:draw() end
    end
end

function Group:destroy()
    for i, member in ipairs(self.members) do
        if member.destroy then member:destroy() end
    end
end

return Group