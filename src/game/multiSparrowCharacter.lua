local MultiSparrowCharacter = Character:extend()

function MultiSparrowCharacter:new(data)
    MultiSparrowCharacter.super.new(self, data)

    self.sprites = {}
    self.animations = {} -- will hold vars: name, prefix, sheet, offsetX, offsetY

    self.sprite = graphics.newSparrowAtlas()
    self.assetPath = EXTEND_LIBRARY(data.assetPath)
    self.sprite:load(self.assetPath .. "")

    for i, anim in ipairs(data.animations) do
        if not anim.assetPath and not anim.asset then
            anim.assetPath = self.assetPath
        else
            local nuts = anim.assetPath or anim.asset
            anim.assetPath = EXTEND_LIBRARY(nuts)
        end

        local isIndices = anim.frameIndices ~= nil

        table.insert(
            self.animations,
            {
                name = anim.name,
                atlasanim = anim.prefix,
                asset = anim.assetPath,
                offsets = anim.offsets,
                frameIndices = anim.frameIndices,
                isIndices = isIndices
            }
        )
    end

    for _, anim in ipairs(self.animations) do
        if not self.sprites[anim.asset] then
            self.sprites[anim.asset] = graphics.newSparrowAtlas()
            self.sprites[anim.asset]:load(anim.asset)
        end

        if anim.isIndices then
            self.sprites[anim.asset]:addAnimByIndices(
                anim.name,
                anim.atlasanim,
                anim.frameIndices,
                "",
                24,
                anim.loop or false
            )
        else
            self.sprites[anim.asset]:addAnimByPrefix(
                anim.name,
                anim.atlasanim,
                24,
                anim.loop or false
            )
        end
    end

    for _, anim in ipairs(self.animations) do
        if anim.name == "danceLeft" then
            self.shouldAlternate = true
            break
        end
    end
end

function MultiSparrowCharacter:updateHitbox()
    self.sprite:updateHitbox()
    self.width, self.height = self.sprite.width, self.sprite.height
end

function MultiSparrowCharacter:setAntialiasing(enabled)
    for _, spr in pairs(self.sprites) do
        spr:setAntialiasing(enabled)
    end
end

function MultiSparrowCharacter:update(dt)
    MultiSparrowCharacter.super.update(self, dt)
    for _, spr in pairs(self.sprites) do
        spr:update(dt, (self.sprite == spr))
        spr.x = self.x + self.offsets[1] - X_OFFSET_AMOUNT_FOR_SPITES
        spr.y = self.y + self.offsets[2] - Y_OFFSET_AMOUNT_FOR_SPRITES
        spr.x = spr.x - self.curAnimOffset[1]
        spr.y = spr.y - self.curAnimOffset[2]
        spr.scale.x = self.scale.x
        spr.scale.y = self.scale.y
        spr.origin.x = self.origin.x
        spr.origin.y = self.origin.y
        spr.shader = self.shader
        spr.visible = self.visible
        spr.flipX = self.flipX
        spr.flipY = self.flipY
        spr.onFrameChange = self.onFrameChange
        spr.onAnimationFinished = self.onAnimationFinished
    end
end

function MultiSparrowCharacter:play(name, forced, loop)
    local animname = nil
    local targetSprite = nil

    for _, anim in ipairs(self.animations) do
        if anim.name == name then
            targetSprite = self.sprites[anim.asset]
            if targetSprite then
                animname = anim.name
            end
            break
        end
    end

    if self:isFunction("play") and not self.inScriptCall then
        self:call("play", name, forced, loop)
    end

    if not animname or not targetSprite then
        return
    end

    self.sprite = targetSprite
    self.sprite:play(animname, forced, loop)

    for _, anim in ipairs(self.animations) do
        if anim.name == animname then
            if anim.offsets then
                self.curAnimOffset[1] = anim.offsets[1]
                self.curAnimOffset[2] = anim.offsets[2]
            else
                self.curAnimOffset[1] = 0
                self.curAnimOffset[2] = 0
            end
            break
        end
    end

    self.sprite.x = self.x + self.offsets[1] - X_OFFSET_AMOUNT_FOR_SPITES - self.curAnimOffset[1]
    self.sprite.y = self.y + self.offsets[2] - Y_OFFSET_AMOUNT_FOR_SPRITES - self.curAnimOffset[2]
end


function MultiSparrowCharacter:draw(camera)
    self.sprite:draw(camera)
end

function MultiSparrowCharacter:getWidth()
    return self.sprite:getWidth()
end

function MultiSparrowCharacter:getHeight()
    return self.sprite:getHeight()
end

function MultiSparrowCharacter:getDimensions()
    return self.sprite:getWidth(), self.sprite:getHeight()
end

function MultiSparrowCharacter:getMidpoint()
    return self.sprite:getMidpoint()
end

return MultiSparrowCharacter