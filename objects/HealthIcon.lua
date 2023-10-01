local HealthIcon = Sprite:extend()

HealthIcon.sprTracker = nil
HealthIcon.isOldIcon = false
HealthIcon.isPlayer = false
HealthIcon.char = ""
HealthIcon.iconOffsets = {0, 0}

function HealthIcon:new(char, isPlayer)
    local char = char or "bf"
    local isPlayer = isPlayer or false
    
    self.super.new(self)
    self.sprTracker = nil
    self.isOldIcon = char == "bf-old"
    self.isPlayer = isPlayer
    self.char = char
    self.iconOffsets = {0, 0}
    self:changeIcon(char)

    self.flipX = self.isPlayer
end

function HealthIcon:update(dt)
    self.super.update(self, dt)
    
    if self.sprTracker then
        self.x, self.y = self.sprTracker.x + self.sprTracker.width + 12, self.sprTracker.y - 30
    end
end

function HealthIcon:changeIcon(char)
    local name = "icons/icon-" .. char

    local graphic = Paths.image(name)
    self:load(graphic, true, math.floor(graphic:getWidth()/2), math.floor(graphic:getHeight()))
    self.iconOffsets[1] = (self.width - 150)/2
    self.iconOffsets[2] = (self.height - 150)/2
    self:updateHitbox()

    self:addByTiles(char, {1, 2}, 0, false, isPlayer)
    self:play(char)
    
    if char:endsWith("pixel") then
        self.antialiasing = false
    end
end

function HealthIcon:updateHitbox()
    self.super.updateHitbox(self)
    self.offset.x = self.iconOffsets[1]
    self.offset.y = self.iconOffsets[2]
end

function HealthIcon:getCharacter()
    return self.char
end

return HealthIcon