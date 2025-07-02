local FunkinSprite = Sprite:extend()

function FunkinSprite:isAnimationDynamic(id)
    if self.curAnim == nil then return false end
    local animData = self:getAnimByName(id)
    if animData == nil then return false end
    return #animData.frames > 1
end

function FunkinSprite:loadSparrow(key)
    local data = Paths.getSparrowAtlas(key)

    self:setFrames(data) -- also sets the image!
end

function FunkinSprite:loadTexture(key)
    self:load(Paths.image(key))
end

return FunkinSprite