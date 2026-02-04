local AnimateAtlasCharacter = Character:extend()

function EXTEND_LIBRARY(assetPath, appendAssets)
    if appendAssets == nil then
        appendAssets = true
    end
    local lib, path = assetPath:match("^(.-):(.-)$")
    if lib and path then
        if lib ~= "shared" then
            lib = lib .. "/images"
        end
        assetPath = (appendAssets and "assets/" or "") .. lib:lower() .. "/" .. path
    else
        if not assetPath:startsWith("#") and not assetPath:startsWith("assets/") then
            assetPath = "shared/" .. assetPath
        end
    end

    return assetPath
end

function EXTEND_LIBRARY_SFX(assetPath)
    local lib, path = assetPath:match("^(.-):(.-)$")
    if lib and path then
        if lib ~= "shared" then
            lib = lib .. "/sounds"
        end
        assetPath = "assets/" .. lib:lower() .. "/" .. path
    else
        if not assetPath:startsWith("#") and not assetPath:startsWith("assets/") then
            assetPath = "shared/" .. assetPath
        end
    end

    return assetPath
end

function EXTEND_LIBRARY_MUSIC(assetPath)
    local lib, path = assetPath:match("^(.-):(.-)$")
    if lib and path then
        if lib ~= "shared" then
            lib = lib .. "/music"
        end
        assetPath = "assets/" .. lib:lower() .. "/" .. path
    else
        if not assetPath:startsWith("#") and not assetPath:startsWith("assets/") then
            assetPath = "shared/" .. assetPath
        end
    end

    return assetPath
end

function AnimateAtlasCharacter:new(data, _atlasSettings)
    AnimateAtlasCharacter.super.new(self, data)

    self.sprite = graphics.newTextureAtlas()
    local base = self
    function self.sprite:getAtlasSettings()
        return _atlasSettings or {}
    end
    self.assetPath = EXTEND_LIBRARY(data.assetPath)
    self.sprite:load(self.assetPath .. "")

    for i, anim in ipairs(data.animations) do
        local isIndices = anim.frameIndices ~= nil

        local animType = anim.animType or "prefix"
        if animType == "prefix" then
            if isIndices then
                self.sprite:addAnimByIndices(anim.name, anim.prefix, anim.frameIndices, anim.framerate or 24, anim.loop or false)
            else
                self.sprite:addAnimByPrefix(anim.name, anim.prefix, anim.framerate or 24, anim.loop or false)
            end
        elseif animType == "symbol" then
            if isIndices then
                self.sprite:addAnimBySymbolIndices(anim.name, anim.prefix, anim.frameIndices, anim.framerate or 24, anim.loop or false)
            else
                self.sprite:addAnimBySymbol(anim.name, anim.prefix, anim.framerate or 24, anim.loop or false)
            end
        end
    end

    for _, anim in ipairs(data.animations) do
        if anim.name == "danceLeft" then
            self.shouldAlternate = true
            break
        end
    end

    if self.sprite:hasAnimation("singLEFT") then
        self.sprite:play("singLEFT", true, false)
        if self.shouldAlternate then
            self.sprite:play("danceLeft", true, false)
        else
            self.sprite:play("idle", true, false)
        end
    end

    self.animations = data.animations
end

function AnimateAtlasCharacter:getAllAnimations()
    local anims = {}
    for _, anim in ipairs(self.animations) do
        table.insert(anims, anim.name)
    end
    return anims
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
    self.sprite.onFrameChange = self.onFrameChange
    self.sprite.onAnimationFinished = self.onAnimationFinished

    self.sprite.alpha = self.alpha or 0
end

function AnimateAtlasCharacter:updateHitbox()
    self.sprite:updateHitbox()
    self.width, self.height = self.sprite.width, self.sprite.height
end

function AnimateAtlasCharacter:play(name, forced, loop)
    -- does the sprite even have the animation?
    if not self.sprite:hasAnimation(name) then
        return
    end
    if self:isFunction("play") and not self.inScriptCall then
        self:call("play", name, forced, loop)
    else
        self.sprite:play(name, forced, loop)
    end

    self.sprite.x, self.sprite.y = self.x + self.offsets[1], self.y + self.offsets[2]
    for _, anim in ipairs(self.animations) do
        if anim.name == name then
            if anim.offsets then
                self.sprite.x = self.sprite.x - anim.offsets[1] - X_OFFSET_AMOUNT_FOR_SPITES
                self.sprite.y = self.sprite.y - anim.offsets[2] - Y_OFFSET_AMOUNT_FOR_SPRITES
                self.curAnimOffset[1] = anim.offsets[1]
                self.curAnimOffset[2] = anim.offsets[2]
            else
                self.curAnimOffset[1] = 0
                self.curAnimOffset[2] = 0
            end
            break
        end
    end
end

function AnimateAtlasCharacter:setAntialiasing(enabled)
    --self.sprite:setAntiAliasing(enabled)
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

function AnimateAtlasCharacter:getMidpoint()
    return self.sprite:getMidpoint()
end

return AnimateAtlasCharacter