local MultiSparrowCharacter = Character:extend()

function MultiSparrowCharacter:new(data)
    MultiSparrowCharacter.super.new(self, data)

    self.sprites = {}
    self.animations = {} -- will hold vars: name, prefix, sheet, offsetX, offsetY

    self.current = graphics.newTextureAtlas()
    self.assetPath = data.assetPath:gsub("shared:", "assets/")
    self.current:load(self.assetPath .. "")

    for i, anim in ipairs(data.animations) do
        if not anim.assetPath and not anim.asset then
            anim.assetPath = self.assetPath
        else
            local nuts = anim.assetPath or anim.asset
            anim.assetPath = nuts:gsub("shared:", "assets/")
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

function MultiSparrowCharacter:update(dt)
    MultiSparrowCharacter.super.update(self, dt)
    for _, spr in pairs(self.sprites) do
        spr:update(dt)
        spr.x, spr.y = self.x + self.offsets[1], self.y + self.offsets[2]
        spr.scale.x = self.scale.x
        spr.scale.y = self.scale.y
        spr.origin.x = self.origin.x
        spr.origin.y = self.origin.y
    end
end

function MultiSparrowCharacter:play(name, forced, loop)
    local animname = ""

    for _, anim in ipairs(self.animations) do
        for asset, spr in pairs(self.sprites) do
            if asset == anim.asset and name == anim.name then
                self.current = spr
                animname = anim.name
                break
            end
        end
        if animname ~= "" then break end
    end

    self.current:play(animname, forced, loop)
    self.current.x, self.current.y = self.x + self.offsets[1], self.y + self.offsets[2]
    for _, anim in ipairs(self.animations) do
        if anim.name == animname and anim.offsets then
            self.current.x = self.current.x + anim.offsets[1]
            self.current.y = self.current.y + anim.offsets[2]
            break
        end
    end
end

function MultiSparrowCharacter:draw()
    self.current:draw()
end

function MultiSparrowCharacter:getWidth()
    return self.current:getWidth()
end

function MultiSparrowCharacter:getHeight()
    return self.current:getHeight()
end

function MultiSparrowCharacter:getDimensions()
    return self.current:getWidth(), self.current:getHeight()
end

return MultiSparrowCharacter