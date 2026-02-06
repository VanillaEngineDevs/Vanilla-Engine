local PackerCharacter = Character:extend()

function PackerCharacter:new(data)
    PackerCharacter.super.new(self, data)

    self.sprite = graphics.newSparrowAtlas()
    self.assetPath = EXTEND_LIBRARY(data.assetPath)
    self.sprite:load(self.assetPath .. "")

    for i, anim in ipairs(data.animations) do
        local isIndices = anim.frameIndices ~= nil and #anim.frameIndices > 0

        if isIndices then
            self.sprite:addAnimByIndices(anim.name, anim.prefix, anim.frameIndices, anim.framerate, anim.loop)
        else
            print("WARNING: Animation '" .. anim.name .. "' does not have frame indices defined, trying to add by prefix")
            self.sprite:addAnimByPrefix(anim.name, anim.prefix, anim.framerate, anim.loop or false)
        end
    end

    for _, anim in ipairs(data.animations) do
        if anim.name == "danceLeft" then
            self.shouldAlternate = true
            break
        end
    end

    self.animations = data.animations
end

function PackerCharacter:setAntialiasing(enabled)
    self.sprite:setAntialiasing(enabled)
end

function PackerCharacter:getAllAnimations()
    local anims = {}
    for _, anim in ipairs(self.animations) do
        table.insert(anims, anim.name)
    end
    return anims
end

function PackerCharacter:update(dt)
    PackerCharacter.super.update(self, dt)
    self.sprite:update(dt)
    self.sprite.scale.x = self.scale.x
    self.sprite.scale.y = self.scale.y

    self.sprite.x = self.x + self.offsets[1] - X_OFFSET_AMOUNT_FOR_SPITES
    self.sprite.y = self.y + self.offsets[2] - Y_OFFSET_AMOUNT_FOR_SPRITES
    self.sprite.x = self.sprite.x - (self.curAnimOffset[1] * self.scale.x)
    self.sprite.y = self.sprite.y - (self.curAnimOffset[2] * self.scale.y)
    self.sprite.origin.x = self.origin.x
    self.sprite.origin.y = self.origin.y
    self.sprite.shader = self.shader
    self.sprite.visible = self.visible
    self.sprite.flipX = self.flipX
    self.sprite.flipY = self.flipY
    self.sprite.onFrameChange = self.onFrameChange
    self.sprite.onAnimationFinished = self.onAnimationFinished

    self.sprite.alpha = self.alpha or 1
end

function PackerCharacter:updateHitbox()
    self.sprite:updateHitbox()
    self.width, self.height = self.sprite.width, self.sprite.height
end

function PackerCharacter:play(name, forced, loop)
    if self:isFunction("play") and not self.inScriptCall then
        self:call("play", name, forced, loop)
    else
        self.sprite:play(name, forced, loop)
    end

    for _, anim in ipairs(self.animations) do
        if anim.name == name then
            if anim.offsets then
                self.sprite.x = self.sprite.x + self.offsets[1] - X_OFFSET_AMOUNT_FOR_SPITES
                self.sprite.y = self.sprite.y + self.offsets[2] - Y_OFFSET_AMOUNT_FOR_SPRITES
                self.curAnimOffset[1] = anim.offsets[1]
                self.curAnimOffset[2] = anim.offsets[2]
            else
                self.curAnimOffset[1] = 0
                self.curAnimOffset[2] = 0
            end
            break
        end
    end

    self.sprite.x = self.x + (self.offsets[1] * self.scale.x) - X_OFFSET_AMOUNT_FOR_SPITES - (self.curAnimOffset[1] * self.scale.x)
    self.sprite.y = self.y + (self.offsets[2] * self.scale.y) - Y_OFFSET_AMOUNT_FOR_SPRITES - (self.curAnimOffset[2] * self.scale.y)
end

function PackerCharacter:draw(camera)
    self.sprite:draw(camera)
end

function PackerCharacter:getWidth()
end

function PackerCharacter:getHeight()
end

function PackerCharacter:getDimensions()
end

function PackerCharacter:getMidpoint()
    return self.sprite:getMidpoint()
end

return PackerCharacter