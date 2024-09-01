-- For XML's

function getImage(key)
    local key = key .. ".png"
    -- does it exist? if not, try remove ".png"
    if not love.filesystem.getInfo(key) then
        key = key:gsub(".png", "")
    end
    if graphics.cache[key] then
        return graphics.cache[key]
    else
        local img = love.graphics.newImage(key)
        graphics.cache[key] = img
        return img
    end

    return nil
end
function getSparrow(key)
    local ip, xp = key, key .. ".xml"
    -- remove ".dds" from the key
    xp = xp:gsub(".dds.xml", ".xml")
    local i = getImage(ip)
    if love.filesystem.getInfo(xp) then
        local o = Sprite.getFramesFromSparrow(i, love.filesystem.read(xp))
        return o
    end

    return nil
end

local Sprite = Object:extend()
local stencilS, stencilX, stencilY = {}, 0, 0

local function _stencil()
    if stencilS then
        love.graphics.push()
            love.graphics.translate(stencilX + stencilS.clipRect.x + stencilS.clipRect.width /2,
                                    stencilY + stencilS.clipRect.y + stencilS.clipRect.height/2)
            love.graphics.rotate(stencilS.angle)
            love.graphics.translate(-stencilS.clipRect.width /2, -stencilS.clipRect.height/2)
            love.graphics.rectangle("fill", -stencilS.width/2, -stencilS.height/2, stencilS.clipRect.width, stencilS.clipRect.height)
        love.graphics.pop()
    end
end

Sprite.defaultCam = nil

function Sprite.newFrame(name, x, y, w, h, sw, sh, ox, oy, ow, oh)
    local aw, ah = x+w, y+h
    return {
        name = name,
        quad = love.graphics.newQuad(
            x, y,
            aw > sw and w - (aw - sw) or w,
            ah > sh and h - (ah - sh) or h,
            sw, sh
        ),
        width = ow or w,
        height = oh or h,
        offset = {x = ox or 0, y = oy or 0}
    }
end 

function Sprite.getFramesFromSparrow(tex, desc)
    if type(tex) == "string" then tex = love.graphics.newImage(tex) end

    local f = {texture=tex, frames={}}
    local sw, sh = tex:getWidth(), tex:getHeight()
    ---@diagnostic disable-next-line: param-type-mismatch
    for i, c in ipairs(xml.parse(desc)) do
        if c.tag == "SubTexture" then
            table.insert(f.frames, Sprite.newFrame(
                c.attr.name,
                tonumber(c.attr.x),
                tonumber(c.attr.y),
                tonumber(c.attr.width),
                tonumber(c.attr.height),
                sw, sh,
                tonumber(c.attr.frameX) or 0,
                tonumber(c.attr.frameY) or 0,
                tonumber(c.attr.frameWidth),
                tonumber(c.attr.frameHeight)
            ))
        end
    end

    return f
end

function Sprite:new(x, y, tex)
    local x = x or 0
    local y = y or 0
    self.x = x
    self.y = y

    self.texture = nil
    self.width = 0
    self.height = 0
    self.antialiasing = true

    self.camera = nil
    
    self.origin = {x=0,y=0}
    self.offset = {x=0,y=0}
    self.scale = {x=1,y=1}
    self.shear = {x=0,y=0}
    self.scrollFactor = {x=1,y=1}
    self.animationOffset = {}

    self.clipRect = nil

    self.flipX = false
    self.flipY = false

    self.color = {1,1,1}
    self.alpha = 1
    self.angle = 0

    self._frames = nil
    self._animations = nil

    self.curAnim = nil
    self.curFrame = nil
    self.animFinished = nil
    self.maxHoldTimer = 0.1
    self.holdTimer = 0
    self.singDuration = 4
    self.cameraPosition = {x = 0, y = 0}

    if tex then self:load(tex) end
end

function Sprite:load(tex, w, h)
    if type(tex) == "string" then
        tex = love.graphics.newImage(tex)
    end
    self.tex = tex

    self.width = w or tex:getWidth()
    self.height = h or tex:getHeight()

    self.curAnim = nil
    self.curFrame = nil
    self.animFinished = false

    return self
end

function Sprite:loadGraphic(tex, frameW, frameH) -- just used for icons lol!!!!!
    if type(tex) == "string" then
        tex = love.graphics.newImage(tex)
    end
    self.tex = tex

    self.width = tex:getWidth()
    self.height = tex:getHeight()

    self.curAnim = nil
    self.curFrame = 1
    self.animFinished = false

    self._frames = {}
    for i = 0, self.width, frameW do
        for j = 0, self.height, frameH do
            table.insert(self._frames, Sprite.newFrame(
                tostring(#self._frames + 1),
                i,
                j,
                frameW,
                frameH,
                self.width,
                self.height,
                0,
                0,
                frameW,
                frameH
            ))
        end
    end

    return self
end

function Sprite:setFrames(f)
    self._frames = f.frames
    self.tex = f.texture

    self:load(f.texture)
    self.width = self:getFrameWidth()
    self.height = self:getFrameHeight()

    self.maxHoldTimer = 0.1
    self.holdTimer = 0
    self.singDuration = 4
    self.cameraPosition = {x = 0, y = 0}
end

function Sprite:getFrame()
    if self.curAnim then
        return self.curAnim.frames[math.floor(self.curFrame)]
    elseif self._frames then
        return self._frames[1]
    end
    return nil
end

function Sprite:getFrameWidth()
    local f = self:getFrame()
    if f then return f.width 
    else return self.tex:getWidth() end
end

function Sprite:getFrameHeight()
    local f = self:getFrame()
    if f then return f.height 
    else return self.tex:getHeight() end
end

function Sprite:setGraphicSize(width, height)
	if width == nil then width = 0 end
	if height == nil then height = 0 end

	self.scale = {
		x = width / self:getFrameWidth(),
		y = height / self:getFrameHeight()
	}

	if width <= 0 then
		self.scale.x = self.scale.y
	elseif height <= 0 then
		self.scale.y = self.scale.x
	end
end

function Sprite:updateHitbox()
    local w = self:getFrameWidth()
    local h = self:getFrameHeight()

    self.width = math.abs(self.scale.x) * w
    self.height = math.abs(self.scale.y) * h

    self.offset.x = -0.5 * (self.width - w)
    self.offset.y = -0.5 * (self.height - h)
    self:centerOrigin()
end

function Sprite:centerOrigin()
    self.origin.x = self.width / 2
    self.origin.y = self.height / 2
end

function Sprite:centerOffsets()
    self.offset.x = (self:getFrameWidth() - self.width) / 2
    self.offset.y = (self:getFrameHeight() - self.height) / 2
end

function Sprite:addOffset(anim, x,y)
    if self._animations and self._animations[anim] then
        self.animationOffset[anim] = {x=x,y=y}
    end
end

function Sprite:getScreenPosition(c)
    local tx, ty = 0, 0
    if c then
        tx, ty = c:getPosition(0,0)
        tx, ty = tx * self.scrollFactor.x, ty * self.scrollFactor.y
    end
    return self.x + tx, self.y + ty
end

function Sprite:getMidpoint()
    return {x=self.x+self.width/2, y=self.y+self.height/2}
end

function Sprite:getGraphicMidpoint()
    return {x=self.x+self:getFrameWidth()/2, y=self.y+self:getFrameHeight()/2}
end

function Sprite:setScrollFactor(x1,x2)
    local x1 = x1 or 1
    local x2 = x2 or x1
    self.scrollFactor.x = x1
    self.scrollFactor.y = x2
end

function Sprite:addAnimByPrefix(n, p, fr, l)
    local fr = fr or 24
    local l = l or false

    local a = {name=n, framerate=fr, looped=l, frames={}}
    for i, frame in ipairs(self._frames) do
        if util.startsWith(frame.name, p) then
            table.insert(a.frames, frame)
        end
    end

    if not self._animations then self._animations = {} end
    pcall(
        function()
            self._animations[n] = a
            self.animationOffset[n] = {x=0, y=0}
        end
    )
end

function Sprite:addAnimByIndices(n, p, i, fr, l)
    local fr = fr or 24
    local l = l or false

    local a = {name=n, framerate=fr, looped=l, frames={}}
    local subEnd = #p + 1
    for _i, indice in ipairs(i) do
        for _i2, frame in ipairs(self._frames) do
            if util.startsWith(frame.name, p) and tonumber(string.sub(frame.name, subEnd)) == indice then
                table.insert(a.frames, frame)
                break
            end
        end
    end

    if not self._animations then self._animations = {} end
    self._animations[n] = a
    self.animationOffset[n] = {x=0, y=0}
end

function Sprite:animate(anim, force, callback)
    if not force and self.curAnim and self.curAnim.name == anim and not self.animFinished then
        self.animFinished = false
        return
    end

    self.animCallback = callback
    self.curAnim = self._animations[anim]
    self.curFrame = 1
    self.animFinished = false
end

Sprite.play = Sprite.animate -- Incase users wan't to use a function more haxeflixel-like

function Sprite:screenCenter(ax)
    if ax == nil then ax = "xy" end
    if ax:find("x") then
        self.x = (1280 - self.width) / 2
    end
    if ax:find("y") then
        self.y = (720 - self.height) / 2
    end
    return self
end

function Sprite:update(dt)
    if self.curAnim and not self.animFinished then
        self.curFrame = self.curFrame + self.curAnim.framerate * dt
        if self.curFrame >= #self.curAnim.frames then
            if self.animCallback then
                self.animCallback()
            end
            if self.curAnim.looped then
                self.curFrame = 1
            else
                self.curFrame = #self.curAnim.frames
                self.animFinished = true
            end
        end
    end
end

function Sprite:isAnimName(name)
    -- check if name is a valid animation name
    return self._animations and self._animations[name] ~= nil
end

function Sprite:getAnimName()
    if self.curAnim then
        return self.curAnim.name
    end
    return nil
end

function Sprite:beat(beat)
    local beat = math.floor(beat) or 0
    local curAnimName = self:getAnimName()
    if not curAnimName then return end
    if beatHandler.onBeat() then
        if self:isAnimName("idle") then
            if (not self:isAnimated() and util.startsWith(self:getAnimName(), "sing")) or (self:getAnimName() == "idle" or self:getAnimName() == "idle loop") then
                if self.lastHit ~= nil and self.lastHit > 0 then
                    if beat % 2 == 0 and self.lastHit + beatHandler.stepCrochet * self.singDuration <= musicTime then
                        self:animate("idle", true)
                    end
                elseif beat % 2 == 0 then
                    self:animate("idle", true)
                end
            end
        else
            if beat % 1 == 0 then
                if (not self:isAnimated() and util.startsWith(self:getAnimName(), "sing")) or (self:getAnimName() == "danceLeft" or self:getAnimName() == "danceRight" or (not self:isAnimated() and self:getAnimName() == "sad")) then
                    self.danced = not self.danced or false
                    if self.danced then
                        self:animate("danceLeft", true)
                    else
                        self:animate("danceRight", true)
                    end
                end
            end
        end
    end
end

function Sprite:isAnimated()
    return not self.animFinished
end

function Sprite:makeGraphic(w, h, c)
    self.tex = love.graphics.newCanvas(w, h)
    self.color = hex2rgb(c) or {255, 255, 255}
    self.alpha = 1
    self.tex:renderTo(function()
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.alpha)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end)
    self.width = w
    self.height = h
    self.isGraphic = true
end

function Sprite:gridOverlay(cellWidth, cellHeight, width, height, alternate, color1, color2)
    local width = width or -1
    local height = height or -1
    local alternate = (alternate == nil and true) or alternate
    local color1 = color1 or "E6E6E6"
    local color2 = color2 or "FBFBFB"

    if width == -1 then
        width = graphics.getWidth()
    end
    if height == -1 then
        height = graphics.getHeight()
    end

    if width < cellWidth or height < cellHeight then
        return
    end

    self.tex = self:createGrid(cellWidth, cellHeight, width, height, alternate, color1, color2)
    self.width = width
    self.height = height
end

function Sprite:createGrid(cellWidth, cellHeight, width, height, alternate, color1, color2)
    local rowColor = color1
    local lastColor = color1
    local grid = love.graphics.newCanvas(width, height)
    self.rects = {
        -- stored as {x,y,w,h,color}
    }

    local y = 0
    while y <= height do
        if y > 0 and lastColor == rowColor and alternate then
            lastColor = lastColor == color1 and color2 or color1
        elseif y > 0 and lastColor ~= rowColor and not alternate then
            lastColor = lastColor == color2 and color1 or color2
        end

        local x = 0
        while x <= width do
            if x == 0 then
                rowColor = lastColor
            end

            table.insert(self.rects, {x=x, y=y, w=cellWidth, h=cellHeight, color=lastColor})

            if lastColor == color1 then
                lastColor = color2
            else
                lastColor = color1
            end

            x = x + cellWidth
        end

        y = y + cellHeight
    end

    -- make a renderTo function to draw the rects
    grid:renderTo(function()
        for i, rect in ipairs(self.rects) do
            love.graphics.setColor(hex2rgb(rect.color))
            love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end)

    return grid
end

function Sprite:draw()
    if self.tex and (self.alpha > 0 or self.scale.x ~= 0 or self.scale.y ~= 0) then
        local cam = self.camera or Sprite.defaultCam
        local x, y = self:getScreenPosition(cam)
        local f, r, sx, sy, ox, oy, kx, ky = self:getFrame(), self.angle, self.scale.x, self.scale.y, self.offset.x, self.offset.y, self.shear.x, self.shear.y

        if type(self.color) == "number" then self.color = hex2rgb(self.color) end
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.alpha)

        local min, mag, anisotropy = self.tex:getFilter()
        local mode = self.antialiasing and "linear" or "nearest"
        self.tex:setFilter(mode, mode, anisotropy)

        if cam then cam:attach() end

        if self.flipX then sx = -sx end
        if self.flipY then sy = -sy end

        x, y = x + ox - self.offset.x, y + oy - self.offset.y

        if f then
            ox, oy = ox + f.offset.x, oy + f.offset.y
        end

        if self.curAnim then
            ox = ox + self.animationOffset[self.curAnim.name].x
            oy = oy + self.animationOffset[self.curAnim.name].y
        end

        if self.clipRect then
            stencilS, stencilX, stencilY = self, x, y
            love.graphics.stencil(_stencil, "replace", 1)
            love.graphics.setStencilTest("greater", 0)
        end

        if not f then
            love.graphics.draw(self.tex, x - (self.isGraphic and 75 or 0), y - (self.isGraphic and 40 or 0), r, sx, sy, ox, oy, kx, ky)
        else
            love.graphics.draw(self.tex, f.quad, x, y, r, sx, sy, ox, oy, kx, ky)
        end

        if cam then cam:detach() end

        if self.clipRect then
            love.graphics.setStencilTest()
        end

        love.graphics.setColor(1,1,1)

        self.tex:setFilter(min, mag, anisotropy)
    end
end

function Sprite:destroy()
    self.tex = nil
    self.origin.x, self.origin.y = 0, 0
    self.offset.x, self.offset.y = 0, 0
    self.scale.x, self.scale.y = 1, 1

    self._frames = nil
    self._animations = nil

    self.curAnim = nil
    self.curFrame = 1
    self.animFinished = false
end

return Sprite