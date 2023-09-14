local OptionsMenu = Object:extend()

OptionsMenu.curOption = nil
OptionsMenu.curSelected = 1
OptionsMenu.list = {}

OptionsMenu.grpOptions = Group()
OptionsMenu.checkboxGroup = Group()
OptionsMenu.grpTexts = Group()

OptionsMenu.group = Group()

OptionsMenu.title = ""

function OptionsMenu:enter()
    if self.title == "" then self.title = "Options" end
    bg = Sprite():load(graphics.imagePath("menu/menuDesat"))
    bg.color = 0xFFea71fd
    bg:screenCenter()
    self.group:add(bg)

    self.group:add(self.grpOptions)
    self.group:add(self.grpTexts)
    self.group:add(self.checkboxGroup)
    
    descBox = {
        col = hex2rgb(0xFF000000),
        alpha = 0.6,
        width = 0,
        height = 0,
        x = 0,
        y = 0,
        ox = 0, oy = 0,

        draw = function(self)
            love.graphics.setColor(self.col[1], self.col[2], self.col[3], self.alpha)
            love.graphics.rectangle("fill", self.x + self.ox, self.y + self.oy, self.width, self.height)
        end,

        setGraphicSize = function(self, width, height)
            self.width = width
            self.height = height
        end,
    }
    self.group:add(descBox)

    titleText = CreateText(self.title, true)
    titleText.x, titleText.y = 38, 90
    titleText:setScale(0.6)
    titleText.alpha = 0.4
    self.group:add(titleText)

    descText = {
        x=50,y=600,limit=1180,text="",size=32,
        font=optionsFont,color=0xFFFFFFFF,align="center",
        border="outline",borderColor=0xFF000000,borderSize=4.8,
        width = 0, height = 0,
        setup = function(self, text)
            self.text = text
            self.width = self.font:getWidth(self.text)
            --self.height = self.font:getHeight(self.text)
            -- since limit is 1180 pixels, determine the real height
            self.height = self.font:getHeight(self.text, self.limit)
            local lines = math.floor(self.width / self.limit)
            self.height = self.height * (lines+1)
        end,
        update = function(self, dt)
            self.width = self.font:getWidth(self.text)
            --self.height = self.font:getHeight(self.text)
        end,

        screenCenter = function(self, axis)
            local axis = axis or "XY"
            local width = font:getWidth(self.text)
            local height = font:getHeight(self.text)
            if axis:find("X") then
                self.x = push:getWidth()/2 - width/2
            end
            if axis:find("Y") then
                self.y = push:getHeight()/2 - height/2
            end
        end,

        draw = function(self)
            love.graphics.push()
            love.graphics.setFont(self.font)
            love.graphics.setColor(hex2rgb(self.borderColor))
            love.graphics.printf(self.text, self.x-self.borderSize/2, self.y-self.borderSize/2, self.limit, self.align)
            love.graphics.printf(self.text, self.x+self.borderSize/2, self.y-self.borderSize/2, self.limit, self.align)
            love.graphics.printf(self.text, self.x-self.borderSize/2, self.y+self.borderSize/2, self.limit, self.align)
            love.graphics.printf(self.text, self.x+self.borderSize/2, self.y+self.borderSize/2, self.limit, self.align)
            love.graphics.printf(self.text, self.x+self.borderSize/2, self.y, self.limit, self.align)
            love.graphics.printf(self.text, self.x-self.borderSize/2, self.y, self.limit, self.align)
            love.graphics.printf(self.text, self.x, self.y+self.borderSize/2, self.limit, self.align)
            love.graphics.printf(self.text, self.x, self.y-self.borderSize/2, self.limit, self.align)
            love.graphics.setColor(hex2rgb(self.color))
            love.graphics.printf(self.text, self.x, self.y, self.limit, self.align)
            love.graphics.pop()
        end
    }
    self.group:add(descText)

    for i = 1, #self.optionsArray do
        local optionText = CreateText(self.optionsArray[i].name, false)
        optionText.startPosition.x, optionText.startPosition.y = 200, 350
        optionText.isMenuItem = true
        optionText.targetY = i-1
        self.grpOptions:add(optionText)

        if self.optionsArray[i].type == "bool" then
            local checkbox = Checkbox(optionText.x + optionText.startPosition.x - 105, optionText.y + optionText.startPosition.y - 75, self.optionsArray[i]:getValue() == true)
            checkbox.sprTracker = optionText
            checkbox.ID = i
            self.checkboxGroup:add(checkbox)
        else
            optionText.x = optionText.x - 80
            optionText.startPosition.x = optionText.startPosition.x - 80
            local valueText = CreateText(tostring(self.optionsArray[i]:getValue()), false)
            valueText.attached = true
            valueText.offsetX = optionText.width + 60
            valueText.sprTracker = optionText
            valueText.copyAlpha = true
            valueText.ID = i
            self.grpTexts:add(valueText)
            self.optionsArray[i].child = valueText
        end
        self:updateTextFrom(self.optionsArray[i])
    end

    self:changeSelection()
    self:reloadCheckboxes()
end

OptionsMenu.nextAccept = 0
OptionsMenu.holdTime = 0
OptionsMenu.holdValue = 0

function OptionsMenu:addOption(option)
    if self.optionsArray == nil or #self.optionsArray < 1 then
        self.optionsArray = {}
    end
    table.insert(self.optionsArray, option)
end

function OptionsMenu:reloadCheckboxes()
    for i, checkbox in ipairs(self.checkboxGroup.members) do
        --checkbox.daValue = (self.optionsArray[checkbox.ID]:getValue() == true)
        checkbox:set_daValue(self.optionsArray[checkbox.ID]:getValue() == true)
    end
end

function OptionsMenu:update(dt)
    local usesCheckbox 
    self.group:update(dt)

    if input:pressed("up") then
        self:changeSelection(-1)
    elseif input:pressed("down") then
        self:changeSelection(1)
    end

    if input:pressed("back") then
        Gamestate.pop()
    end

    if self.nextAccept <= 0 then
        usesCheckbox = true
        if self.curOption.type ~= "bool" then
            usesCheckbox = false
        end

        if usesCheckbox then
            if input:pressed("confirm") then
                self.nextAccept = 1

                audio.playSound(confirmSound)
                self.curOption:setValue(not self.curOption:getValue())
                self:reloadCheckboxes()
            end
        end
    end

    if not usesCheckbox then
        local pressed = (input:pressed("left") or input:pressed("right"))
        local holdValue = 0
        if self.holdTime > 0.5 or pressed then
            if pressed and self.curOption.type ~= "bool" then
                local add = nil
                if self.curOption.type ~= "string" then
                    add = input:pressed("left") and -self.curOption.changeValue or self.curOption.changeValue
                end

                if self.curOption.type ~= "string" then
                    if self.curOption.type == "float" or self.curOption.type == "percent" then
                        local new = self.curOption:getValue() + add
                        self.curOption:setValue(math.roundDecimal(new, self.curOption.decimals))
                        if self.curOption:getValue() < self.curOption.minValue then self.curOption:setValue(self.curOption.minValue) end
                        if self.curOption:getValue() > self.curOption.maxValue then self.curOption:setValue(self.curOption.maxValue) end
                    elseif self.curOption.type == "number" then
                        self.curOption:setValue(util.round(self.curOption:getValue() + add))
                        if self.curOption:getValue() < self.curOption.minValue then self.curOption:setValue(self.curOption.minValue) end
                        if self.curOption:getValue() > self.curOption.maxValue then self.curOption:setValue(self.curOption.maxValue) end
                    end
                else
                    local num = self.curOption.curOption
                    if input:pressed("left") then num = num - 1 
                    else num = num + 1 end

                    if num < 1 then num = #self.curOption.options end
                    if num > #self.curOption.options then num = 1 end
                    
                    self.curOption.curOption = num
                    self.curOption:setValue(self.curOption.options[num])
                end

                self:updateTextFrom(self.curOption)
            elseif self.curOption.type ~= "string" and self.curOption.type ~= "bool" then
                local add = input:down("left") and -self.curOption.changeValue or self.curOption.changeValue
                if self.curOption.type == "number" then
                    self.curOption:setValue(util.round(self.curOption:getValue() + add))
                    if self.curOption:getValue() < self.curOption.minValue then self.curOption:setValue(self.curOption.minValue) end
                    if self.curOption:getValue() > self.curOption.maxValue then self.curOption:setValue(self.curOption.maxValue) end
                elseif self.curOption.type == "float" or self.curOption.type == "percent" then
                    self.curOption:setValue(math.roundDecimal(self.curOption:getValue() + add, self.curOption.decimals))
                    if self.curOption:getValue() < self.curOption.minValue then self.curOption:setValue(self.curOption.minValue) end
                    if self.curOption:getValue() > self.curOption.maxValue then self.curOption:setValue(self.curOption.maxValue) end
                end

                self:updateTextFrom(self.curOption)
            end
        end

        if input:down("left") or input:down("right") then
            self.holdTime = self.holdTime + dt
        else
            self.holdTime = 0
        end
    end

    self.nextAccept = self.nextAccept - dt
end

function OptionsMenu:changeSelection(change)
    local change = change or 0
    self.curSelected = self.curSelected + change

    if self.curSelected < 1 then
        self.curSelected = #self.optionsArray
    end
    if self.curSelected > #self.optionsArray then
        self.curSelected = 1
    end

    descText.text = self.optionsArray[self.curSelected].description
    descText:screenCenter("Y")
    descText.y = descText.y + 270

    local bullshit = 1

    for i, item in ipairs(self.grpOptions.members) do
        item.targetY = bullshit - self.curSelected
        bullshit = bullshit + 1

        item.alpha = 0.6
        if item.targetY == 0 then
            item.alpha = 1
        end
    end

    for i, text in ipairs(self.grpTexts.members) do
        text.alpha = 0.6
        if i == self.curSelected then
            text.alpha = 1
        end
    end

    descText:setup(descText.text)
    descBox.x = 50
    descBox.y = 608
    descBox:setGraphicSize(1180, math.floor(descText.height+25))

    self.curOption = self.optionsArray[self.curSelected]
    audio.playSound(selectSound)
end

function OptionsMenu:updateTextFrom(option)
    local string = option.displayFormat
    local val = tostring(option:getValue())
    if option.type == "percent" then val = val * 100 end
    local def = tostring(option.defaultValue)
    local str = string.gsub(string, "%%v", val)
    str = string.gsub(str, "%%d", def)
    if option.type == "percent" then str = str .. "%" end
    if option.child then
        option.child:updateText(str, false)
    end
end

function OptionsMenu:draw()
    self.group:draw()
end

function OptionsMenu:leave()
    self.group:clear()
    self.grpOptions:clear()
    self.grpTexts:clear()
    self.checkboxGroup:clear()
    self.optionsArray = {}
end

return OptionsMenu