local FunkinSprite = Sprite:extend()

function FunkinSprite:isAnimationDynamic(id)
    if self.curAnim == nil then return false end
    local animData = self:getAnimByName(id)
    if animData == nil then return false end
    return #animData.frames > 1
end

return FunkinSprite