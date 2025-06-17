---@class Container : Group
local Container = Group:extend()

---@param maxSize (integer|nil)
function Container:new(maxSize)
    Group.new(self, maxSize)
end

---@param member table
function Container:onMemberAdd(member)
    if member.container ~= nil then table.remove(member.container, member) end

    member.container = self
end

---@param member table
function Container:onMemberRemove(member)
    member.container = nil
end

return Container