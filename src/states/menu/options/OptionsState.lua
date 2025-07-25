local OptionsState = {}

OptionsState.options = {"Gamemodes", "Gameplay", "Graphics", "Controls", "Miscillaneous"}
if love.system.getOS() == "NX" then
    OptionsState.options = {"Gamemodes", "Gameplay", "Graphics", "Miscillaneous"}
end
OptionsState.grpOptions = Group()
OptionsState.curSelected = 1
OptionsState.menuBG = nil
OptionsState.onPlayState = false
OptionsState.group = Group()

OptionsState.selectorLeft = nil
OptionsState.selectorRight = nil

function OptionsState:enter()
    local bg = Sprite():load(graphics.imagePath("menu/menuDesat"))
    bg.color = 0xFFea71fd
    bg:updateHitbox()
    bg:screenCenter()
    self.group:add(bg)

    grpOptions = Group()
    self.group:add(grpOptions)

    for i = 1, #self.options do
        local optionText = CreateText(self.options[i], true)
        optionText:screenCenter()
        optionText.y = optionText.y + (100 * (i - (#self.options/2))) - 50
        optionText.x = optionText.x - 75
        self.grpOptions:add(optionText)
    end
    self.group:add(self.grpOptions)

    self.selectorLeft = CreateText(">", true)
    self.selectorRight = CreateText("<", true)
    self.group:add(self.selectorLeft)
    self.group:add(self.selectorRight)
    self:changeSelection()
end

function OptionsState:changeSelection(change)
    local change = change or 0
    
    self.curSelected = self.curSelected + change
    if self.curSelected < 1 then
        self.curSelected = #self.options
    end
    if self.curSelected > #self.options then
        self.curSelected = 1
    end

    local bullshit = 1

    for i, item in ipairs(self.grpOptions.members) do
        item.targetY = bullshit - self.curSelected
        bullshit = bullshit + 1

        item.alpha = 0.6
        if item.targetY == 0 then
            item.alpha = 1
            self.selectorLeft.x = item.x - 63
            self.selectorLeft.y = item.y
            self.selectorRight.x = item.x + item.width - 50
            self.selectorRight.y = item.y
        end
    end
    audio.playSound(selectSound)
end

function OptionsState:update(dt)
    self.group:update(dt)

    if not graphics.isFading() then
        if input:pressed("down") then
            self:changeSelection(1)
        elseif input:pressed("up") then
            self:changeSelection(-1)
        end
    
        if input:pressed("back") then
            Gamestate.switch(menuSelect)
        end
    
        if input:pressed("confirm") then
            Gamestate.push(optionSubstates[self.options[self.curSelected]])
        end
    end
end

function OptionsState:draw()
    self.group:draw()
end

function OptionsState:leave()
    self.group:clear()
    self.grpOptions:clear()

    saveSettings()
end

return OptionsState