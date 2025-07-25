---@diagnostic disable: missing-fields
--[[ local Bit = require("loveanimate.libs.Bit")
local Classic = require("loveanimate.libs.Classic") ]]
local baseDirectory = (...):match("(.-)[^%.]+$"):gsub("AnimateAtlas", "")
local Bit = require(baseDirectory .. "libs.Bit")
local Classic = require(baseDirectory .. "libs.Classic")

local function intToRGB(int)
	return
		Bit.band(Bit.rshift(int, 16), 0xFF) / 255,
		Bit.band(Bit.rshift(int, 8), 0xFF) / 255,
		Bit.band(int, 0xFF) / 255,
		Bit.band(Bit.rshift(int, 24), 0xFF) / 255
end

---
--- @class love.animate.AnimateAtlas
---
local AnimateAtlas = Classic:extend()

local json = require(baseDirectory .. "libs.Json")
require(baseDirectory .. "libs.StringUtil")

function AnimateAtlas:constructor(object)
    self.frame = 0
    self.symbol = ""
    self.playing = false

    --- @protected
    self._curSymbol = nil

    --- @protected
    self._frameTimer = 0

    --- @protected
    self._rotatedAtlasSpriteTextures = {} --- @type table<string, love.Image>

    --- @protected
    self._colorTransformShader = love.graphics.newShader([[
        extern vec4 colorOffset;
        extern vec4 colorMultiplier;

        vec4 effect(vec4 color, Image tex, vec2 texCoords, vec2 screenCoords) {
            vec4 finalColor = Texel(tex, texCoords) * color;
            finalColor += colorOffset;
            return finalColor * colorMultiplier;
        }
    ]])
    self:setColorOffset(0, 0, 0, 0)
    self:setColorMultiplier(1, 1, 1, 1)

    self._callback = nil
    self.objectReference = object
end

function AnimateAtlas:setColorOffset(r, g, b, a)
    self._colorTransformShader:send("colorOffset", {r, g, b, a})
end

function AnimateAtlas:setColorMultiplier(r, g, b, a)
    self._colorTransformShader:send("colorMultiplier", {r, g, b, a})
end

local colorTransforms = {
    brightness = function(self, colorTransform)
        local brightness = colorTransform["brightness"]
        self:setColorOffset(brightness, brightness, brightness, 0)
        self:setColorMultiplier(
            1 - math.abs(brightness),
            1 - math.abs(brightness),
            1 - math.abs(brightness),
            1
        )
    end,
    tint = function(self, colorTransform)
        local tintColor = tonumber("0xFF" + colorTransform["tintColor"]:sub(2))
        local tintR, tintG, tintB = intToRGB(tintColor)

        local multiplier = colorTransform["tintMultiplier"]
        self:setColorOffset(
            tintR * multiplier,
            tintG * multiplier,
            tintB * multiplier,
            0
        )
        self:setColorMultiplier(
            1 - multiplier,
            1 - multiplier,
            1 - multiplier,
            1
        )
    end,
    alpha = function(self, colorTransform)
        local alphaMultiplier = colorTransform["alphaMultiplier"]
        self:setColorMultiplier(1, 1, 1, alphaMultiplier)
    end,
    advanced = function(self, colorTransform)
        self:setColorOffset(
            colorTransform["redOffset"],
            colorTransform["greenOffset"],
            colorTransform["blueOffset"],
            colorTransform["AlphaOffset"]
        )
        self:setColorMultiplier(
            colorTransform["RedMultiplier"],
            colorTransform["greenMultiplier"],
            colorTransform["blueMultiplier"],
            colorTransform["alphaMultiplier"]
        )
    end
}

--- Load the atlas from folder
--- @param folder string
---
function AnimateAtlas:load(folder)
    for key, value in pairs(self._rotatedAtlasSpriteTextures) do
        value:release()
        self._rotatedAtlasSpriteTextures[key] = nil
    end
    self.timeline = {}
    self.timeline.data = json.decode(love.filesystem.read("string", folder .. "/" .. "Animation.json"))
    self.timeline.optimized = self.timeline.data.AN ~= nil

    self.spritemaps = {}
    for _, item in ipairs(love.filesystem.getDirectoryItems(folder)) do
        if string.startsWith(item, "spritemap") and string.endsWith(item, ".json") then
            local jsonStr = love.filesystem.read("string", folder .. "/" .. item)
            jsonStr = jsonStr:gsub("^[^%[%{]*", "")
            jsonStr = jsonStr:gsub("[^%]%}]*$", "")
            jsonStr = jsonStr:gsub("・", "")
            
            local data = json.decode(jsonStr)
            local texture = love.graphics.newImage(folder .. "/" .. string.sub(item, 1, #item - 5) .. ".png")
            table.insert(self.spritemaps, { data = data, texture = texture })
        end
    end
    self.libraries = {}
    if self.timeline.data.SD ~= nil or self.timeline.data.SYMBOL_DICTIONARY ~= nil then
        -- regular adobe format
        local optimized = self.timeline.data.SD ~= nil
        local symbolDictionary = self.timeline.data[optimized and "SD" or "SYMBOL_DICTIONARY"]
        
        local symbols = symbolDictionary[optimized and "S" or "Symbols"]
        for i = 1, #symbols do
            local symbol = symbols[i]
            
            local symbolName = symbol[optimized and "SN" or "SYMBOL_name"]
            local data = symbol[optimized and "TL" or "TIMELINE"]
            
            self.libraries[symbolName] = { data = data, optimized = data.L ~= nil }
        end
    else
        -- bta format
        for _, item in ipairs(love.filesystem.getDirectoryItems(folder .. "/LIBRARY")) do
            if string.endsWith(item, ".json") then
                local data = json.decode(love.filesystem.read("string", folder .. "/LIBRARY/" .. item))
                self.libraries[string.sub(item, 1, #item - 5)] = { data = data, optimized = data.L ~= nil }
            end
        end
    end
    if #self.spritemaps < 1 then
        error("Couldn't find any spritemaps for folder path '" .. folder .. "'")
        return
    end
    if love.filesystem.getInfo(folder .. "/metadata.json", "file") ~= nil then
        self.framerate = json.decode(love.filesystem.read("string", folder .. "/metadata.json"))[self.timeline.optimized and "FRT" or "framerate"]
    else
        local optimized = self.timeline.data.FRT ~= nil
        local hasFramerate = self.timeline.data.FRT ~= nil or self.timeline.data.framerate ~= nil
        self.framerate = hasFramerate and (optimized and self.timeline.data.FRT or self.timeline.data.framerate) or 24
        print(self.framerate)
    end
    print("Loaded at " .. self.framerate .. " frames per second")
end

---
--- @param symbol string?
---
function AnimateAtlas:play(symbol)
    self.frame = 0
    self.symbol = symbol or ""
    -- does the symbol exist? if not, find the first one that starts with the symbol
    if symbol and not self.libraries[symbol] then
        for key, value in pairs(self.libraries) do
            if string.startsWith(key, symbol) then
                self.symbol = key
                print("Symbol '" .. symbol .. "' not found, using '" .. key .. "' instead.")
                break
            end
        end
    end

    self.playing = true
    self._frameTimer = 0.0
end

---
--- @param symbol string
--- @return boolean
--- 
function AnimateAtlas:isSymbol(symbol)
    if not symbol then
        return false
    end

    if self.libraries[symbol] then
        return true
    end

    return false
end

function AnimateAtlas:stop()
    self.playing = false
    self._frameTimer = 0.0
end

function AnimateAtlas:resume()
    self.playing = true
end

function AnimateAtlas:getTimelineLength(timeline)
    local optimized = timeline.optimized == true or timeline.L ~= nil
    if timeline.data then
        timeline = timeline.data[optimized and "AN" or "ANIMATION"][optimized and "TL" or "TIMELINE"]
    end
    local longest = 0
    local timelineLayers = timeline[optimized and "L" or "LAYERS"]
    for i = #timelineLayers, 1, -1 do
        local layer = timelineLayers[i]
        local layerFrames = layer[optimized and "FR" or "Frames"]

        local keyframe = layerFrames[#layerFrames]
        if keyframe ~= nil then
            local length = keyframe[optimized and "I" or "index"] + keyframe[optimized and "DU" or "duration"]
            if length > longest then
                longest = length
            end
        end
    end
    
    return longest
end

function AnimateAtlas:getLength()
    local optimized = self.timeline.optimized == true or self.timeline.L ~= nil
    return self:getTimelineLength(self.timeline.data[optimized and "AN" or "ANIMATION"][optimized and "TL" or "TIMELINE"])
end

local function matrix2D(matrix)
    return "column", -- OKAY MAKE SURE THIS IS HERE LOL
        matrix[1], -- a
        matrix[2], -- b
        0, 0,
        matrix[3], -- c
        matrix[4], -- d
        0, 0, 0, 0, 1, 0,
        matrix[5], -- tx
        matrix[6], -- ty
        0, 1
end

local function matrix3D(matrix, optimized)
    if optimized then
        return "column",
            matrix[1], -- a
            matrix[2], -- b
            matrix[3], matrix[4],
            matrix[5], -- c
            matrix[6], -- d
            matrix[7], matrix[8], matrix[9], matrix[10], matrix[11], matrix[12],
            matrix[13], -- tx
            matrix[14], -- ty
            matrix[15], matrix[16]
    end

    return "column",
        matrix["m00"], matrix["m01"], matrix["m02"], matrix["m03"],
        matrix["m10"], matrix["m11"], matrix["m12"], matrix["m13"],
        matrix["m20"], matrix["m21"], matrix["m22"], matrix["m23"],
        matrix["m30"], matrix["m31"], matrix["m32"], matrix["m33"]
end

local function renderSymbol(self, symbol, frame, index, matrix, colorTransform, optimized)
    local symbolName = symbol[optimized and "SN" or "SYMBOL_name"]

    -- get the symbol's first frame
    local firstFrame = symbol[optimized and "FF" or "firstFrame"]
    if firstFrame == nil then
        firstFrame = 0
    end

    local frameIndex = firstFrame -- get the frame index we want to possibly render
    frameIndex = frameIndex + (frame - index)

    local symbolType = symbol[optimized and "ST" or "symbolType"]
    if symbolType == "movieclip" or symbolType == "MC" then
        -- movie clips can only display first frame
        frameIndex = 0
    end
    local loopMode = symbol[optimized and "LP" or "loop"]

    local library = self.libraries[symbolName]
    local symbolTimeline = library.data

    local length = self:getTimelineLength(symbolTimeline)

    if loopMode == "loop" or loopMode == "LP" then
        -- wrap around back to 0
        if frameIndex < 0 then
            frameIndex = length - 1
        end
        if frameIndex > length - 1 then
            frameIndex = 0
        end

    elseif loopMode == "playonce" or loopMode == "PO" then
        -- stop at last frame
        if frameIndex < 0 then
            frameIndex = 0
        end
        if frameIndex > length - 1 then
            frameIndex = length - 1
        end

    elseif loopMode == "singleframe" or loopMode == "SF" then
        -- stop at first frame
        frameIndex = firstFrame
    end

    local is3DMatrix = symbol[optimized and "M3D" or "Matrix3D"] ~= nil
    local symbolMatrix = love.math.newTransform()

    local symbolMatrixRaw
    if is3DMatrix then
        symbolMatrixRaw = symbol[optimized and "M3D" or "Matrix3D"]
    else
        symbolMatrixRaw = symbol[optimized and "MX" or "Matrix"]
    end

    symbolMatrix:setMatrix((is3DMatrix and matrix3D or matrix2D)(symbolMatrixRaw, optimized))

    -- TODO: is this shit even working correctly??
    local symbolColor = symbol[optimized and "C" or "color"]
    if symbolColor and not colorTransform then
        colorTransform = symbolColor
    end
    if colorTransform and symbolColor then
        for key, value in pairs(colorTransform) do
            if type(value) == "number" then
                if string.endsWith(key, "Offset") then
                    -- is offset
                    colorTransform[key] = value + symbolColor[key]
                else
                    -- assume multiplier
                    colorTransform[key] = value * symbolColor[key]
                end
            end
        end
    end

    self:drawTimeline(symbolTimeline, frameIndex, matrix:clone():apply(symbolMatrix), colorTransform)
end

local function renderSprite(self, sprite, spritemap, spriteMatrix, matrix, colorTransform)
    -- store thecolor transform mode somewhere
    local colorTransformMode = colorTransform and colorTransform.mode or nil
    if not colorTransformMode then
        colorTransformMode = "none"
    end
    --- @type "brightness"|"tint"|"alpha"|"advanced"|"none"
    colorTransformMode = colorTransformMode:lower()

    local texture = spritemap.texture --- @type love.Image
    local quad = love.graphics.newQuad(sprite.x, sprite.y, sprite.w, sprite.h, texture:getWidth(), texture:getHeight())

    local drawMatrix = matrix * spriteMatrix
    if sprite.rotated then
        drawMatrix:translate(0,sprite.w)
        drawMatrix:rotate(-math.pi/2)
    end
    local lastShader = love.graphics.getShader()
    love.graphics.setShader(self._colorTransformShader)

    self:setColorOffset(0, 0, 0, 0)
    self:setColorMultiplier(1, 1, 1, 1)

    if(type(colorTransforms[colorTransformMode]) == "function") then
        colorTransforms[colorTransformMode](self, colorTransform)
    end
    love.graphics.draw(texture, quad, drawMatrix)
    love.graphics.setShader(lastShader)
end

local function renderAtlasSprite(self, atlasSprite, matrix, colorTransform, optimized)
    local name = atlasSprite[optimized and "N" or "name"]
    local is3DMatrix = atlasSprite[optimized and "M3D" or "Matrix3D"] ~= nil

    local spriteMatrixRaw = nil
    if is3DMatrix then
        spriteMatrixRaw = atlasSprite[optimized and "M3D" or "Matrix3D"]
    else
        spriteMatrixRaw = atlasSprite[optimized and "MX" or "Matrix"]
    end
    local spriteMatrix = love.math.newTransform()
    spriteMatrix:setMatrix((is3DMatrix and matrix3D or matrix2D)(spriteMatrixRaw, optimized))

    local spritemaps = self.spritemaps
    for l = 1, #spritemaps do
        local spritemap = spritemaps[l]
        local sprites = spritemap.data.ATLAS.SPRITES
        for z = 1, #sprites do
            local sprite = sprites[z].SPRITE

            if sprite.name == name then
                renderSprite(self, sprite, spritemap, spriteMatrix, matrix, colorTransform)
                break
            end
        end
    end
end

local function renderKeyFrame(self, keyframe, frame, matrix, colorTransform, optimized)
    local index = keyframe[optimized and "I" or "index"]
    local duration = keyframe[optimized and "DU" or "duration"]

    if not (frame >= index and frame < index + duration) then
        return false
    end
    local elements = keyframe[optimized and "E" or "elements"]

    for k = 1, #elements do
        local element = elements[k]

        local symbol = element[optimized and "SI" or "SYMBOL_Instance"]
        local atlasSprite = element[optimized and "ASI" or "ATLAS_SPRITE_instance"]

        if symbol then
            self._curSymbol = { data = symbol, index = index }
            renderSymbol(self, symbol, frame, index, matrix, colorTransform, optimized)
        elseif atlasSprite then
            renderAtlasSprite(self, atlasSprite, matrix, colorTransform, optimized)
        end
    end

    return true
end

---
--- @param  timeline  table
--- @param  frame     integer
--- @param  matrix    love.Transform
---
function AnimateAtlas:drawTimeline(timeline, frame, matrix, colorTransform)
    local optimized = timeline.L ~= nil
    local timelineLayers = timeline[optimized and "L" or "LAYERS"]

    for i = #timelineLayers, 1, -1 do
        local layer = timelineLayers[i]
        local keyframes = layer[optimized and "FR" or "Frames"]

        for j = 1, #keyframes do
            if renderKeyFrame(self, keyframes[j], frame, matrix, colorTransform, optimized) then
                break
            end
        end
    end
end

function AnimateAtlas:getSymbolTimeline(symbol)
    if not symbol then
        symbol = ""
    end
    local timeline = self.libraries[self.symbol]
    if not timeline then
        timeline = self.timeline
    else
        timeline = timeline.data
    end
    return timeline
end

function AnimateAtlas:update(dt)
    if self.framerate <= 0.0 or not self.playing then
        return
    end
    self._frameTimer = self._frameTimer + dt
    if self._frameTimer >= 1.0 / self.framerate then
        self.frame = self.frame + 1

        local length = self:getTimelineLength(self:getSymbolTimeline(self.symbol))
        if self.frame > length - 1 then
            if self._curSymbol then
                if self._callback then
                    self._callback(self.objectReference, self)
                end
                local optimized = self._curSymbol.data.ST ~= nil
                local symbolName = self._curSymbol.data[optimized and "SN" or "SYMBOL_name"]

                local firstFrame = self._curSymbol.data[optimized and "FF" or "firstFrame"]
                if firstFrame == nil then
                    firstFrame = 0
                end
                local frameIndex = firstFrame -- get the frame index we want to possibly render
                frameIndex = frameIndex + (self.frame - self._curSymbol.index)

                local symbolType = self._curSymbol.data[optimized and "ST" or "symbolType"]
                if symbolType == "movieclip" or symbolType == "MC" then
                    -- movie clips can only display first frame
                    frameIndex = 0
                end
                local loopMode = self._curSymbol.data[optimized and "LP" or "loop"]

                local library = self.libraries[symbolName]
                local symbolTimeline = library.data

                local length = self:getTimelineLength(symbolTimeline)
                
                if loopMode == "loop" or loopMode == "LP" then
                    -- wrap around back to 0
                    if frameIndex < 0 then
                        frameIndex = length - 1
                    end
                    if frameIndex > length - 1 then
                        frameIndex = 0
                    end

                elseif loopMode == "playonce" or loopMode == "PO" then
                    -- stop at last frame
                    if frameIndex < 0 then
                        frameIndex = 0
                    end
                    if frameIndex > length - 1 then
                        frameIndex = length - 1
                    end

                elseif loopMode == "singleframe" or loopMode == "SF" then
                    -- stop at first frame
                    frameIndex = firstFrame
                end
                self.frame = frameIndex
            else
                self.frame = length - 1
            end
        end
        self._frameTimer = 0.0
    end
end

function AnimateAtlas:draw(x, y, r, sx, sy, ox, oy)
    r = r or 0.0 -- rotation (radians)
    sx = sx or 1.0 -- scale x
    sy = sy or 1.0 -- scale y
    ox = ox or 0.0 -- origin x
    oy = oy or 0.0 -- origin y
    
    local identity = love.math.newTransform()
    identity:translate(x, y)
    
    identity:translate(ox, oy)
    identity:rotate(r)
    identity:scale(sx, sy)
    identity:translate(-ox, -oy)

    local timeline = self:getSymbolTimeline(self.symbol)
    if timeline.data then
        timeline = timeline.data[timeline.optimized and "AN" or "ANIMATION"][timeline.optimized and "TL" or "TIMELINE"]
    end
    self._curSymbol = nil
    self:drawTimeline(timeline, self.frame, identity, nil)
end

return AnimateAtlas