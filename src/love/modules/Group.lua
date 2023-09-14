local Group = Object:extend()
Group.members = {}

function Group:new()
    self.members = {}

    return self
end

function Group:add(member)
    table.insert(self.members, member)
end

function Group:remove(member)
    table.remove(self.members, table.find(self.members, member))
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

return Group