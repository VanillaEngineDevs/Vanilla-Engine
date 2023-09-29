local HealthBar = Group:extend()

HealthBar.leftBar = nil
HealthBar.rightBar = nil
HealthBar.bg = nil
HealthBar.valueFunction = function() return 0 end
HealthBar.percent = 0
HealthBar.bounds = {min=0, max=1}
HealthBar.leftToRight = true
HealthBar.barCenter = 0

HealthBar.barWidth = 1
HealthBar.barHeight = 1
HealthBar.barOffset = {x=3, y=3}

HealthBar.x, HealthBar.y = 0, 0

function HealthBar:new(x, y, image, valueFunction, boundX, boundY)
    self.x, self.y = x or 0, y or 0
    self.super.new(self)

    self.bg = Sprite(0, 0)
    self.bg:load(image)
    self.barWidth = math.floor(self.bg.width - 6)
    self.barHeight = math.floor(self.bg.height - 6)

    self.leftBar = Sprite()
    self.leftBar:makeGraphic(math.floor(self.bg.width), math.floor(self.bg.height), hexToColor(0xFFFFFFFF))

    self.rightBar = Sprite()
    self.rightBar:makeGraphic(math.floor(self.bg.width), math.floor(self.bg.height), hexToColor(0x00000000))

    self.valueFunction = valueFunction or function() return 0 end
    self.percent = 0
    self.bounds = {min=0, max=1}
    self.leftToRight = true
    self.barCenter = 0
    
    self.barOffset = {x=3, y=3}

    self.bounds = {min=boundX or 0, max=boundY or 1}

    self:add(self.leftBar)
    self:add(self.rightBar)
    self:add(self.bg)
    self:regenerateClips()
end

function HealthBar:update(dt)
    self.super.update(self, dt)
    -- get the value then convert it to a percentage (0-1), then, make it to 0-100
    local value = self.valueFunction()
    value = math.bound(value, self.bounds.min, self.bounds.max)
    value = math.remapToRange(value, self.bounds.min, self.bounds.max, 0, 100)

    self.percent = value and value or 0
    --print(self.percent)

    self:updateBar()
end

function HealthBar:screenCenter(axis)
    local axis = axis or "XY"

    if axis:find("X") then
        self.x = (push:getWidth() / 2) - (self.bg.width / 2)
    end
    if axis:find("Y") then
        self.y = (push:getHeight() / 2) - (self.bg.height / 2)
    end
end

function HealthBar:setColors(left, right)
    self.leftBar.color = left
    self.rightBar.color = right
end

function HealthBar:updateBar()
    if not self.leftBar or not self.rightBar then return end

    self.leftBar.x, self.leftBar.y = self.bg.x, self.bg.y
    self.rightBar.x, self.rightBar.y = self.bg.x, self.bg.y

    local leftSize = 0
    if self.leftToRight then
        -- if at 50%, its half the bar
        leftSize = math.floor(self.percent / 100 * self.barWidth)
    else
        leftSize = math.floor((100 - self.percent) / 100 * self.barWidth/0.9)
    end

    self.leftBar.clipRect.width = leftSize
    self.leftBar.clipRect.height = self.barHeight
    self.leftBar.clipRect.x = self.barOffset.x
    self.leftBar.clipRect.y = self.barOffset.y

    self.rightBar.clipRect.width = self.barWidth - leftSize
    self.rightBar.clipRect.height = self.barHeight
    self.rightBar.clipRect.x = self.barOffset.x + leftSize
    self.rightBar.clipRect.y = self.barOffset.y
end

function HealthBar:regenerateClips()
    if self.leftBar then
        self.leftBar:setGraphicSize(math.floor(self.bg.width), math.floor(self.bg.height))
        self.leftBar:updateHitbox()
        self.leftBar.clipRect = {x=0,y=0,width=math.floor(self.bg.width),height=math.floor(self.bg.height)}
    end

    if self.rightBar then
        self.rightBar:setGraphicSize(math.floor(self.bg.width), math.floor(self.bg.height))
        self.rightBar:updateHitbox()
        self.rightBar.clipRect = {x=0,y=0,width=math.floor(self.bg.width),height=math.floor(self.bg.height)}
    end

    self:updateBar()
end

function HealthBar:draw()
    love.graphics.push()
        love.graphics.translate(self.x, self.y)
        self.super.draw(self)
    love.graphics.pop()
end

return HealthBar