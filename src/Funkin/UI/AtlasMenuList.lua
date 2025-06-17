---@class AtlasMenuItem : MenuListItem
local AtlasMenuItem = MenuListItem:extend()

function AtlasMenuItem:new(x, y, name, atlas, callback)
    self.atlas = atlas
    self.centered = false
    MenuListItem.new(self, x, y, name, callback)
end

function AtlasMenuItem:setData(name, callback)
    self.frames = self.atlas.frames
    self:load(self.atlas.graphic)
    self:addAnimByPrefix("idle", name .. " idle", 24)
    self:addAnimByPrefix("selected", name .. " selected", 24)

    MenuListItem.setData(self, name, callback)
end

function AtlasMenuItem:changeAnim(animName)
    self:play(animName)
    self:updateHitbox()

    if self.centered then
        self:centerOrigin()
        self.offset = table.copy(self.origin)
    end
end

function AtlasMenuItem:idle()
    self:changeAnim("idle")
end

function AtlasMenuItem:select()
    self:changeAnim("selected")
end

function AtlasMenuItem:getSelected()
    return self.curAnim ~= nil and self.curAnim.name == "selected" or false
end

function AtlasMenuItem:destroy()
    MenuListItem.destroy(self)
    self.atlas = nil
end

return AtlasMenuItem