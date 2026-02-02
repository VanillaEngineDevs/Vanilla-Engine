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

    self.x = 0
    self.y = 0
    self.rotation = 0
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

function AnimateAtlas:stop()
    self.playing = false
    self._frameTimer = 0.0
end

function AnimateAtlas:resume()
    self.playing = true
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

function AnimateAtlas:addAnimBySymbol(name, symbolName, framerate, loop)
    framerate = framerate or 30
    loop = loop == nil and true or loop

    local anim = {
        name = name,
        symbolName = symbolName,
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
            if nameInFrame == symbolName then
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

function AnimateAtlas:addAnimBySymbolIndices(name, symbolName, indices, framerate, loop)
    framerate = framerate or 30
    loop = loop == nil and true or loop

    local anim = {
        name = name,
        symbolName = symbolName,
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
            if nameInFrame == symbolName then
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

---
--- @param animName string?
--- @param loop boolean?
---
function AnimateAtlas:play(animName, forced, loop)
    -- if anim exists and is not finished, forced needs to be true to continue
    if
        self.curAnim ~= nil and
        self.curAnim.name == animName and
        self.playing and
        not forced
    then
        return
    end
    
    for i, anim in ipairs(self.animations) do
        if anim.name == animName then
            self.curAnim = anim
            self.frame = 1
            self.playing = true
            self.looping = loop ~= nil and loop or anim.loop
            self.animFinished = false
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
    return self.timeline.data[optimized and "AN" or "ANIMATION"][optimized and "TL" or "TIMELINE"][optimized and "N" or "name"]
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

local function renderSymbol(self, symbol, frame, index, matrix, colorTransform, optimized, stencilMode)
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

    self:drawTimeline(symbolTimeline, frameIndex, matrix:clone():apply(symbolMatrix), colorTransform, stencilMode)
    for _, fe in ipairs(self.frameElements) do
        if fe.filter(frame) then
            fe.element:draw(self, frame.matrix)
        end
    end
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
        --love.graphics.setShader(self._colorTransformShader)

        self:setColorOffset(0, 0, 0, 0)
        self:setColorMultiplier(1, 1, 1, 1)

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

local function renderKeyFrame(self, keyframe, frame, matrix, colorTransform, optimized, stencilMode)
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
            renderSymbol(self, symbol, frame, index, matrix, colorTransform, optimized, stencilMode)
        elseif atlasSprite then
            renderAtlasSprite(self, atlasSprite, matrix, colorTransform, optimized, stencilMode)
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
	local timelineLayers = timeline[optimized and "L" or "LAYERS"]
	local namesToLayers = {}

	for i = #timelineLayers, 1, -1 do
		local layer = timelineLayers[i]
		namesToLayers[layer[optimized and "LN" or "Layer_name"]] = layer
	end

	for i = #timelineLayers, 1, -1 do
		local layer = timelineLayers[i]
		local keyframes = layer[optimized and "FR" or "Frames"]
		local layerType = layer[optimized and "LT" or "Layer_type"]
		local clippedBy = layer[optimized and "CB" or "Clipped_by"] or layer[optimized and "Clpb" or "Clipped_by"]

		if layerType ~= nil then
			goto continue
		end

		if clippedBy ~= nil then
            local maskLayer = namesToLayers[clippedBy]
            self:_pushMask(maskLayer, frame, matrix, optimized)
        end

		for j = 1, #keyframes do
			if renderKeyFrame(self, keyframes[j], frame, matrix, colorTransform, optimized) then
				break
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

function AnimateAtlas:update(dt)
    if self.framerate <= 0 or not self.playing or not self.curAnim then return end

    self._frameTimer = self._frameTimer + dt
    local interval = 1 / self.curAnim.framerate

    while self._frameTimer >= interval do
        self._frameTimer = self._frameTimer - interval
        self.frame = self.frame + 1

        if self.frame > #self.curAnim.frames then
            if self.looping then
                self.frame = 1
            else
                self.playing = false
                self.animFinished = true
                self.frame = #self.curAnim.frames
                if self._callback then
                    self._callback(self.objectReference)
                end
            end
        end

        self.onFrameChange:emit(self.curAnim.name, self.frame, self.curAnim.frames[self.frame])
        if self.animFinished then
            self.onAnimationFinished:emit(self.curAnim.name)
        end
    end
end

function AnimateAtlas:hasAnimation(name)
    for i, anim in ipairs(self.animations) do
        if anim.name == name then
            return true
        end
    end
    return false
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
	symbolMatrix:setMatrix((is3DMatrix and matrix3D or matrix2D)(symbolMatrixRaw, optimized))

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
	spriteMatrix:setMatrix((is3DMatrix and matrix3D or matrix2D)(spriteMatrixRaw, optimized))

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

function AnimateAtlas:stop()
    self.playing = false
    self.frame = 1
end

function AnimateAtlas:resume()
    self.playing = true
end

function AnimateAtlas:draw(camera, x, y, r, sx, sy, ox, oy)
    if not self.visible then
        return
    end
    camera = camera or {x = 0, y = 0}
    local cx = camera.x
    local cy = camera.y
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

    local timeline
    if self.curAnim and self.curAnim.frames then
        local frameIndex = self.curAnim.frames[math.min(self.frame, #self.curAnim.frames)]
        timeline = self:getSymbolTimeline()
        if timeline.data then
            timeline = timeline.data[timeline.optimized and "AN" or "ANIMATION"][timeline.optimized and "TL" or "TIMELINE"]
        end
        self._curSymbol = nil
        self:drawTimeline(timeline, frameIndex, identity, nil)
    end
end

return AnimateAtlas