local Sprite = Object:extend()

Sprite.defaultAntialiasing = true

Sprite.frame = 1
Sprite.frameWidth = 0
Sprite.frameHeight = 0
Sprite.frames = nil

Sprite.graphic = nil
Sprite.alpha = 1.0

Sprite.flipX, Sprite.flipY = false, false

Sprite.origin = {x = 0, y = 0}
Sprite.offset = {x = 0, y = 0}
Sprite.scale = {x = 1, y = 1}
Sprite.shear = {x = 0, y = 0}

Sprite.blend = "alpha"

Sprite.color = {1, 1, 1}

Sprite.clipRect = nil
Sprite.shader = nil

Sprite.x, Sprite.y = 0, 0
Sprite.width, Sprite.height = 0, 0

Sprite.Stencil = {
    sprite = {},
    x = 0,
    y = 0,
    func = function(self)
        if Sprite.Stencil.sprite then
            love.graphics.push()
                love.graphics.translate(Sprite.Stencil.x + Sprite.Stencil.clipRect.x + Sprite.Stencil.clipRect.width / 2, Sprite.Stencil.y + Sprite.Stencil.clipRect.y + Sprite.Stencil.clipRect.height / 2)
                love.graphics.rotate(math.rad(Sprite.Stencil.angle or 0))
                love.graphics.translate(-Sprite.Stencil.clipRect.width / 2, -Sprite.Stencil.clipRect.height / 2)
                love.graphics.rectangle("fill", -Sprite.Stencil.clipRect.width /2, -Sprite.Stencil.clipRect.height / 2, Sprite.Stencil.clipRect.width, Sprite.Stencil.clipRect.height)
            love.graphics.pop()
        end
    end
}

function Sprite.NewFrame(name, x,y,w,h,sw,sh,ox,oy,ow,oh)
    local aw, ah = x + w, y + h

    local frame = {}
    frame.name = name
    frame.quad = love.graphics.newQuad(x,y, aw > sw and w - (aw - sw) or w, ah > sh and h - (ah - sh) or h, sw, sh)
    frame.x, frame.y = x, y
    frame.width = ow or w
    frame.height = oh or h
    frame.offset = {x= ox or 0, y= oy or 0}

    return frame
end

function Sprite:new(x, y, graphic)
    self.x = x or 0
    self.y = y or 0

    self.graphic = nil
    self.width, self.height = 0, 0
    self.antialiasing = Sprite.defaultAntialiasing

    self.camera = nil

    self.alive, self.exists, self.visible = true, true, true

    self.origin = {x=0,y=0}
    self.offset = {x=0,y=0}
    self.scale = {x=1,y=1}
    self.shear = {x=0,y=0}

    self.scrollFactor = {x=1,y=1}

    self.clipRect = nil
    self.flipX, self.flipY = false, false

    self.alpha = 1
    self.color = {1,1,1}
    self.angle = 0

    self.shader = nil
    self.blend = "alpha"

    self.frames = nil
    self.animations = nil

    self.curAnim = nil
    self.curFrame = nil
    self.animFinished = nil

    if graphic then self:load(graphic) end
end

function Sprite:load(graphic)
    if type(graphic) == "string" then
        graphic = Paths.image(graphic)
    end
    self.graphic = graphic

    self.width = graphic:getWidth()
    self.height = graphic:getHeight()

    return self
end

function Sprite:setFrames(frames)
    self.frames = frames
    self.graphic = frames.graphic

    self:load(self.graphic)
    self.width, self.height = frames.frames[1].width, frames.frames[1].height
end

function Sprite:addByPrefix(animName, animPrefix, framerate, loop)
    framerate = framerate or 30
    loop = (loop == nil) and true or loop

    local anim = {}
    anim.name = animName
    anim.frames = {}
    anim.framerate = framerate
    anim.looped = loop

    for i, frame in ipairs(self.frames.frames) do
        if frame.name:startsWith(animPrefix) then
            table.insert(anim.frames, frame)
        end
    end

    if not self.animations then self.animations = {} end
    self.animations[animName] = anim
end

function Sprite:addByIndices(animName, animPrefix, indices, framerate, loop)
    framerate = framerate or 30
    loop = (loop == nil) and true or loop

    local anim = {}
    anim.name = animName
    anim.frames = {}
    anim.framerate = framerate
    anim.looped = loop

    for i, frame in ipairs(self.frames.frames) do
        if frame.name:startsWith(animPrefix) then
            for j, index in ipairs(indices) do
                if i == index then
                    table.insert(anim.frames, frame)
                end
            end
        end
    end

    if not self.animations then self.animations = {} end
    self.animations[animName] = anim
end

function Sprite:update(dt)
    if self.alive and self.exists and self.curAnim then
        self.curFrame = self.curFrame + dt * self.curAnim.framerate
        if self.curFrame >= #self.curAnim.frames then
            if self.curAnim.looped then
                self.curFrame = 1
            else
                self.curFrame = #self.curAnim.frames
                self.animFinished = true
            end
        end
    end
end

function Sprite:play(anim, force)
    if self.curAnim and self.curAnim.name == anim and not force then return end
    if self.animations and self.animations[anim] then
        self.curAnim = self.animations[anim]
        self.curFrame = 1
        self.animFinished = false
    end 
end

function Sprite:getCurrentFrame()
    if self.curAnim then
        return self.curAnim.frames[math.floor(self.curFrame)]
    elseif self.frames then
        return self.frames.frames[1]
    end
end

function Sprite:getFrameWidth()
    local frame = self:getCurrentFrame()
    if frame then return frame.width
    else return self.width end
end

function Sprite:getFrameHeight()
    local frame = self:getCurrentFrame()
    if frame then return frame.height
    else return self.height end
end

function Sprite:setGraphicSize(w, h)
    local w = w or 0
    local h = h or 0

    self.scale.x = w / self:getFrameWidth()
    self.scale.y = h / self:getFrameHeight()

    if w <= 0 then
        self.scale.x = self.scale.y
    elseif h <= 0 then
        self.scale.y = self.scale.x
    end
end

function Sprite:updateHitbox()
    local w, h = self:getFrameWidth(), self:getFrameHeight()

    self.width = math.abs(self.scale.x) * w
    self.height = math.abs(self.scale.y) * h

    self.offset = {x = -0.5 * (self.width - w), y = -0.5 * (self.height - h)}
    self:centerOrigin()
end

function Sprite:centerOffsets()
    self.offset.x, self.offset.y = (self:getFrameWidth() - self.width) / 2, (self:getFrameHeight() - self.height) / 2
end

function Sprite:centerOrigin()
    self.origin.x, self.origin.y = self:getFrameWidth() / 2, self:getFrameHeight() / 2
end

function Sprite:screenCenter(axis)
    axis = axis or "XY"
    if axis:find("X") then
        self.x = (push:getWidth() - self.width) / 2
    end
    if axis:find("Y") then
        self.y = (push:getHeight() - self.height) / 2
    end
end

function Sprite:draw()
    if self.exists and self.alive and self.visible and self.graphic then
        local frame = self.curAnim and self.curAnim.frames[math.floor(self.curFrame)] or nil
        if self.shader then
            love.graphics.setShader(self.shader)
        end
        love.graphics.setBlendMode(self.blend)

        if self.clipRect then
            love.graphics.setStencilTest("greater", 0)
        end

        local x, y = self.x, self.y
        local angle = math.rad(self.angle)
        local sx, sy = self.scale.x, self.scale.y
        local ox, oy = self.origin.x, self.origin.y

        if self.flipX then sx = -sx end
        if self.flipY then sy = -sy end

        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.alpha)

        x, y = x + ox - self.offset.x, y + oy - self.offset.y

        if frame then
            ox, oy = ox + frame.offset.x, oy + frame.offset.y
        end

        if self.clipRect then
            Sprite.Stencil = {
                sprite = self,
                x = x,
                y = y,
                clipRect = self.clipRect,
                func = Sprite.Stencil.func
            }
            love.graphics.stencil(Sprite.Stencil.func, "replace", 1, false)
        end

        if not frame then
            love.graphics.draw(self.graphic, x, y, angle, sx, sy, ox, oy, self.shear.x, self.shear.y)
        else
            --print('its over /b/ros....')
            love.graphics.draw(self.graphic, frame.quad, x, y, angle, sx, sy, ox, oy, self.shear.x, self.shear.y)
        end

        if self.clipRect then
            love.graphics.setStencilTest()
        end
        love.graphics.setColor(r, g, b, a)
        love.graphics.setBlendMode("alpha")
    end
end

return Sprite