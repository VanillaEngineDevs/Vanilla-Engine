local AnimateAtlasCharacter = Character:extend()

function AnimateAtlasCharacter:new(data)
    AnimateAtlasCharacter.super.new(self, data)

    self.sprite = graphics.newTextureAtlas()
    self.assetPath = data.assetPath:gsub("shared:", "assets/")
    self.sprite:load(self.assetPath .. "")

    for i, anim in ipairs(data.animations) do
        local isIndices = anim.frameIndices ~= nil

        if isIndices then
            self.sprite:addAnimByIndices(anim.name, anim.prefix, anim.frameIndices, anim.framerate, anim.loop or false)
        else
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

function AnimateAtlasCharacter:update(dt)
    AnimateAtlasCharacter.super.update(self, dt)
    self.sprite:update(dt)
    self.sprite.x, self.sprite.y = self.x + self.offsets[1] - X_OFFSET_AMOUNT_FOR_SPITES, self.y + self.offsets[2] - Y_OFFSET_AMOUNT_FOR_SPRITES
    self.sprite.x = self.sprite.x - self.curAnimOffset[1]
    self.sprite.y = self.sprite.y - self.curAnimOffset[2]
    self.sprite.scale.x = self.scale.x
    self.sprite.scale.y = self.scale.y
    self.sprite.origin.x = self.origin.x
    self.sprite.origin.y = self.origin.y
    self.sprite.shader = self.shader
    self.sprite.visible = self.visible
    self.sprite.flipX = self.flipX
    self.sprite.flipY = self.flipY
end

function AnimateAtlasCharacter:updateHitbox()
    self.sprite:updateHitbox()
    self.width, self.height = self.sprite.width, self.sprite.height
end

function AnimateAtlasCharacter:play(name, forced, loop)
    self.sprite:play(name, forced, loop)

    self.sprite.x, self.sprite.y = self.x + self.offsets[1], self.y + self.offsets[2]
    for _, anim in ipairs(self.animations) do
        if anim.name == name and anim.offsets then
            self.sprite.x = self.sprite.x - anim.offsets[1] - X_OFFSET_AMOUNT_FOR_SPITES
            self.sprite.y = self.sprite.y - anim.offsets[2] - Y_OFFSET_AMOUNT_FOR_SPRITES
            self.curAnimOffset[1] = anim.offsets[1]
            self.curAnimOffset[2] = anim.offsets[2]
            break
        end
    end
end

function AnimateAtlasCharacter:draw(camera)
    self.sprite:draw(camera)
end

function AnimateAtlasCharacter:getWidth()
end

function AnimateAtlasCharacter:getHeight()
end

function AnimateAtlasCharacter:getDimensions()
end

return AnimateAtlasCharacter