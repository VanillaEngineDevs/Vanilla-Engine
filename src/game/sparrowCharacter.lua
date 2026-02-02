local SparrowCharacter = Character:extend()

function SparrowCharacter:new(data)
    SparrowCharacter.super.new(self, data)

    self.sprite = graphics.newSparrowAtlas()
    self.assetPath = data.assetPath:gsub("shared:", "assets/")
    self.sprite:load(self.assetPath .. "")

    for i, anim in ipairs(data.animations) do
        local isIndices = anim.frameIndices ~= nil

        if isIndices then
            self.sprite:addAnimByIndices(anim.name, anim.prefix, anim.frameIndices, anim.framerate, anim.loop)
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

function SparrowCharacter:update(dt)
    SparrowCharacter.super.update(self, dt)
    self.sprite:update(dt)
    self.sprite.x = self.x + (self.offsets[1] * self.scale.x) - X_OFFSET_AMOUNT_FOR_SPITES
    self.sprite.y = self.y + (self.offsets[2] * self.scale.y) - Y_OFFSET_AMOUNT_FOR_SPRITES
    self.sprite.x = self.sprite.x - (self.curAnimOffset[1] * self.scale.x)
    self.sprite.y = self.sprite.y - (self.curAnimOffset[2] * self.scale.y)
    self.sprite.scale.x = self.scale.x
    self.sprite.scale.y = self.scale.y
    self.sprite.origin.x = self.origin.x
    self.sprite.origin.y = self.origin.y
    self.sprite.shader = self.shader
    self.sprite.visible = self.visible
    self.sprite.flipX = self.flipX
    self.sprite.flipY = self.flipY
end

function SparrowCharacter:updateHitbox()
    self.sprite:updateHitbox()
    self.width, self.height = self.sprite.width, self.sprite.height
end

function SparrowCharacter:play(name, forced, loop)
    self.sprite:play(name, forced, loop)

    for _, anim in ipairs(self.animations) do
        if anim.name == name and anim.offsets then
            self.sprite.x = self.sprite.x + self.offsets[1] - X_OFFSET_AMOUNT_FOR_SPITES
            self.sprite.y = self.sprite.y + self.offsets[2] - Y_OFFSET_AMOUNT_FOR_SPRITES
            self.curAnimOffset[1] = anim.offsets[1]
            self.curAnimOffset[2] = anim.offsets[2]
            break
        end
    end

    self.sprite.x = self.x + (self.offsets[1] * self.scale.x) - X_OFFSET_AMOUNT_FOR_SPITES - (self.curAnimOffset[1] * self.scale.x)
    self.sprite.y = self.y + (self.offsets[2] * self.scale.y) - Y_OFFSET_AMOUNT_FOR_SPRITES - (self.curAnimOffset[2] * self.scale.y)
end

function SparrowCharacter:draw(camera)
    self.sprite:draw(camera)
end

function SparrowCharacter:getWidth()
end

function SparrowCharacter:getHeight()
end

function SparrowCharacter:getDimensions()
end

return SparrowCharacter