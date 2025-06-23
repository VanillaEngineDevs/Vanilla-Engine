---@class Group
local Group = Basic:extend()

---@param member table
---@return any
function Group:onMemberAdd(member) end
---@param member table
---@return any
function Group:onMemberRemove(member) end

---@param maxSize (integer|nil)
---@return nil
function Group:new(maxSize)
    self.members = {}
    self.maxSize = math.floor(math.abs(maxSize or 0)) -- 0 = unlimited
    self.length = 0
    self._cameras = nil

    Basic.new(self)
end

---@return nil
function Group:destroy()
    if self.members ~= nil then
        local count = self.length
        while count > 0 do
            if #self.members > 0 then
                local member = table.remove(self.members, 1)
                if member and member.destroy then
                    member:destroy()
                end
            else
                break
            end

            count = count - 1
        end

        self.members = nil
    end
end 

---@param dt float
---@return nil
function Group:update(dt)
    for _, member in ipairs(self.members) do
        if member and member.exists and member.active and member.update then
            member:update(dt)
        end
    end
end

---@return nil
function Group:draw()
    local oldDefaultCameras = Camera._defaultCameras
    if self._cameras ~= nil then
        Camera._defaultCameras = self._cameras
    end

    for _, member in ipairs(self.members) do
        if member and member.exists and member.visible and member.draw then
            member:draw()
        end
    end

    Camera._defaultCameras = oldDefaultCameras
end

---@param member table
---@return (table | nil)
function Group:add(member)
    if member == nil then
        print("Cannot add a `nil` object to a Group")
        return nil
    end

    --[[ if table.contains(self.members, member) ~= -1 then
        print("Member already in group")
        return member
    end ]]

    if self.maxSize > 0 and self.length >= self.maxSize then
        print("Attempted to add member to filled Group (Size: " .. self.maxSize .. ")")
        return member
    end

    table.insert(self.members, member)
    self.length = self.length + 1
    self:onMemberAdd(member)

    return member
end

---@param position integer
---@param object table
---@return nil
function Group:insert(position, object)

end

---@param objectClass table
---@param objectFactory table
---@param force boolean
---@return nil
function Group:recycle(objectClass, objectFactory, force)
    local function createObject()
        if objectFactory ~= nil then
            return self:add(objectFactory())
        end

        if objectClass ~= nil then
            return self:add(objectClass())
        end

        return self:add(Basic())
    end

    if self.maxSize > 0 then
        if self.length < self.maxSize then
            return createObject()
        end

        local basic = self.members[self._marker]
        self._marker = self._marker + 1

        if self._marker >= self.maxSize then
            self._marker = 0
        end

        basic:revive()

        return basic
    end

    local basic = self:getFirstAvailable(objectClass, force)

    if basic ~= nil then
        basic:revive()
        return basic
    end

    return createObject()
end

---@param objectClass table
---@param force boolean
---@return (table|nil)  
function Group:getFirstAvailable(objectClass, force)
    local result = self:getFirst(function(member)
        return member and member.exists and member:isInstanceOf(objectClass) and (force or not member.active)
    end)

    if result == nil then
        return nil
    end

    return result
end

---@param member table
---@param splice boolean
---@return (table|nil)
function Group:remove(member, splice)
    if #self.members == nil then return nil end

    local index = table.find(self.members, member)
    if index == -1 then
        return nil
    end

    if splice then
        table.remove(self.members, index)
        self.length = self.length - 1
    else
        self.members[index] = nil
    end

    self:onMemberRemove(member)

    return member
end

---@param oldObject table
---@param newObject table
---@return (table|nil)
function Group:replace(oldObject, newObject)
    local index = table.find(self.members, oldObject)
    if index == -1 then return nil end

    self.members[index] = newObject

    self:onMemberRemove(oldObject)
    self:onMemberAdd(newObject)

    return newObject
end

---@param func function
function Group:sort(func)
    table.sort(self.members, func)
end

---@param func function
---@return (table|nil)
function Group:getFirst(func)
    return self:getFirstHelper(func)
end

---@private
---@param func function
---@return (table|nil)
function Group:getFirstHelper(func)
    local result = nil
    for _, member in ipairs(self.members) do
        if member and func(member) then
            result = member
            break
        end
    end

    return result
end

---Kill all members in a group
---@return nil
function Group:killMembers()
    for _, member in ipairs(self.members) do
        if member and member.exists and member.kill then
            member:kill()
        end
    end
end

---Kills the group
---@return nil
function Group:kill()
    self:killMembers()
end

---Revive all members in a group
---@return nil
function Group:reviveMembers()
    for _, member in ipairs(self.members) do
        if member and member.exists and member.revive then
            member:revive()
        end
    end
end

---Revive the group
---@return nil
function Group:revive()
    self:reviveMembers()
end

function Group:getCameras()
end

---Resorts the members by z-index
---@return nil
function Group:refresh()
    self:sort(function(a, b)
        return a.zIndex or 0 < b.zIndex or 0
    end)
end

function Group:clear()
    local count = self.length
    while count > 0 do
        if #self.members > 0 then
            local member = table.remove(self.members, 1)
            if member and member.destroy then
                member:destroy()
            end
        else
            break
        end

        count = count - 1
    end

    self.length = 0
end

function Group:getObjects()
    return self.members
end

return Group