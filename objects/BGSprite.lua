local BGSprite = Sprite:extend()

BGSprite.idleAnim = ""

function BGSprite:new(image, x, y, scrollX, scrollY, animArray, loop)
    local x = x or 0
    local y = y or 0
    local scrollX = scrollX or 1
    local scrollY = scrollY or 1
    local loop = (loop == nil) and true or loop

    self.super.new(self, x, y)

    if self.animArray then

    else
        self:load(image)
    end
    self.scrollFactor.x, self.scrollFactor.y = scrollX, scrollY

    self.camera = PlayState.camGame
end

function BGSprite:dance(forceplay)
    if self.idleAnim then
        self:play(self.idleAnim, forceplay)
    end
end

return BGSprite