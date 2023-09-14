local symbols = {"!", "?", ".", ",", "'", "-", "(", ")", ":", ";", "/", "&", "+", "=", "_", "<", ">", "[", "]", "{", "}", "#", "$", "%", "@", "*"}

function CreateText(text, isBold)
    local isLowercase = false
    local isNumber = false
    local o = {
        x = 0,
        y = 0,
        text = {},
        size = 1,
        string = text,
        alpha = 1,
        width = 0,
        height = 0,
        isMenuItem = false,
        changeX = true,
        changeY = true,

        attached = false,
        offsetX = 0,
        offsetY = 0,
        sprTracker = nil,
        copyVisible = true,
        copyAlpha = false,
        
        distancePerItem = {x=20,y=120},
        startPosition = {x=0,y=0},

        setup = function(self, text, isBold)
            self.text = {}
            for i = 1, #text do
                local char = text:sub(i, i)
                local lastWasSpace = text:sub(i-1, i-1) == " "
                -- is letter uppercase?
                isLowercase = char:lower() == char
                -- is letter a number?
                isNumber = tonumber(char) ~= nil
                char = char:lower()

                if char ~= " " then
                    table.insert(self.text, Sprite())
                    self.text[#self.text]:setFrames(getSparrow(graphics.imagePath("alphabet")))
                    -- check if its isNumber or in symbols
                    if not isNumber and not table.contains(symbols, char) then
                        self.text[#self.text]:addAnimByPrefix("anim", char .. (isBold and " bold" or (isLowercase and " lowercase" or " uppercase")), 24, true)
                    else
                        if char == "<" then char = "left" end
                        if char == ">" then char = "right" end
                        if char == "." then char = "period" end
                        self.text[#self.text]:addAnimByPrefix("anim", char .. (isBold and " bold" or " normal"), 24, true)
                    end
                    self.text[#self.text]:play("anim", true)
                    self.text[#self.text]:updateHitbox()
                    if lastWasSpace then self.text[#self.text].x = self.text[#self.text].x + 20 end
                    self.text[#self.text].x = self.text[#self.text].x + (
                        self.text[#self.text-1] and self.text[#self.text-1].x + self.text[#self.text-1].width or 57
                    ) + 3
                    self.text[#self.text].y = -self.text[#self.text].height
                end
            end

            self.width = self.text[#self.text].x + self.text[#self.text].width
            self.height = self.text[#self.text].height

            self.startPosition.x = self.x 
            self.startPosition.y = self.y
        end,

        updateText = function(self, text, isBold)
            self:setup(text, isBold)
        end,

        setScale = function(self, scale)
            self.size = scale
        end,

        screenCenter = function(self, axis)
            local axis = axis or "XY"
            if axis:find("X") then
                self.x = push:getWidth()/2 - self.text[#self.text].x/2
            end
            if axis:find("Y") then
                self.y = push:getHeight()/2 - self.text[#self.text].y/2
            end
        end,

        update = function(self, dt)
            for i, char in ipairs(self.text) do
                char:update(dt)
            end
            if self.isMenuItem then
                local lerpVal = util.bound(dt * 9.6, 0, 1)
                if self.changeX then
                    self.x = util.lerp(self.x, (self.targetY * self.distancePerItem.x) + self.startPosition.x, lerpVal)
                end
                if self.changeY then
                    self.y = util.lerp(self.y, (self.targetY * 1.3 * self.distancePerItem.y) + self.startPosition.y, lerpVal)
                end
            end

            if self.attached then
                if self.sprTracker ~= nil then
                    self.x, self.y = self.sprTracker.x + self.offsetX, self.sprTracker.y + self.offsetY
                    if self.copyVisible then
                        self.visible = self.sprTracker.visible
                    end
                    if self.copyAlpha then
                        self.alpha = self.sprTracker.alpha
                    end
                end
            end
        end,

        draw = function(self)
            love.graphics.push()
            love.graphics.translate(self.x, self.y)
            love.graphics.scale(self.size, self.size)
            for i, char in ipairs(self.text) do
                char.alpha = self.alpha
                char:draw()
            end
            love.graphics.pop()
        end
    }
    o:setup(text, isBold)
    return o
end