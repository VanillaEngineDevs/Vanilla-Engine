---@diagnostic disable: undefined-field
---@class Sprite : Object

Sprite = Object:extend()

local function sortFramesByIndices(prefix, postfix)
	local s, e = #prefix + 1, - #postfix - 1
	return function(a, b)
		return string.sub(a.name, s, e) < string.sub(b.name, s, e)
	end
end

--- Not to be used explicitly.
---@alias frame { name: string, quad: love.Quad, width: number, height: number, offset: { x: number, y: number } }

---@return frame
function Sprite.CreateFrame(name, x, y, width, height, sheetWidth, sheetHeight, ox, oy, oWidth, oHeight)
    local aw, ah = x + width, y + height

    ---@type frame
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
        }
    }

    return frame
end

---@param x number
---@param y number
---@param graphic (string | love.Drawable)?
function Sprite:new(x, y, graphic)
    Object.new(self, x, y)

    self.curAnim = nil
    self.curFrame = nil
    self.animFinished = nil
    self.animPaused = false

    self.frames = nil
    self.anims = nil
	self.lastFrame = 0

    self.offset = Point()
	self.animOffsets = {}

	self.cameras = {}

	self.alpha = 1

    if graphic then
        self:load(graphic)
    end

	self.onFrameChange = Signal()
	self.onFinish = Signal()
end

---@param graphic (string | love.Drawable)
function Sprite:load(graphic)
    if type(graphic) == "string" then
        self.graphic = Graphic:getGraphic(graphic)
    else
        self.graphic = graphic
    end

    self.width, self.height = self.graphic:getDimensions()
end

---@param anim string
---@param force? boolean
---@param frame? number
function Sprite:play(anim, force, frame)
	local curAnim = self.curAnim

	if curAnim and not force and curAnim.name == anim and
		not self.animFinished then
		self.animFinished = false
		self.animPaused = false
		return
	end
	if not self.anims then return end

	curAnim = self.anims[anim]
	if curAnim then
		self.curAnim = curAnim
		self.curFrame = frame or 1
		self.animFinished = false
		self.animPaused = false
	end
end

function Sprite:setAnimationOffsets(anim, offsetX, offsetY)
	if not self.anims then return end
	if not self.anims[anim] then return end

	if type(offsetX) == "number" then
		self.animOffsets[anim] = Point(offsetX, offsetY or offsetX)
	else
		self.animOffsets[anim] = offsetX
	end
end

function Sprite:pause()
	if self.curAnim and not self.animFinished then self.animPaused = true end
end

function Sprite:resume()
	if self.curAnim and not self.animFinished then self.animPaused = false end
end

function Sprite:finish()
    if self.curAnim then
        self.animFinished = true
        self.animPaused = true
    end
end

---@param frames {frames: frame, graphic: love.Drawable}
function Sprite:setFrames(frames)
    self.frames = frames.frames

    self:load(frames.graphic)
    self.width, self.height = self:getFrameDimensions()
    self:centerOrigin()
end

---@param name string
---@param prefix string
---@param framerate? number
---@param looped? boolean
function Sprite:addAnimByPrefix(name, prefix, framerate, looped)
	if framerate == nil then framerate = 30 end
	if looped == nil then looped = true end

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

	if not self.anims then self.anims = {} end
	self.anims[name] = anim
end

---@param name string
---@param prefix string
---@param indices table
---@param framerate? number
---@param looped? boolean
function Sprite:addAnimByIndices(name, prefix, indices, postfix, framerate, looped)
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

	if not self.anims then self.anims = {} end
	self.anims[name] = anim
end

function Sprite:addAnimByFrames(name, frames, framerate, looped)
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

	if not self.anims then self.anims = {} end
	self.anims[name] = anim
end

function Sprite:getCurrentFrame()
    if self.curAnim then
        return self.curAnim.frames[math.floor(self.curFrame)]
    elseif self.frames then
        return self.frames[1]
    end
    return nil
end

function Sprite:getFrameWidth()
    local frame = self:getCurrentFrame()
    return frame and frame.width or self.graphic and self.graphic:getWidth() or 0
end

function Sprite:getFrameHeight()
    local frame = self:getCurrentFrame()
    return frame and frame.height or self.graphic and self.graphic:getHeight() or 0
end

function Sprite:getFrameDimensions()
    return self:getFrameWidth(), self:getFrameHeight()
end

function Sprite:getCurrentAnimation()
	return self.curAnim.name
end

function Sprite:getAnimByName(name)
	return self.anims[name]
end

---@param width number
---@param height number
function Sprite:setGraphicSize(width, height)
	if width == nil then width = 0 end
	if height == nil then height = 0 end

	self.scale.x = width / self:getFrameWidth()
	self.scale.y = height / self:getFrameHeight()

	if width <= 0 then
		self.scale.x = self.scale.y
	elseif height <= 0 then
		self.scale.y = self.scale.x
	end
end

function Sprite:updateHitbox()
	local width, height = self:getFrameDimensions()

	self.width = math.abs(self.scale.x) * width
	self.height = math.abs(self.scale.y) * height

	self:fixOffsets(width, height)
	self:centerOrigin(width, height)
end

---@param width number
---@param height number
function Sprite:centerOffsets(width, height)
	self.offset.x = (width or self:getFrameWidth()) / 2
	self.offset.y = (height or self:getFrameHeight()) / 2
end

---@param width number
---@param height number
function Sprite:fixOffsets(width, height)
	self.offset.x = (self.width - (width or self:getFrameWidth())) / -2
	self.offset.y = (self.height - (height or self:getFrameHeight())) / -2
end

---@param width? number
---@param height? number
function Sprite:centerOrigin(width, height)
	self.origin.x = (width or self:getFrameWidth()) / 2
	self.origin.y = (height or self:getFrameHeight()) / 2
end

---@param dt number
function Sprite:update(dt)
    Object.update(self, dt)

    if self.curAnim and not self.animFinished and not self.animPaused then
        self.curFrame = self.curFrame + dt * self.curAnim.framerate
        if self.curFrame >= #self.curAnim.frames + 1 then
			if self.curFrame ~= self.lastFrame then
				self.onFrameChange:dispatch(self, self.curAnim.name, #self.curAnim.frames)
				self.lastFrame = self.curFrame
			end
			self.onFinish:dispatch(self, self.curAnim.name)
            if self.curAnim.looped then
                self.curFrame = 1
            else
                self.curFrame = #self.curAnim.frames
                self.animFinished = true
            end
        end
    end
end

function Sprite:draw(forcedCamera)
	if not forcedCamera then
		if #self.cameras <= 0 then
			self:render(Camera._defaultCameras[1])
		end
		for _, camera in ipairs(self.cameras) do
			self:render(camera)
		end
	else
		self:render(forcedCamera)
	end
end

---@param camera Camera
function Sprite:render(camera)
	if not self.graphic then return end
	love.graphics.push()

	camera:applyTransform()

    local lastColor = {love.graphics.getColor()}
    local blend, alphaMode = love.graphics.getBlendMode()

    local curFrame = self:getCurrentFrame()

    local x, y, rot, sx, sy, ox, oy = self.x, self.y, math.rad(self.angle), self.scale.x, self.scale.y, self.origin.x, self.origin.y

    if self.flipX then sx = -sx end
    if self.flipY then sy = -sy end

    x = x + ox - self.offset.x - (camera.scroll.x * self.scrollFactor.x)
    y = y + oy - self.offset.y - (camera.scroll.y * self.scrollFactor.y)

    if curFrame then
        ox = ox + curFrame.offset.x
        oy = oy + curFrame.offset.y

		if self.animOffsets[curFrame.name] then
			ox = ox + self.animOffsets[curFrame.name].x
			oy = oy + self.animOffsets[curFrame.name].y
		end
    end

	if self.printIfDrawing then printf("Drawing sprite %s at (%d, %d) with rotation %.2f and scale (%.2f, %.2f)", self._label or "unknown", x, y, rot, sx, sy) end

    if not curFrame then
        love.graphics.draw(self.graphic, x, y, rot, sx, sy, ox, oy)
    else
        love.graphics.draw(self.graphic, curFrame.quad, x, y, rot, sx, sy, ox, oy)
    end

	love.graphics.pop()
end

return Sprite