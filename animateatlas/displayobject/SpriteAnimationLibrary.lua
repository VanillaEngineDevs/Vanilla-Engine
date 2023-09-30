local SpriteAnimationLibrary = Object:extend()

function SpriteAnimationLibrary:new(data, atlas, graphic)
    self.framerate = 30

    self._atlas = {}
    self._symbolData = {}
    self._symbolPool = {}
    self._defaultSymbolName = ""
    self._texture = graphic
    self.smoothing = false

    self.BITMAP_SYMBOL_NAME = "___atlas_sprite___"

    self.STD_MATRIX3D_DATA = {
        m00 = 1,
        m01 = 0,
        m02 = 0,
        m03 = 0,
        m10 = 0,
        m11 = 1,
        m12 = 0,
        m13 = 0,
        m20 = 0,
        m21 = 0,
        m22 = 1,
        m23 = 0,
        m30 = 0,
        m31 = 0,
        m32 = 0,
        m33 = 1
    }

    self:parseAnimationData(data)
    self:parseAtlasData(atlas)
end

function SpriteAnimationLibrary:hasAnimation(name)
    return self:hasSymbol(name)
end

function SpriteAnimationLibrary:createAnimation(noAntialiasing, symbol)
    self.smoothing = not noAntialiasing
    self.symbol = symbol or self._defaultSymbolName
    if not self:hasSymbol(self.symbol) then
        return error("Symbol " .. self.symbol .. " does not exist in this SpriteAnimationLibrary.")
    end
    return SpriteMovieClip(self:getSymbol(symbol))
end

function SpriteAnimationLibrary:getAnimationNames(prefix)
    local prefix = prefix or ""
    
    local out = {}

    for i, name in ipairs(self._symbolData) do
        if name ~= self.BITMAP_SYMBOL_NAME and name:indexOf(prefix) == 0 then
            table.insert(out, name)
        end

        table.sort(out, function(a, b)
            a = a:lower()
            b = b:lower()

            if a < b then
                return -1
            elseif a > b then
                return 1
            else
                return 0
            end
        end)
    end

    return out
end

function SpriteAnimationLibrary:getSpriteData(name)
    return self._atlas[name]
end

function SpriteAnimationLibrary:hasSymbol(name)
    return self._atlas[name] ~= nil
end

function SpriteAnimationLibrary:getSymbol(name)
    local pool = self:getSymbolPool(name)
    if #pool == 0 then
        local symbol = SpriteSymbol(self:getSymbolData(name), self, self._texture)
        symbol.smoothing = self.smoothing
        return symbol
    else
        return table.remove(pool, 1)
    end
end

function SpriteAnimationLibrary:putSymbol(symbol)
    -- reset symbol
    symbol:reset()
    local pool = self:getSymbolPool(symbol.symbolName)
    table.insert(pool, symbol)
    symbol.currentFrame = 1
end

function SpriteAnimationLibrary:getSymbolPool(name)
    local pool = self._symbolPool[name]
    if not pool then
        pool = {}
        self._symbolPool[name] = pool
    end
    return pool
end

function SpriteAnimationLibrary:parseAnimationData(data)
    local metaData = data.metadata

    if metaData and metaData.framerate and metaData.framerate > 0 then
        self.framerate = metaData.framerate
    else
        self.framerate = 24
    end

    self._symbolData = {}

    local symbols = data.SYMBOL_DICTIONARY.Symbols
    for i, symbolData in ipairs(symbols) do
        self._symbolData[symbolData.SYMBOL_name] = self:preprocessSymbolData(symbolData)
    end

    local defaultSymbolData = self:preprocessSymbolData(data.ANIMATION)
    self._defaultSymbolName = defaultSymbolData.SYMBOL_name
    self._symbolData[self._defaultSymbolName] = defaultSymbolData

    self._symbolData[self.BITMAP_SYMBOL_NAME] = {
        SYMBOL_name = self.BITMAP_SYMBOL_NAME,
        TIMELINE = {
            LAYERS = {}
        }
    }
end

function SpriteAnimationLibrary:preprocessSymbolData(symbolData)
    local timeLineData = symbolData.TIMELINE
    local layerDates = timeLineData.LAYERS

    if not timeLineData.sortedForRender then
        timeLineData.sortedForRender = true
        -- reverse layerDates
        layerDates = table.reverse(layerDates)
    end

    for i, layerData in ipairs(layerDates) do
        local frames = layerData.Frames

        for i, frame in ipairs(frames) do
            local elements = frame.elements
            for e = 1, #elements do
                local element = elements[e]
                if element.ATLAS_SPRITE_instance then
                    element = {
                        SYMBOL_name = self.BITMAP_SYMBOL_NAME,
                        Instance_Name = "InstName",
                        bitmap = element.ATLAS_SPRITE_instance,
                        symbolType = "graphic",
                        firstFrame = 1,
                        loop = true,
                        transformationPoint = {
                            x = 0,
                            y = 0
                        },
                        Matrix3D = self.STD_MATRIX3D_DATA
                    }
                    elements[e] = element
                end
            end
        end
    end

    return symbolData
end

function SpriteAnimationLibrary:parseAtlasData(atlas)
    self._atlas = {}
    if atlas.ATLAS and atlas.ATLAS.SPRITES then
        for i, frame in ipairs(atlas.ATLAS.SPRITES) do
            self._atlas[frame.SPRITE.name] = frame.SPRITE
        end
    end
end

function SpriteAnimationLibrary:getSymbolData(name)
    return self._symbolData[name]
end

return SpriteAnimationLibrary