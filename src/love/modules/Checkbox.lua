local Checkbox = Sprite:extend()

Checkbox.sprTracker = nil
Checkbox.daValue = false
Checkbox.copyAlpha = true
Checkbox.offsetX = 0
Checkbox.offsetY = 0

function Checkbox:new(x,y,checked)
    self.super.new(self, x, y)
    self:setFrames(getSparrow(graphics.imagePath("menu/checkboxanim")))
    self:addAnimByPrefix("unchecked", "checkbox0", 24, false)
    self:addAnimByPrefix("unchecking", "checkbox anim reverse", 24, false)
    self:addAnimByPrefix("checking", "checkbox anim0", 24, false)
    self:addAnimByPrefix("checked", "checkbox finish", 24, false)

    self:play("unchecked", true)

    self:setGraphicSize(math.floor(0.9 * self.width))

    self:set_daValue(checked)

    return self
end

function Checkbox:update(dt)
    self.super.update(self, dt)

    -- move to target position
    if self.sprTracker then
        self.x = self.sprTracker.x - 65
        self.y = self.sprTracker.y - 75
    end
end

function Checkbox:set_daValue(check)
    if check then
        if self.curAnim.name ~= "checked" and self.curAnim.name ~= "checking" then
            self:play("checking", true, function()
                self:animFinishedCallback("checking")
            end)
            self.offset.x = 34
            self.offset.y = 25
        end
    elseif self.curAnim.name ~= "unchecked" and self.curAnim.name ~= "unchecking" then
        self:play("unchecking", true, function()
            self:animFinishedCallback("unchecking")
        end)
        self.offset.x = 25
        self.offset.y = 28
    end

    return self.daValue
end

function Checkbox:animFinishedCallback(name)
    if name == "checking" then
        self:play("checked", true)
        self.offset.x = 3
        self.offset.y = 12
    elseif name == "unchecking" then
        self:play("unchecked", true)
        self.offset.x = 0
        self.offset.y = 2
    end
end

return Checkbox