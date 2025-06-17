---@class MenuTypedList : Group
local MenuTypedList = Group:extend()

function MenuTypedList:new(navControls, wrapMode)
    self.selectedIndex = 0
    self.selectedItem = 1
    self.onChange = Signal()
    self.onAcceptPress = Signal()
    self.enabled = true
    self.wrapMode = wrapMode or "Both"
    self.navControls = navControls or "Vertical"

    self.byName = {}
    self.busy = false

    Group.new(self)
end

function MenuTypedList:addItem(name, item)
    if self.length == self.selectedIndex then 
        item:select()
    end

    self.byName[name] = item
    return self:add(item)
end

function MenuTypedList:resetItem(oldName, newName, callback)
    if self.byName[oldName] == nil then return print("Item not found: " .. oldName) end

    local item = self.byName[oldName]
    self.byName[oldName] = nil
    self.byName[newName] = item

    item:setItem(newName, callback)

    return item
end

function MenuTypedList:update(dt)
    Group.update(self, dt)

    if self.enabled and not self.busy then
        self:updateControls()
    end
end

function MenuTypedList:updateControls()
    local controls = nil -- TODO
end

function MenuTypedList:navAxis(index, size, prev, next, allowWrap)
    if prev == next then return index end

    if prev then
        if index > 0 then
            index = index - 1
        elseif allowWrap then
            index = size - 1
        end
    else
        if index < size - 1 then
            index = index + 1
        elseif allowWrap then
            index = 0
        end
    end
    
    return index
end

function MenuTypedList:navList(prev, next, allowWrap)
    return self:navAxis(self.selectedIndex, self.length, prev, next, allowWrap)
end

function MenuTypedList:navGrid(latSize, latPrev, latNext, latAllowWrap, prev, next, allowWrap)
    local size = math.ceil(self.length / latSize)
    local index = math.floor(self.selectedIndex / latSize)
    local latIndex = self.selectedIndex % latSize

    latIndex = self:navAxis(latIndex, latSize, latPrev, latNext, latAllowWrap)
    index = self:navAxis(index, size, prev, next, allowWrap)

    return math.floor(math.min(self.length - 1, index * latSize + latIndex))
end

function MenuTypedList:accept()
    local selected = self.members[self.selectedIndex + 1]
    self.onAcceptPress:dispatch(selected)

    if selected.fireInstantly then selected:callback()
    else 
        self.busy = true
        --FunkinSound:playOnce(Paths.sound("confirmMenu"))
    end
end

function MenuTypedList:selectItem(index)
    self.members[self.selectedIndex + 1]:idle()

    self.selectedIndex = index

    local selected = self.members[self.selectedIndex + 1]
    selected:select()
    self.onChange:dispatch(selected)
end

function MenuTypedList:has(name)
    return self.byName[name] ~= nil
end

function MenuTypedList:getItem(name)
    return self.byName[name]
end

function MenuTypedList:destroy()
    Group.destroy(self)
    self.byName = nil
    self.onChange:removeAll()
    self.onAcceptPress:removeAll()
end

---@class MenuListItem : Sprite
MenuListItem = Sprite:extend()

function MenuListItem:new(x, y, name, callback)
    self.fireInstantly = false
    self.selected = false

    Sprite.new(self, x, y)

    self:setData(name, callback)
    self:idle()
end

function MenuListItem:setData(name, callback)
    self.name = name

    if callback ~= nil then
        self.callback = callback
    end
end

function MenuListItem:setItem(name, callback)
    self:setData(name, callback)

    if self.selected then self:select()
    else self:idle() end
end

function MenuListItem:idle()
    self.alpha = 0
end

function MenuListItem:select()
    self.alpha = 1
end

return MenuTypedList