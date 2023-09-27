local Group = Object:extend()

Group.members = {}

function Group:new()
    self.members = {}
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
        if member.draw then member:draw() end
    end
end

function Group:destroy()
    for i, member in ipairs(self.members) do
        if member.destroy then member:destroy() end
    end
end

return Group