---@diagnostic disable: param-type-mismatch
local baseDirectory = (...):match("(.-)[^%.]+$")
local Classic = require(baseDirectory .. "libs.Classic")

---
--- @class love.animate.SparrowAtlas
---
local SparrowAtlas = Classic:extend()

--[[ local json = require("loveanimate.libs.Json")
local xml = require("loveanimate.libs.Xml")
require("loveanimate.libs.StringUtil") ]]
local xml = require(baseDirectory .. "libs.Xml")
require(baseDirectory .. "libs.StringUtil")

local currentImageFormat = "." .. graphics.getImageType()

local function fileExists(path)
    return love.filesystem.getInfo(path, "file") ~= nil
end

local function getFileContent(path)
    if fileExists(path) then
        local content, _, _, _ = love.filesystem.read("string", path, nil)
        return content --- @type string
    end
    return ""
end

local function createFrame(name, x, y, width, height, sheetWidth, sheetHeight, ox, oy, oWidth, oHeight, rotated)
    local aw, ah = x + width, y + height

    local frame = {
        name = name, ---@type string
        quad = love.graphics.newQuad( ---@type love.Quad
            x, y,
            aw > sheetWidth and width - (aw - sheetWidth) or width,
            ah > sheetHeight and height - (ah - sheetHeight) or height,
            sheetWidth, sheetHeight
        ),
        width = oWidth or width, ---@type number
        height = oHeight or height, ---@type number
        offset = { ---@type {x: number, y: number}
            x = ox or 0,
            y = oy or 0
        },
        rotated = rotated or false ---@type boolean
    }

    return frame
end

local function sortFramesByIndices(prefix, postfix)
	local s, e = #prefix + 1, - #postfix - 1
	return function(a, b)
		return string.sub(a.name, s, e) < string.sub(b.name, s, e)
	end
end

function SparrowAtlas:constructor()
    self.frame = 0
    self.framerate = 24

    self.playing = false
    self.looping = false

    self.image = nil --- @type love.Image

    --- @protected
    self._frameTimer = 0
    self.currentFrame = 1

    self.frames = {}
    self.animations = {}
    self.curAnim = nil

    self.x = 0
    self.y = 0
    self.rotation = 0
    self.angle = 0 -- this is used instead of rotation to simulate a centered origin rotation
    -- rotation can still be used to rotate around the origin, though this simulates it
    self.scale = {x = 1, y = 1}
    self.origin = {x = 0, y = 0}
    self.offset = {x = 0, y = 0}
    self.colour = {1, 1, 1}
    self.scroll = {x = 1, y = 1}
    self.alpha = 1

    self.shader = nil
    self.visible = true

    self.flipX = false
    self.flipY = false

    self.zIndex = 0

    self.suffix = ""

    self.flipXAnims = {}
    self.flipYAnims = {}

    self.onFrameChange = signal.new()
    self.onAnimationFinished = signal.new()

end

function SparrowAtlas:setSuffix(suffix)
    self.suffix = suffix

    self:play((self.curAnim and self.curAnim.name or "") .. self.suffix, true)
end

--- Load the atlas from an image and xml
--- 
--- @param  imageData?   love.Image|string  Either a Love2D image instance or an image file path.
--- @param  dataString?   string             Either XML data or an XML file path.
--- @param  framerate?   integer            Framerate of each animation. (This is not specified in the XML, so it must be manually specified) (fallback is 24)
---
function SparrowAtlas:load(imageData, dataString, framerate)
    ---@diagnostic disable-next-line: cast-local-type
    dataString = dataString or imageData
    local ogPath = imageData
    if type(imageData) == "string" and not imageData:startsWith("#") then
        imageData = "assets/" .. imageData .. currentImageFormat
        if fileExists(imageData) then
            if graphics.cache[imageData] then
                imageData = graphics.cache[imageData]
            else
                imageData = love.graphics.newImage(imageData)
                graphics.cache[imageData] = imageData
            end
        end
        self.IS_RECTANGLE = false
    elseif type(imageData) == "string" and imageData:startsWith("#") then
        self.IS_RECTANGLE = true
        local colorCode = imageData:sub(2)
        local r = tonumber("0x" .. colorCode:sub(1, 2)) / 255
        local g = tonumber("0x" .. colorCode:sub(3, 4)) / 255
        local b = tonumber("0x" .. colorCode:sub(5, 6)) / 255
        self.colour = {r, g, b}
    end

    -- if no image, print FAILED TO LOAD IMAGE: path
    if not love.filesystem.getInfo("assets/" .. ogPath .. currentImageFormat, "file") and not self.IS_RECTANGLE then
        print("FAILED TO LOAD IMAGE: " .. tostring(ogPath))
    end

    self.image = imageData
    self.framerate = framerate or 24
    if dataString then
        dataString = "assets/" .. dataString .. ".xml"
        if fileExists(dataString) then
            dataString = getFileContent(dataString)
            local xmlData = xml.parse(dataString)
            local sw, sh = self.image:getWidth(), self.image:getHeight()

            for i = 1, #xmlData.TextureAtlas.children do
                local node = xmlData.TextureAtlas.children[i]
                if node.name ~= "SubTexture" then
                    goto continue
                end

                table.insert(self.frames, createFrame(
                    node.att.name,
                    tonumber(node.att.x), tonumber(node.att.y),
                    tonumber(node.att.width), tonumber(node.att.height),
                    sw, sh,
                    tonumber(node.att.frameX) or 0, tonumber(node.att.frameY) or 0,
                    tonumber(node.att.frameWidth), tonumber(node.att.frameHeight),
                    node.att.rotated == "true"
                ))

                ::continue::
            end
        else
            dataString = dataString:gsub("%.xml$", ".txt")
            local content = getFileContent(dataString)
            for line in content:gmatch("[^\r\n]+") do
                local name, x, y, width, height = line:match("^(.-)%s*=%s*(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
                local _, frameid = name:match("^(.-)_(%d+)$")
                frameid = tonumber(frameid)
                if name and x and y and width and height and frameid then
                    print(name, x, y, width, height, frameid)
                    table.insert(self.frames, createFrame(
                        name,
                        tonumber(x), tonumber(y),
                        tonumber(width), tonumber(height),
                        self.image:getWidth(), self.image:getHeight()
                    ))
                end
            end
        end
    end

    self:centerOrigin()
end

function SparrowAtlas:setAntialiasing(antialiasing)
    if self.image and self.image.setFilter then
        self.image:setFilter(antialiasing and "linear" or "nearest", antialiasing and "linear" or "nearest")
    end
end

function SparrowAtlas:addAnimByPrefix(name, prefix, framerate, looped)
    framerate = framerate or 30
    looped = looped == nil and true or looped

    local anim, foundFrame = {
        name = name,
        framerate = framerate,
        looped = looped,
        frames = {}
    }, false

    for _, f in ipairs(self.frames) do
		if f.name:startsWith(prefix) then
			foundFrame = true
			table.insert(anim.frames, f)
		end
	end

	if not foundFrame then return end

	table.sort(anim.frames, sortFramesByIndices(prefix, ""))

	if not self.animations then self.animations = {} end
	self.animations[name] = anim
end

function SparrowAtlas:addAnimByIndices(name, prefix, indices, postfix, framerate, looped)
	if postfix == nil then postfix = "" end
	if framerate == nil then framerate = 30 end
	if looped == nil then looped = true end

	local anim = {
		name = name,
		framerate = framerate,
		looped = looped,
		frames = {}
	}

	local allFrames, foundFrame = {}, false
	local notPostfix = #postfix <= 0
	for _, f in ipairs(self.frames) do
		if f.name:startsWith(prefix) and
			(notPostfix or f.name:endsWith(postfix)) then
			foundFrame = true
			table.insert(allFrames, f)
		end
	end
	if not foundFrame then return end

	table.sort(allFrames, sortFramesByIndices(prefix, postfix))

	for _, i in ipairs(indices) do
		local f = allFrames[i + 1]
		if f then table.insert(anim.frames, f) end
	end

	if not self.animations then self.animations = {} end
	self.animations[name] = anim
end

function SparrowAtlas:addAnimByFrames(name, frames, framerate, looped)
	if framerate == nil then framerate = 30 end
	if looped == nil then looped = true end

	local anim = {
		name = name,
		framerate = framerate,
		looped = looped,
		frames = {}
	}

	for _, f in ipairs(frames) do
		local frame = self.frames[f]
		if frame then
			table.insert(anim.frames, frame)
		end
	end

	if not self.animations then self.animations = {} end
	self.animations[name] = anim
end

function SparrowAtlas:hasAnimation(name)
    return self.animations and self.animations[name] ~= nil
end

---
--- @param  anim   string?
--- @param  force  boolean?
--- @param  loop   boolean?
--- @param  frame  integer?
---
function SparrowAtlas:play(anim, force, loop, frame)
    local curAnim = self.curAnim

	if curAnim and not force and curAnim.name == anim and
		not self.animFinished then
		self.animFinished = false
		self.animPaused = false
		return
	end
	if not self.animations then return end

	curAnim = self.animations[anim]
	if curAnim then
		self.curAnim = curAnim
		self.currentFrame = frame or 1
		self.animFinished = false
		self.animPaused = false
        if loop ~= nil then
            self.curAnim.looped = loop
        end
	end
end

function SparrowAtlas:updateHitbox()
	local width, height = self:getFrameDimensions()

	self.width = math.abs(self.scale.x) * width
	self.height = math.abs(self.scale.y) * height

	self:fixOffsets(width, height)
	self:centerOrigin(width, height)
end

---@param width number
---@param height number
function SparrowAtlas:centerOffsets(width, height)
	self.offset.x = (width or self:getFrameWidth()) / 2
	self.offset.y = (height or self:getFrameHeight()) / 2
	print(self.offset.x, self.offset.y)
end

---@param width number
---@param height number
function SparrowAtlas:fixOffsets(width, height)
	self.offset.x = (self.width - (width or self:getFrameWidth())) / -2
	self.offset.y = (self.height - (height or self:getFrameHeight())) / -2
end

---@param width? number
---@param height? number
function SparrowAtlas:centerOrigin(width, height)
	self.origin.x = (width or self:getFrameWidth()) / 2
	self.origin.y = (height or self:getFrameHeight()) / 2
end

---@deprecated
function SparrowAtlas:animate(name, looping, onComplete)
    print("SparrowAtlas:animate is deprecated. Use SparrowAtlas:play instead.")
    self:play(name, looping)
end

function SparrowAtlas:stop()
    self.playing = false
    self._frameTimer = 0.0
end

function SparrowAtlas:resume()
    self.playing = true
end

function SparrowAtlas:getCurrentAnimation()
    return self.curAnim.name
end

function SparrowAtlas:getCurrentFrame()
    if self.curAnim then
        return self.curAnim.frames[math.floor(self.currentFrame)]
    elseif self.frames then
        return self.frames[1]
    end
    return nil
end

---
--- @return number
---
function SparrowAtlas:getFrameWidth()
    local frame = self:getCurrentFrame()
    if not self.IS_RECTANGLE and self.image then
        frame = frame or { width = self.image:getWidth() }
    elseif self.IS_RECTANGLE then
        frame = { width = self.scale.x }
    end
    return frame.width
end

---
--- @return number
---
function SparrowAtlas:getFrameHeight()
    local frame = self:getCurrentFrame()
    if not self.IS_RECTANGLE and self.image then
        frame = frame or { height = self.image:getHeight() }
    elseif self.IS_RECTANGLE then
        frame = { height = self.scale.y }
    end
    return frame.height
end

---
--- @return number, number
---
function SparrowAtlas:getFrameDimensions()
    local frame = self:getCurrentFrame()
    if not self.IS_RECTANGLE and self.image then
        frame = frame or { width = self.image:getWidth(), height = self.image:getHeight() }
    elseif self.IS_RECTANGLE then
        frame = { width = self.scale.x, height = self.scale.y }
    end
    return frame.width, frame.height
end

function SparrowAtlas:getMidpoint()
    local w, h = self:getFrameDimensions()
    return w*3, h*1.25
end

function SparrowAtlas:update(dt, emitSignals)
    if emitSignals == nil then emitSignals = true end
    if not (self.curAnim and not self.animFinished and not self.animPaused) then
        return
    end

    self.currentFrame = tonumber(self.currentFrame) or 1
    self.currentFrame = self.currentFrame + dt * self.curAnim.framerate

    if self.currentFrame >= #self.curAnim.frames + 1 then
        if self.curAnim.looped then
            self.currentFrame = 1
        else
            self.currentFrame = #self.curAnim.frames
            self.animFinished = true
        end
    end

    local frameIndex = math.floor(self.currentFrame)
    local lastFrameIndex = self.lastFrameIndex or 0

    if emitSignals and frameIndex ~= lastFrameIndex then
        self.onFrameChange:emit(
            self.curAnim.name,
            frameIndex,
            self.curAnim.frames[frameIndex]
        )
        self.lastFrameIndex = frameIndex
    end

    if self.animFinished and emitSignals then
        self.onAnimationFinished:emit(self.curAnim.name)
    end
end

function SparrowAtlas:draw(camera, x, y, r, sx, sy, ox, oy)
    if not self.visible then
        return
    end
    camera = camera or {x = 0, y = 0, shakeX = 0, shakeY = 0, centered = false}
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

    local flipX, flipY = self.flipX, self.flipY

    -- if curanim, check if flipx or flipy anim, if so, set flipx or flipy to true
    if self.curAnim then
        if self.flipXAnims[self.curAnim.name] then
            flipX = true
        end
        if self.flipYAnims[self.curAnim.name] then
            flipY = true
        end
        
    end

    if flipX then
        sx = sx * -1
        --x = x + (self:getFrameWidth() * -1)
    end
    if flipY then
        sy = sy * -1
    end

    local curFrame = self:getCurrentFrame()

    x = x + ox - self.offset.x - (cx * self.scroll.x)
    y = y + oy - self.offset.y - (cy * self.scroll.y)

    if curFrame then
        if curFrame.rotated then
            r = r - math.pi / 2
            ox, oy = select(3, curFrame.quad:getViewport()) - (oy + curFrame.offset.y), ox + curFrame.offset.x
            sx, sy = sy, sx
        else
            ox = ox + curFrame.offset.x * (sx < 0 and -1 or 1)
            oy = oy + curFrame.offset.y * (sy < 0 and -1 or 1)
        end
    end

    -- apply angle
    if self.angle and self.angle ~= 0 then
        r = r + self.angle
        -- sin/cos magic for rotating around the center of the sprite
        local centerX = self:getFrameWidth() / 2
        local centerY = self:getFrameHeight() / 2
        local offsetX = x - centerX
        local offsetY = y - centerY
        local cos = math.cos(self.angle)
        local sin = math.sin(self.angle)
        x = centerX + offsetX * cos - offsetY * sin
        y = centerY + offsetX * sin + offsetY * cos
    end

    local lastShader = love.graphics.getShader()
    love.graphics.setShader(self.shader)
    local lastColor = {love.graphics.getColor()}
    love.graphics.setColor(self.colour[1] * lastColor[1], self.colour[2] * lastColor[2], self.colour[3] * lastColor[3], self.alpha * lastColor[4])
    if curFrame and not self.IS_RECTANGLE then
        love.graphics.draw(self.image, curFrame.quad, x, y, r, sx, sy, ox, oy)
    elseif not curFrame and not self.IS_RECTANGLE then
        love.graphics.draw(self.image, x, y, r, sx, sy, ox, oy)
    else
        -- ox and oy scales from the scale (sx and sy IS the height)
        local nox = ox * (sx < 0 and -1 or 1)
        local noy = oy * (sy < 0 and -1 or 1)
        love.graphics.rectangle("fill", x - nox, y - noy, sx, sy)
    end

    love.graphics.setColor(lastColor)
    love.graphics.setShader(lastShader)
end

function SparrowAtlas:clone() -- i gnot no idea if this works ngl
    local clone = SparrowAtlas()
    if not self.IS_RECTANGLE then
        clone.image = self.image
    end
    clone.framerate = self.framerate
    clone.frames = self.frames
    clone.animations = self.animations
    clone.curAnim = {
        name = self.curAnim and self.curAnim.name or nil,
        framerate = self.curAnim and self.curAnim.framerate or nil,
        looped = self.curAnim and self.curAnim.looped or nil,
        frames = self.curAnim and self.curAnim.frames or nil
    }
    clone.currentFrame = self.currentFrame
    clone.x = self.x
    clone.y = self.y
    clone.rotation = self.rotation
    clone.angle = self.angle
    clone.scale = {x = self.scale.x, y = self.scale.y}
    clone.origin = {x = self.origin.x, y = self.origin.y}
    clone.offset = {x = self.offset.x, y = self.offset.y}
    clone.colour = {self.colour[1], self.colour[2], self.colour[3]}
    clone.alpha = self.alpha
    clone.shader = self.shader
    clone.visible = self.visible
    clone.flipX = self.flipX
    clone.flipY = self.flipY
    clone.zIndex = self.zIndex
    clone.suffix = self.suffix
    clone.flipXAnims = self.flipXAnims
    clone.flipYAnims = self.flipYAnims
    return clone
end

return SparrowAtlas