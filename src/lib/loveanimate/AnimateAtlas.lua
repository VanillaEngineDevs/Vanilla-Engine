---@diagnostic disable: missing-fields
--[[ local Bit = require("loveanimate.libs.Bit")
local Classic = require("loveanimate.libs.Classic") ]]
local baseDirectory = (...):match("(.-)[^%.]+$"):gsub("AnimateAtlas", "")
local Bit = require(baseDirectory .. "libs.Bit")
local Classic = require(baseDirectory .. "libs.Classic")

AnimateSymbolInstance = Object:extend()
function AnimateSymbolInstance:new(lib, parent)
    self.timeline = lib.data
    self.optimized = lib.optimized
    self.parent = parent
    self.localFrame = 0
end

function AnimateSymbolInstance:update(dt)
end

function AnimateSymbolInstance:setFrame(frame)
    self.localFrame = frame
end

local function intToRGB(int)
	return
		Bit.band(Bit.rshift(int, 16), 0xFF) / 255,
		Bit.band(Bit.rshift(int, 8), 0xFF) / 255,
		Bit.band(int, 0xFF) / 255,
		Bit.band(Bit.rshift(int, 24), 0xFF) / 255
end

local function resolveSymbolTimeline(lib)
    if not lib then return nil end

    if lib.S then
        return lib.S
    end

    if lib.L or lib.LAYERS then
        return lib
    end

    return nil
end

local function getSymbolFrameCount(symbol)
    symbol = resolveSymbolTimeline(symbol)
    if not symbol then return 0 end

    local optimized = symbol.L ~= nil
    local layers = symbol[optimized and "L" or "LAYERS"]
    if not layers then return 0 end

    local longest = 0

    for i = #layers, 1, -1 do
        local frames = layers[i][optimized and "FR" or "Frames"]
        local kf = frames and frames[#frames]

        if kf then
            local index = kf[optimized and "I" or "index"] or 0
            local duration = kf[optimized and "DU" or "duration"] or 1

            longest = math.max(longest, index + duration)
        end
    end

    return longest
end

---
--- @class love.animate.AnimateAtlas
---
local AnimateAtlas = Classic:extend()

local json = require(baseDirectory .. "libs.Json")
require(baseDirectory .. "libs.StringUtil")

function AnimateAtlas:constructor(object)
    self.frame = 0
    self.playing = false

    --- @protected
    self._curSymbol = nil
    self._stencilDepth = 0

    --- @protected
    self._frameTimer = 0
    self.currentFrame = 0
    self.endFrame = 0
    self.startFrame = 0

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
    self._maskShader = love.graphics.newShader([[
		vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
			float alpha = Texel(texture, texture_coords).a;
			if (alpha == 0.0) { discard; }
			return vec4(alpha);
        }
    ]])
    self.shader = nil
    self:setColorOffset(0, 0, 0, 0)
    self:setColorMultiplier(1, 1, 1, 1)

    self._callback = nil
    self.objectReference = object

    self.animations = {}
    self.curAnim = nil
    self.frameCount = 0

    self.x = 0
    self.y = 0
    self.rotation = 0
    self.angle = 0
    self.scale = {x = 1, y = 1}
    self.origin = {x = 0, y = 0}
    self.offset = {x = 0, y = 0}
    self.scroll = {x = 1, y = 1}

    self.width = 0
    self.height = 0

    self.frameElements = {}
    self.visible = true

    self.flipX = false
    self.flipY = false

    self.animPaused = false

    self.zIndex = 0

    self.alpha = 1

    self.atlasSettings = self:getAtlasSettings() or {}
    self._symbolInstances = {}
    self._symbolisntanceCache = {}

    self.onFrameChange = signal.new()
    self.onAnimationFinished = signal.new()
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
            (colorTransform["AlphaOffset"] or 1) * self.alpha
        )
        self:setColorMultiplier(
            colorTransform["RedMultiplier"],
            colorTransform["greenMultiplier"],
            colorTransform["blueMultiplier"],
            (colorTransform["alphaMultiplier"] or 1) * self.alpha
        )
    end
}

--- Load the atlas from folder
--- @param folder string
---
function AnimateAtlas:load(folder, listAllSymbols)
    self.atlasSettings = self:getAtlasSettings() or {}
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
            symbol.length = getSymbolFrameCount(symbol)
            
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
    end

    -- lists all animation names if true
    if listAllSymbols then
        print("Animations in atlas '" .. folder .. "':")

        for name, lib in pairs(self.libraries) do
            local data = lib.data
            local isOptimized = lib.optimized

            local layers =
                isOptimized and data.L
                or data.layers

            if layers and #layers > 0 then
                print(" - " .. name)
            end
        end
    end
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

function AnimateAtlas:getTimelineLength(timelineWrapper)
    local timeline = timelineWrapper.data or timelineWrapper
    local optimized = timelineWrapper.optimized == true or timeline.L ~= nil

    if timeline.AN or timeline.ANIMATION then
        timeline = timeline[optimized and "AN" or "ANIMATION"][optimized and "TL" or "TIMELINE"]
    end

    local layers = timeline[optimized and "L" or "LAYERS"]
    if not layers then return 0 end

    local longest = 0

    for i = #layers, 1, -1 do
        local frames = layers[i][optimized and "FR" or "Frames"]
        local kf = frames and frames[#frames]

        if kf then
            local length =
                (kf[optimized and "I" or "index"] or 0) +
                (kf[optimized and "DU" or "duration"] or 0)

            longest = math.max(longest, length)
        end
    end

    return longest
end

function AnimateAtlas:addAnimByPrefix(name, prefix, framerate, loop)
    framerate = framerate or 30
    loop = loop == nil and true or loop

    local anim = {
        name = name,
        prefix = prefix,
        framerate = framerate,
        loop = loop,
        frames = {}
    }

    local timeline = self.timeline
    local optimized = timeline.optimized == true or timeline.data.L ~= nil
    local timelineData = timeline.data[optimized and "AN" or "ANIMATION"][optimized and "TL" or "TIMELINE"]
    local layers = timelineData[optimized and "L" or "LAYERS"]

    for i = 1, #layers do
        local layer = layers[i]
        local keyframes = layer[optimized and "FR" or "Frames"]

        for j = 1, #keyframes do
            local keyframe = keyframes[j]
            local nameInFrame = keyframe[optimized and "N" or "name"] or ""
            if nameInFrame == prefix then
                local index = keyframe[optimized and "I" or "index"]
                local duration = keyframe[optimized and "DU" or "duration"] or 1
                for f = index, index + duration - 1 do
                    table.insert(anim.frames, f)
                end
            end
        end
    end

    if #anim.frames == 0 then
        anim.frames = {0}
    end

    table.insert(self.animations, anim)
end

---
--- @param animName string?
--- @param loop boolean?
---
function AnimateAtlas:play(animName, forced, loop, frameStart)
    if not animName or animName == "" or not self:hasAnimation(animName) then
        self.curAnim = {
            name = animName or "__raw__",
            framerate = self.framerate,
            loop = (loop == nil) and true or loop,
            raw = true,
            startFrame = frameStart or 0,
            endFrame = self:getLength() - 1
        }

        self.frame = self.curAnim.startFrame
        self.playing = true
        self.animFinished = false
        self.animPaused = false
        self._activeSymbol = nil
        return
    end

    if self.curAnim
        and self.curAnim.name == animName
        and self.playing
        and not forced
    then
        if self.animPaused then
            self.animPaused = false
            self.playing = true
        end
        return
    end

    for _, anim in ipairs(self.animations) do
        if anim.name == animName then
            self.curAnim = anim
            self.frame = 1
            self.playing = true
            self.looping = loop ~= nil and loop or anim.loop
            self.animFinished = false
            self.animPaused = false
            self.paused = false

            if anim.type == "symbol" then
                self._activeSymbol =
                    self._symbolisntanceCache[anim.name]
                        or AnimateSymbolInstance({data = anim.timeline, optimized = anim.optimized}, self)

                self._activeSymbol:setFrame(anim.frames[1])
            else
                self._activeSymbol = nil
            end

            break
        end
    end

    self.width, self.height = self:getBoundDimensions()
end

function AnimateAtlas:playSymbol(animName, forced, loop, frameStart)
    if not animName or animName == "" or not self:hasAnimation(animName) then
        self.curAnim = {
            name = "__raw__",
            framerate = self.framerate,
            loop = (loop == nil) and true or loop,
            raw = true,
            startFrame = frameStart or 0,
            endFrame = self:getLength() - 1
        }

        self.frame = self.curAnim.startFrame
        self.playing = true
        self.animFinished = false
        self.animPaused = false
        return
    end

    if self.curAnim
        and self.curAnim.name == animName
        and self.playing
        and not forced
    then
        if self.animPaused then
            self.animPaused = false
            self.playing = true
        end
        return
    end

    for _, anim in ipairs(self.animations) do
        if anim.name == animName then
            self.curAnim = anim
            self.frame = 1
            self.playing = true
            self.looping = loop ~= nil and loop or anim.loop
            self.animFinished = false
            self.animPaused = false
            self.paused = false

            if anim.type == "symbol" then
                self._activeSymbol =
                    self._symbolisntanceCache[anim.name]
                        or AnimateSymbolInstance({data = anim.timeline, optimized = anim.optimized}, self)

                self._activeSymbol:setFrame(anim.frames[1])
            else
                self._activeSymbol = nil
            end


            break
        end
    end

    self.width, self.height = self:getBoundDimensions()
end

function AnimateAtlas:getLength()
    local optimized = self.timeline.optimized == true or self.timeline.L ~= nil
    return self:getTimelineLength(self.timeline.data[optimized and "AN" or "ANIMATION"][optimized and "TL" or "TIMELINE"])
end

function AnimateAtlas:getDefaultSymbol()
    local optimized = self.timeline.optimized == true or self.timeline.data.L ~= nil
    local timeline = self.timeline.data[optimized and "AN" or "ANIMATION"][optimized and "TL" or "TIMELINE"]
    
    local timelineName = timeline[optimized and "N" or "name"]
    if timelineName and timelineName ~= "" then
        return timelineName
    end
    
    for symbolName, _ in pairs(self.libraries) do
        return symbolName
    end
    
    return ""
end

function AnimateAtlas:getFrameLabelList()
    local foundLabels = {}
    local mainTimeline = self.timeline.data
    local optimized = mainTimeline.L ~= nil
    
    if mainTimeline.AN or mainTimeline.ANIMATION then
        mainTimeline = mainTimeline[optimized and "AN" or "ANIMATION"] and mainTimeline[optimized and "AN" or "ANIMATION"][optimized and "TL" or "TIMELINE"]
        if not mainTimeline then
            return foundLabels
        end
    end
    
    local layers = mainTimeline[optimized and "L" or "LAYERS"]
    if not layers then
        return foundLabels
    end
    
    for i = 1, #layers do
        local layer = layers[i]
        local frames = layer[optimized and "FR" or "Frames"]
        
        if frames then
            for j = 1, #frames do
                local frame = frames[j]
                local frameName = frame[optimized and "N" or "name"] or ""
                if frameName ~= "" and not table.contains(foundLabels, frameName) then
                    table.insert(foundLabels, frameName)
                end
            end
        end
    end
    
    return foundLabels
end

---
--- Gets a frame label by its name.
--- @param name string
--- @return table|nil
---
function AnimateAtlas:getFrameLabel(name)
    local mainTimeline = self.timeline.data
    local optimized = mainTimeline.L ~= nil
    
    if mainTimeline.AN or mainTimeline.ANIMATION then
        mainTimeline = mainTimeline[optimized and "AN" or "ANIMATION"][optimized and "TL" or "TIMELINE"]
    end
    
    local layers = mainTimeline[optimized and "L" or "LAYERS"]
    if not layers then
        return nil
    end
    
    for i = 1, #layers do
        local layer = layers[i]
        local frames = layer[optimized and "FR" or "Frames"]
        
        if frames then
            for j = 1, #frames do
                local frame = frames[j]
                if frame[optimized and "N" or "name"] == name then
                    return frame
                end
            end
        end
    end
    
    return nil
end

function AnimateAtlas:addFrameElement(filterFn, element)
    table.insert(self.frameElements, {
        filter = filterFn,
        element = element
    })
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

function AnimateAtlas:getAtlasSettings()
    return {}
end

function AnimateAtlas:_createSymbolInstance(symbolName)
    self.atlasSettings = self:getAtlasSettings() or {}
    local lib = self.libraries[symbolName]
    if not lib then return nil end

    local timeline = lib.data
    local optimized = lib.optimized == true or timeline.L ~= nil
    local rawLayers = timeline[optimized and "L" or "LAYERS"]

    local layers = {}
    for i = 1, #rawLayers do
        local raw = rawLayers[i]
        layers[i] = {
            name = raw[optimized and "LN" or "Layer_name"],
            raw = raw,
            visible = true
        }
    end

    local symbol = {
        name = symbolName,
        timeline = timeline,
        layers = layers,
        optimized = optimized,
        currentFrame = 0
    }

    if self.atlasSettings.onSymbolCreate then
        self.atlasSettings.onSymbolCreate(symbol)
    end

    self._symbolInstances[symbolName] = symbol
    return symbol
end

function AnimateAtlas:_getSymbolInstance(symbolName)
    return self._symbolInstances[symbolName]
        or self:_createSymbolInstance(symbolName)
end

local function renderSymbol(self, symbolData, frame, index, matrix, colorTransform, optimized, stencilMode)
    local symbolName = symbolData[optimized and "SN" or "SYMBOL_name"]
    local symbol = self:_getSymbolInstance(symbolName)
    if not symbol then return end

    local firstFrame = symbolData[optimized and "FF" or "firstFrame"] or 0
    local frameIndex = firstFrame + (frame - index)

    local loopMode = symbolData[optimized and "LP" or "loop"]
    local length = self:getTimelineLength(symbol.timeline)

    if loopMode == "loop" or loopMode == "LP" then
        frameIndex = frameIndex % length
    elseif loopMode == "playonce" or loopMode == "PO" then
        frameIndex = math.min(frameIndex, length - 1)
    elseif loopMode == "singleframe" or loopMode == "SF" then
        frameIndex = firstFrame
    end

    local is3DMatrix = symbolData[optimized and "M3D" or "Matrix3D"] ~= nil
    local symbolMatrix = love.math.newTransform()
    local symbolMatrixRaw
    if is3DMatrix then
        symbolMatrixRaw = symbolData[optimized and "M3D" or "Matrix3D"]
    else
        symbolMatrixRaw = symbolData[optimized and "MX" or "Matrix"]
    end

    symbolMatrix:setMatrix((is3DMatrix and matrix3D or matrix2D)(symbolMatrixRaw, optimized))

    self._curSymbol = symbol
    self:drawTimeline(symbol.timeline, frameIndex, matrix:clone():apply(symbolMatrix), colorTransform)
end

local function renderSprite(self, sprite, spritemap, spriteMatrix, matrix, colorTransform, stencilMode)
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
    love.graphics.setShader(self.shader)
    if not stencilMode then
        if not self.shader then
            love.graphics.setShader(self._colorTransformShader)
        end

        self:setColorOffset(0, 0, 0, 0)
        self:setColorMultiplier(1, 1, 1, self.alpha)

        if type(colorTransforms[colorTransformMode]) == "function" then
            colorTransforms[colorTransformMode](self, colorTransform)
        end
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
    if spriteMatrixRaw then
        spriteMatrix:setMatrix((is3DMatrix and matrix3D or matrix2D)(spriteMatrixRaw, optimized))
    else
        spriteMatrix:setMatrix("column", 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
    end

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
    frame = frame or 0
    if not (frame >= index and frame < index + duration) then
        return false
    end

    if not matrix then
        matrix = love.math.newTransform()
    end

    local elements = keyframe[optimized and "E" or "elements"]
    if not elements then return true end

    for i = 1, #elements do
        local element = elements[i]
        local symbol = element[optimized and "SI" or "SYMBOL_Instance"]
        local atlasSprite = element[optimized and "ASI" or "ATLAS_SPRITE_instance"]

        if symbol then
            renderSymbol(self, symbol, frame, index, matrix, colorTransform, optimized)
        elseif atlasSprite then
            renderAtlasSprite(self, atlasSprite, matrix, colorTransform, optimized)
        elseif element.isAnimate then
            love.graphics.push("transform")
            love.graphics.applyTransform(matrix)
            element:draw(self._camera)
            love.graphics.pop()
        elseif element.draw then
            love.graphics.push("transform")
            local newMat = matrix:clone()
            newMat:translate(element.x or 0, element.y or 0)
            love.graphics.applyTransform(newMat)
            element.shader = self.shader
            element:draw()
            love.graphics.pop()
        end
    end

    return true
end

function AnimateAtlas:_pushMask(maskLayer, frame, matrix, optimized)
    local keyframes = maskLayer[optimized and "FR" or "Frames"]

    self._stencilDepth = self._stencilDepth + 1
    local depth = self._stencilDepth

    love.graphics.stencil(function()
        local lastShader = love.graphics.getShader()
        love.graphics.setShader(self._maskShader)

        love.graphics.push("transform")
        for j = 1, #keyframes do
            if renderKeyFrame(
                self,
                keyframes[j],
                frame,
                matrix,
                nil,
                optimized,
                true
            ) then
                break
            end
        end
        
        love.graphics.pop()
        love.graphics.setShader(lastShader)
    end, "replace", depth, true)

    love.graphics.setStencilTest("equal", depth)
end

function AnimateAtlas:_popMask()
    self._stencilDepth = self._stencilDepth - 1

    if self._stencilDepth > 0 then
        love.graphics.setStencilTest("equal", self._stencilDepth)
    else
        love.graphics.setStencilTest()
    end
end


---
--- @param  timeline  table
--- @param  frame     integer
--- @param  matrix    love.Transform
---
function AnimateAtlas:drawTimeline(timeline, frame, matrix, colorTransform)
    local optimized = timeline.L ~= nil
    local rawLayers = timeline[optimized and "L" or "LAYERS"]

    local symbol = self._curSymbol
    local visibleLayers = {}

    if symbol then
        for _, l in ipairs(symbol.layers) do
            visibleLayers[l.name] = l.visible
        end
    end

    for i = #rawLayers, 1, -1 do
        local layer = rawLayers[i]
        local layerName = layer[optimized and "LN" or "Layer_name"]
        local layerType = layer[optimized and "LT" or "Layer_type"]
		local clippedBy = layer[optimized and "CB" or "Clipped_by"] or layer[optimized and "Clpb" or "Clipped_by"]

		if layerType ~= nil then
			goto continue
		end

		if clippedBy ~= nil then
            local maskLayer = nil
            for j = 1, #rawLayers do
                local potentialMaskLayer = rawLayers[j]
                local potentialMaskLayerName = potentialMaskLayer[optimized and "LN" or "Layer_name"]
                if potentialMaskLayerName == clippedBy then
                    maskLayer = potentialMaskLayer
                    break
                end
            end
            if maskLayer then
                self:_pushMask(maskLayer, frame, matrix, optimized)
            end
        end

        if visibleLayers[layerName] == false then
            goto continue
        end

        local keyframes = layer[optimized and "FR" or "Frames"]
        for j = 1, #keyframes do
            if renderKeyFrame(self, keyframes[j], frame, matrix, colorTransform, optimized) then
            end
        end

        if clippedBy ~= nil then
            self:_popMask()
        end

        ::continue::
    end
end

function AnimateAtlas:getSymbolTimeline(symbol)
    if not symbol then
        symbol = ""
    end
    local timeline = self.libraries[symbol]
    if not timeline then
        timeline = self.timeline
    else
        timeline = timeline.data
    end
    return timeline
end

function AnimateAtlas:getSymbolStartingFrame(symbol)
    if not symbol then
        symbol = ""
    end
    local timeline = self.libraries[symbol]
    if not timeline then
        return 0
    end

    local optimized = timeline.optimized == true or timeline.data.L ~= nil
    local symbolTimeline = timeline.data

    local length = self:getTimelineLength(symbolTimeline)
    return length
end

function AnimateAtlas:getSymbolEndingFrame(symbol)
    if not symbol then
        symbol = ""
    end
    local timeline = self.libraries[symbol]
    if not timeline then
        return 0
    end

    local optimized = timeline.optimized == true or timeline.data.L ~= nil
    local symbolTimeline = timeline.data

    local length = self:getTimelineLength(symbolTimeline)
    return length - 1
end

function AnimateAtlas:getSymbolLength(symbol)
    local timeline = self.libraries[symbol]
    if not timeline then return 0 end
    return self:getTimelineLength(timeline.data)
end

function AnimateAtlas:update(dt, emitSignals)
    if emitSignals == nil then emitSignals = true end
    if self.framerate <= 0 or not self.playing or not self.curAnim then return end

    self._frameTimer = self._frameTimer + dt
    local interval = 1 / self.curAnim.framerate

    while self._frameTimer >= interval do
        self._frameTimer = self._frameTimer - interval

        if self.curAnim.raw then
            if not self.animPaused then self.frame = self.frame + 1 end
            self.frameCount = self.curAnim.endFrame - self.curAnim.startFrame + 1

            if self.frame > self.curAnim.endFrame then
                if self.curAnim.loop then
                    self.frame = self.curAnim.startFrame
                else
                    self.frame = self.curAnim.endFrame
                    self.playing = false
                    self.animFinished = true
                end
            end

            if emitSignals then
                self.onFrameChange:emit("__raw__", self.frame, self.frame)
            end
        else
            if self.curAnim.name == "cutscene" then
                print("Cutscene frame: " .. tostring(self.frame))
                print("Total frames: " .. tostring(#self.curAnim.frames))
            end
            if not self.animPaused then self.frame = self.frame + 1 end

            if self.frame > #self.curAnim.frames then
                if self.looping then
                    self.frame = 1
                else
                    self.playing = false
                    self.animFinished = true
                    self.frame = #self.curAnim.frames
                end

                if self.animFinished and emitSignals then
                    self.onAnimationFinished:emit(self.curAnim.name)
                end
            end

            local logicalFrame = self.curAnim.frames[self.frame]

            if self.curAnim.type == "symbol" and self._activeSymbol then
                self._activeSymbol:setFrame(logicalFrame)
            end

            if emitSignals then
                self.onFrameChange:emit(
                    self.curAnim.name,
                    self.frame,
                    logicalFrame
                )
            end
        end
    end
end

function AnimateAtlas:draw(camera, x, y, r, sx, sy, ox, oy)
    if not self.visible then
        return
    end
    camera = camera or {x = 0, y = 0, shakeX = 0, shakeY = 0, centered = false}
    self._camera = camera
    local cx = camera.x + camera.shakeX
    local cy = camera.y + camera.shakeY
    if camera.centered then
        cx = cx - (1280 / 2)
        cy = cy - (720 / 2)
    end
    x = x or self.x
    y = y or self.y
    r = r or self.rotation
    sx = sx or self.scale.x
    sy = sy or self.scale.y
    ox = ox or self.origin.x
    oy = oy or self.origin.y

    if self.flipX then
        sx = -sx
    end
    if self.flipY then
        sy = -sy
    end

    x = x + ox - self.offset.x - (cx * self.scroll.x)
    y = y + oy - self.offset.y - (cy * self.scroll.y)

    local w, h = self.width, self.height

    local identity = love.math.newTransform()
    identity:translate(x, y)
    identity:translate(ox, oy)
    identity:rotate(r)
    identity:scale(sx, sy)
    identity:translate(-ox, -oy)
    identity:translate(w/2, h/2)
    
    if self.angle ~= 0 then
        local centerX, centerY = self:getMidpoint()
        identity:translate(centerX - x, centerY - y)
        identity:rotate(self.angle)
        identity:translate(-(centerX - x), -(centerY - y))

        -- evil bullshit
        local cosAngle = math.cos(math.rad(self.angle))
        local sinAngle = math.sin(math.rad(self.angle))
        local newW = math.abs(w * cosAngle) + math.abs(h * sinAngle)
        local newH = math.abs(h * cosAngle) + math.abs(w * sinAngle)
        identity:translate((w - newW) / 2, (h - newH) / 2)
    end

    local timeline
    if self.curAnim then
        local frameIndex
        if self.curAnim.raw then
            frameIndex = self.frame
        else
            frameIndex = self.curAnim.frames[math.min(self.frame, #self.curAnim.frames)]
        end
        if frameIndex == nil then
            print("frameindex is nil???????")
            frameIndex = 0
        end

        if self.curAnim.type == "symbol" then
            timeline = self.curAnim.timeline
            -- Get or create the symbol instance to apply atlasSettings
            if self.curAnim.symbolName then
                self._curSymbol = self:_getSymbolInstance(self.curAnim.symbolName)
            else
                self._curSymbol = nil
            end
        else
            timeline = self:getSymbolTimeline()
            if timeline.data then
                timeline = timeline.data[timeline.optimized and "AN" or "ANIMATION"][timeline.optimized and "TL" or "TIMELINE"]
            end
            self._curSymbol = nil
        end
        
        self:drawTimeline(timeline, frameIndex, identity, nil)
    end
end

-- #region BOUNDING BOXES

-- calctl, calckf, calcs, calcas

function AnimateAtlas:_getTopLeft(self, timeline, frame, matrix, bounds)
    local optimized = timeline.L ~= nil
    local timelineLayers = timeline[optimized and "L" or "LAYERS"]
    local foundSprites = false

    for i = #timelineLayers, 1, -1 do
        local layer = timelineLayers[i]
		if layer[optimized and "LT" or "Layer_type"] then
			goto continue
		end

		local keyframes = layer[optimized and "FR" or "Frames"]

		local activeKeyframe = nil
		for j = 1, #keyframes do
			local kf = keyframes[j]
			local index = kf[optimized and "I" or "index"]
			local duration = kf[optimized and "DU" or "duration"]

			if frame >= index and frame < index + duration then
				activeKeyframe = kf
				break
			end
		end

		if activeKeyframe then
			if self:_getKeyframe(self, activeKeyframe, frame, matrix, optimized, bounds) then
				foundSprites = true
			end
		end

		::continue::
    end

    return foundSprites
end

function AnimateAtlas:_getKeyframe(self, keyframe, frame, matrix, optimized, bounds)
	local elements = keyframe[optimized and "E" or "elements"]
	local foundSprites = false
	local index = keyframe[optimized and "I" or "index"]

	for k = 1, #elements do
		local element = elements[k]
		local symbol = element[optimized and "SI" or "SYMBOL_Instance"]
		local atlas = element[optimized and "ASI" or "ATLAS_SPRITE_Instance"]

		if symbol then
			if self:_calcS(self, symbol, frame, index, matrix, optimized, bounds) then
				foundSprites = true
			end
		elseif atlas then
			if self:_calcAS(self, atlas, matrix, optimized, bounds) then
				foundSprites = true
			end
		end
	end

	return foundSprites
end

function AnimateAtlas:_calcS(self, symbol, frame, index, matrix, optimized, bounds)
	local symbolName = symbol[optimized and "SN" or "SYMBOL_name"]
	local firstFrame = symbol[optimized and "FF" or "firstFrame"] or 0

	local frameIndex = firstFrame + (frame - index)
	local symbolType = symbol[optimized and "ST" or "symbolType"]
	if symbolType == "movieclip" or symbolType == "MC" then
		frameIndex = 0
	end

	local loopMode = symbol[optimized and "LP" or "loop"]

	local symbolTimeline = self.libraries[symbolName].data
	local length = self:getTimelineLength(symbolTimeline)

	if loopMode == "loop" or loopMode == "LP" then
		if frameIndex < 0 then
			frameIndex = length - 1
		elseif frameIndex >= length then
			frameIndex = frameIndex % length
		end
	elseif loopMode == "playonce" or loopMode == "PO" then
		frameIndex = math.max(0, math.min(frameIndex, length - 1))
	elseif loopMode == "singleframe" or loopMode == "SF" then
		frameIndex = firstFrame
	end

	local is3DMatrix = symbol[optimized and "M3D" or "Matrix3D"] ~= nil
	local symbolMatrix = love.math.newTransform()
	local symbolMatrixRaw = is3DMatrix and symbol[optimized and "M3D" or "Matrix3D"] or symbol[optimized and "MX" or "Matrix"]
	
	if symbolMatrixRaw then
		symbolMatrix:setMatrix((is3DMatrix and matrix3D or matrix2D)(symbolMatrixRaw, optimized))
	else
		symbolMatrix:setMatrix("column", 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
	end

	local combinedMatrix = matrix:clone():apply(symbolMatrix)
	return self:_getTopLeft(self, symbolTimeline, frameIndex, combinedMatrix, bounds)
end

function AnimateAtlas:_calcAS(self, atlasSprite, matrix, optimized, bounds)
	local name = atlasSprite[optimized and "N" or "name"]

	local sprite = nil
	local spritemaps = self.spritemaps
	for l = 1, #spritemaps do
		local spritemap = spritemaps[l]
		local sprites = spritemap.data.ATLAS.SPRITES
		for z = 1, #sprites do
			local s = sprites[z].SPRITE
			if s.name == name then
				sprite = s
				goto found_sprite
			end
		end
	end

	::found_sprite::
	if not sprite then return false end

	local is3DMatrix = atlasSprite[optimized and "M3D" or "Matrix3D"] ~= nil
	local spriteMatrixRaw = is3DMatrix and atlasSprite[optimized and "M3D" or "Matrix3D"] or atlasSprite[optimized and "MX" or "Matrix"]
	local spriteMatrix = love.math.newTransform()
	
	if spriteMatrixRaw then
		spriteMatrix:setMatrix((is3DMatrix and matrix3D or matrix2D)(spriteMatrixRaw, optimized))
	else
		spriteMatrix:setMatrix("column", 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
	end

	local drawMatrix = matrix:clone():apply(spriteMatrix)
	local w, h = sprite.w, sprite.h

	if sprite.rotated then
		drawMatrix:translate(0, w)
		drawMatrix:rotate(-math.pi/2)
		w, h = h, w
	end
	local x1, y1 = drawMatrix:transformPoint(0, 0)
	local x2, y2 = drawMatrix:transformPoint(w, 0)
	local x3, y3 = drawMatrix:transformPoint(w, h)
	local x4, y4 = drawMatrix:transformPoint(0, h)

	local minX = math.min(x1, x2, x3, x4)
	local minY = math.min(y1, y2, y3, y4)
	local maxX = math.max(x1, x2, x3, x4)
	local maxY = math.max(y1, y2, y3, y4)

	bounds.minX = math.min(bounds.minX, minX)
	bounds.minY = math.min(bounds.minY, minY)
	bounds.maxX = math.max(bounds.maxX, maxX)
	bounds.maxY = math.max(bounds.maxY, maxY)

	return true
end

function AnimateAtlas:addElementToFrames(keyword, element) --ogurifap.gif
    local frames = self:getFramesWithKeyword(keyword)
    local optimized = self.timeline.optimized or self.timeline.data.L ~= nil

    for i = 1, #frames do
        local frame = frames[i]
        local elements = frame[optimized and "E" or "elements"]
        elements.keywordReference = keyword
        if not elements then
            elements = {}
            frame[optimized and "E" or "elements"] = elements
        end

        table.insert(elements, element)
    end

    print("Added element to " .. #frames .. " frames with keyword '" .. keyword .. "'.")
end

function AnimateAtlas:getBoundTopLeft()
	local timeline = self:getSymbolTimeline()
	if timeline.data then
		timeline = timeline.data[timeline.optimized and "AN" or "ANIMATION"][timeline.optimized and "TL" or "TIMELINE"]
	end

	local bounds = {minX = math.huge, minY = math.huge, maxX = -math.huge, maxY = -math.huge}
	local identity = love.math.newTransform()

	local foundSprites = self:_getTopLeft(self, timeline, self.frame, identity, bounds)

	if foundSprites and bounds.minX ~= math.huge and bounds.minY ~= math.huge then
		return bounds.minX, bounds.minY
	end
	return 0, 0
end

function AnimateAtlas:getBoundDimensions()
	local width, height = 0, 0

	local timeline = self:getSymbolTimeline()
	if timeline.data then
		timeline = timeline.data[timeline.optimized and "AN" or "ANIMATION"][timeline.optimized and "TL" or "TIMELINE"]
	end

	local bounds = {minX = math.huge, minY = math.huge, maxX = -math.huge, maxY = -math.huge}
	local identity = love.math.newTransform()

	local foundSprites = self:_getTopLeft(self, timeline, self.frame, identity, bounds)

	if foundSprites and bounds.minX ~= math.huge and bounds.maxX ~= -math.huge then
		width = math.max(0, bounds.maxX - bounds.minX)
		height = math.max(0, bounds.maxY - bounds.minY)
	end

	return width, height
end

function AnimateAtlas:getMidpoint()
    return self.x + self.width / 2, self.y + self.height / 2
end

function AnimateAtlas:updateHitbox()
    self.width, self.height = self:getBoundDimensions()
    self:fixOffsets()
    self:centerOrigin()
end

function AnimateAtlas:centerOffsets(w, h)
    self.offset.x = (w or self.width) / 2
    self.offset.y = (h or self.height) / 2
end

function AnimateAtlas:fixOffsets(w, h)
    self.offset.x = ((w or self.width) - self.width) / 2
    self.offset.y = ((h or self.height) - self.height) / 2
end

function AnimateAtlas:centerOrigin(w, h)
    self.origin.x = (w or self.width) / 2
    self.origin.y = (h or self.height) / 2
end

-- #region


function AnimateAtlas:hasAnimation(name)
    for i, anim in ipairs(self.animations) do
        if anim.name == name then
            return true
        end
    end

    local frameLabels = self:getFrameLabelList()
    if frameLabels and table.indexOf(frameLabels, name) then
        return true
    end

    if self:isSymbol(name) then
        return true
    end
    
    return false
end

function AnimateAtlas:isAnimationDynamic(id)
    if not self:hasAnimation(id) then
        return false
    end

    for _, anim in ipairs(self.animations) do
        if anim.name == id then
            return #anim.frames > 1
        end
    end

    return false
end

function AnimateAtlas:getCurrentAnimation()
    return self.curAnim and self.curAnim.name or ""
end

function AnimateAtlas:isAnimationFinished()
    return self.animFinished or false
end

function AnimateAtlas:listAnimations()
    local frameLabels = self:getFrameLabelList()
    local animationNames = {}

    for _, anim in ipairs(self.animations) do
        table.insert(animationNames, anim.name)
    end

    for _, label in ipairs(frameLabels) do
        if not table.contains(animationNames, label) then
            table.insert(animationNames, label)
        end
    end

    return animationNames
end

function AnimateAtlas:getSymbolElements(symbol)
    if not self:isSymbol(symbol) then
        return {}
    end

    local lib = self.libraries[symbol]
    if not lib then
        return {}
    end

    local timeline = lib.data
    local optimized = lib.optimized

    local layers = timeline[optimized and "L" or "LAYERS"]
    local elements = {}

    if not layers then
        return elements
    end

    for i = 1, #layers do
        local layer = layers[i]
        local frames = layer[optimized and "FR" or "Frames"]
        
        if frames and #frames > 0 then
            local frameElements = frames[1][optimized and "E" or "elements"] or {}
            for j = 1, #frameElements do
                table.insert(elements, frameElements[j])
            end
        end
    end

    if #elements == 0 then
        print("WARNING: No elements found for '" .. symbol .. "' symbol.")
    end

    return elements
end

function AnimateAtlas:getFirstElement(symbol)
    local elements = self:getSymbolElements(symbol)
    return elements and #elements > 0 and elements[1] or nil
end

function AnimateAtlas:getFramesWithKeyword(keyword)
    local frames = {}

    for symbolName, lib in pairs(self.libraries) do
        if symbolName:find(keyword) then
            local timeline = lib.data

            self:forEachLayer(timeline, function(layer)
                self:forEachLayerFrame(layer, function(frame)
                    table.insert(frames, frame)
                end)
            end)
        end
    end

    return frames
end

function AnimateAtlas:forEachLayerFrame(layer, callback)
    if not layer then return end

    local optimized = layer.optimized == true or layer.FR ~= nil
    local frames = layer[optimized and "FR" or "Frames"]

    if frames then
        for i = 1, #frames do
            callback(frames[i])
        end
    end
end

function AnimateAtlas:forEachLayer(timeline, callback)
    if not timeline then return end

    local optimized = timeline.L ~= nil
    local layers = timeline[optimized and "L" or "LAYERS"]

    if layers then
        for i = 1, #layers do
            callback(layers[i])
        end
    end
end

function AnimateAtlas:resume()
    self.playing = true
end


function AnimateAtlas:addAnimByIndices(name, prefix, indices, framerate, loop)
    framerate = framerate or 30
    loop = loop == nil and true or loop

    local anim = {
        name = name,
        prefix = prefix,
        framerate = framerate,
        loop = loop,
        frames = {}
    }

    local timeline = self.timeline
    local optimized = timeline.optimized == true or timeline.data.L ~= nil
    local timelineData = timeline.data[optimized and "AN" or "ANIMATION"][optimized and "TL" or "TIMELINE"]
    local layers = timelineData[optimized and "L" or "LAYERS"]

    local allFrames = {}

    for i = 1, #layers do
        local layer = layers[i]
        local keyframes = layer[optimized and "FR" or "Frames"]

        for j = 1, #keyframes do
            local keyframe = keyframes[j]
            local nameInFrame = keyframe[optimized and "N" or "name"] or ""
            if nameInFrame == prefix then
                local index = keyframe[optimized and "I" or "index"]
                local duration = keyframe[optimized and "DU" or "duration"] or 1
                for f = index, index + duration - 1 do
                    table.insert(allFrames, f)
                end
            end
        end
    end

    for _, i in ipairs(indices) do
        local f = allFrames[i + 1]
        if f then table.insert(anim.frames, f) end
    end

    if #anim.frames == 0 then
        anim.frames = {0}
    end

    table.insert(self.animations, anim)
end

function AnimateAtlas:addAnimBySymbolIndices(name, symbolName, indices, framerate, loop)
    local lib = self.libraries[symbolName]
    if not lib then
        print("Missing symbol:", symbolName)
        return
    end

    local length = getSymbolFrameCount(lib.data)
    local frames = {}

    for _, i in ipairs(indices) do
        if i >= 0 and i < length then
            frames[#frames + 1] = i
        end
    end

    if #frames == 0 then
        frames = {0}
    end

    table.insert(self.animations, {
        name = name,
        type = "symbol",
        symbolName = symbolName,
        timeline = lib.data,
        optimized = lib.optimized,
        frames = frames,
        framerate = framerate or 24,
        loop = loop ~= false
    })
end

function AnimateAtlas:addAnimBySymbol(name, symbolName, framerate, loop)
    local lib = self.libraries[symbolName]
    if not lib then
        print("Symbol not found with name '" .. symbolName .. "'")
        return
    end

    local length = getSymbolFrameCount(lib.data)
    if length <= 0 then
        print("Symbol '" .. symbolName .. "' has no frames")
        return
    end

    local frames = {}
    for i = 0, length - 1 do
        frames[#frames + 1] = i
    end

    framerate = framerate or self.framerate or 24
    loop = loop ~= false

    table.insert(self.animations, {
        name = name,
        type = "symbol",
        symbolName = symbolName,
        timeline = lib.data,
        optimized = lib.optimized,
        frames = frames,
        framerate = framerate,
        loop = loop
    })

    print(#frames .. " frames added for symbol '" .. symbolName .. "' with animation name '" .. name .. "'.")
end

function AnimateAtlas:addAnimByNameWithFallback(name, sourceNameOrSymbol, framerate, loop)
    framerate = framerate or 30
    loop = loop == nil and true or loop

    if self:isSymbol(sourceNameOrSymbol) then
        return self:addAnimBySymbol(name, sourceNameOrSymbol, framerate, loop)
    end

    local frameCount = self:getLength()
    if frameCount > 0 then
        local frames = {}
        for i = 0, frameCount - 1 do
            table.insert(frames, i)
        end
        self:addAnimByIndices(name, "", frames, framerate, loop)
        return true
    end

    return false
end

function AnimateAtlas:pause()
    self.animPaused = true
end

function AnimateAtlas:stop()
    self.playing = false
    self._frameTimer = 0.0
end

function AnimateAtlas:resume()
    self.playing = true
end

function AnimateAtlas:clone()
    local clone = AnimateAtlas(self.atlasSettings)
    clone.libraries = self.libraries
    clone.timeline = self.timeline
    clone.spritemaps = self.spritemaps
    return clone
end

return AnimateAtlas
