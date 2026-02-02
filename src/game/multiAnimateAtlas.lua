local MultiAnimateAtlasCharacter = Character:extend()

function MultiAnimateAtlasCharacter:new(data)
    MultiAnimateAtlasCharacter.super.new(self, data)

    self.sprites = {}
    self.animations = {} -- will hold vars: name, prefix, sheet, offsetX, offsetY

    self.sprite = graphics.newTextureAtlas()
    self.assetPath = EXTEND_LIBRARY(data.assetPath)
    self.sprite:load(self.assetPath .. "")

    for i, anim in ipairs(data.animations) do
        if not anim.assetPath and not anim.asset then
            anim.assetPath = self.assetPath
        else
            local nuts = anim.assetPath or anim.asset
            anim.assetPath = EXTEND_LIBRARY(nuts)
        end

        table.insert(
            self.animations,
            {
                name = anim.name,
                atlasanim = anim.prefix,
                asset = anim.assetPath,
                offsets = anim.offsets
            }
        )
    end

    for _, anim in ipairs(self.animations) do
        if not self.sprites[anim.asset] then
            self.sprites[anim.asset] = graphics.newTextureAtlas()
            self.sprites[anim.asset]:load(anim.asset)
        end

        self.sprites[anim.asset]:addAnimByPrefix(
            anim.name,
            anim.atlasanim,
            24,
            anim.loop or false
        )
    end

    for _, anim in ipairs(self.animations) do
        if anim.name == "danceLeft" then
            self.shouldAlternate = true
            break
        end
    end
end

function MultiAnimateAtlasCharacter:updateHitbox()
    self.sprite:updateHitbox()
    self.width, self.height = self.sprite.width, self.sprite.height
end

function MultiAnimateAtlasCharacter:update(dt)
    MultiAnimateAtlasCharacter.super.update(self, dt)
    for _, spr in pairs(self.sprites) do
        spr:update(dt)
        spr.x, spr.y = self.x + self.offsets[1] - X_OFFSET_AMOUNT_FOR_SPITES, self.y + self.offsets[2] - Y_OFFSET_AMOUNT_FOR_SPRITES
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

function MultiAnimateAtlasCharacter:setAntialiasing(enabled)
    for _, spr in pairs(self.sprites) do
        --spr:setAntiAliasing(enabled)
    end
end

function MultiAnimateAtlasCharacter:play(name, forced, loop)
    local animname = ""

    for _, anim in ipairs(self.animations) do
        for asset, spr in pairs(self.sprites) do
            if asset == anim.asset and name == anim.name then
                self.sprite = spr
                animname = anim.name
                break
            end
        end
        if animname ~= "" then break end
    end

    if self:isFunction("play") and not self.inScriptCall then
        self:call("play", animname, forced, loop)
    else
        self.sprite:play(animname, forced, loop)
    end
    self.sprite.x, self.sprite.y = self.x + self.offsets[1] - X_OFFSET_AMOUNT_FOR_SPITES, self.y + self.offsets[2] - Y_OFFSET_AMOUNT_FOR_SPRITES
    for _, anim in ipairs(self.animations) do
        if anim.name == animname and anim.offsets then
            self.sprite.x = self.sprite.x + anim.offsets[1] - X_OFFSET_AMOUNT_FOR_SPITES
            self.sprite.y = self.sprite.y + anim.offsets[2] - Y_OFFSET_AMOUNT_FOR_SPRITES
            break
        end
    end
end

function MultiAnimateAtlasCharacter:draw(camera)
    self.sprite:draw(camera)
end

function MultiAnimateAtlasCharacter:getWidth()
    return self.sprite:getWidth()
end

function MultiAnimateAtlasCharacter:getHeight()
    return self.sprite:getHeight()
end

function MultiAnimateAtlasCharacter:getDimensions()
    return self.sprite:getWidth(), self.sprite:getHeight()
end

function MultiAnimateAtlasCharacter:getMidpoint()
    return self.sprite:getMidpoint()
end

return MultiAnimateAtlasCharacter