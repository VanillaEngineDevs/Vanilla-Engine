local BGSprite = Sprite:extend()

function BGSprite:new(image, x, y, scrollX, scrollY, animArray, loop)
    self.idleAnim = ""
    local x = x or 0
    local y = y or 0
    local scrollX = scrollX or 1
    local scrollY = scrollY or 1
    local loop = (loop == nil) and true or loop

    self.super.new(self, x, y)

    self.idleAnim = ""

    if animArray then
        self:setFrames(Paths.getAtlas(image, "assets/images/png/" .. image .. ".xml"))
        for i = 1, #animArray do
            local anim = animArray[i]
            self:addByPrefix(anim, anim, 24, loop)
            if self.idleAnim == "" then
                self.idleAnim = anim
                self:play(anim)
            end
        end
    elseif image then -- CAN BE NIL!
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