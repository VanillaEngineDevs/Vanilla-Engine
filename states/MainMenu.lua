local MainMenuState = MusicBeatState:extend()

-- Simplicity
MainMenuState.members = {}
function MainMenuState:add(member)
    table.insert(self.members, member)
end

function MainMenuState:remove(member)
    for i, member in ipairs(self.members) do
        if member == member then
            table.remove(self.members, i)
            return
        end
    end
end

function MainMenuState:insert(position, member)
    table.insert(self.members, position, member)
end

function MainMenuState:clear()
    self.members = {}
end
--

MainMenuState.curSelected = 1
MainMenuState.menuItems = nil
MainMenuState.camGame = nil

MainMenuState.optionShit = {
    "story_mode",
    "freeplay",
    -- "mods", -- todo. psych engine mod folder support
    "credits",
    love.system.getOS() ~= "switch" and "donate" or nil,
    "options"
}

MainMenuState.magenta = nil
MainMenuState.camFollow = {x = 0, y = 0}

MainMenuState.selectedSomethin = false

function MainMenuState:enter()
    self.camGame = Camera()

    if not TitleState.music:isPlaying() then
        TitleState.music:play()
    end

    local yScroll = math.max(0.25 - (0.05 * (#self.optionShit - 4)), 0.1)
    self.bg = Sprite(-80, 0)
    self.bg:load("menu/menuBG")
    self.bg.scrollFactor = {x = 0, y = yScroll}
    self.bg:setGraphicSize(math.floor(self.bg.width * 1.175))
    self.bg:updateHitbox()
    self.bg:screenCenter()
    self:add(self.bg)

    self.camFollow = {x = 0, y = 0}

    self.magenta = Sprite(-80, 0)
    self.magenta:load("menu/menuDesat")
    self.magenta.scrollFactor = {x = 0, y = yScroll}
    self.magenta:setGraphicSize(math.floor(self.magenta.width * 1.175))
    self.magenta:updateHitbox()
    self.magenta:screenCenter()
    self.magenta.visible = false
    self.magenta.color = hexToColor(0xFFd719b)
    self:add(self.magenta)

    self.menuItems = Group()
    self:add(self.menuItems)

    local scale = 1

    for i = 1, #self.optionShit do
        local offset = 108 - (math.max(#self.optionShit, 4) - 4) * 80
        local menuItem = Sprite(0, ((i-1) * 140) + offset)
        menuItem.scale.x, menuItem.scale.y = scale, scale
        menuItem:setFrames(Paths.getAtlas("menu/menu_" .. self.optionShit[i], "assets/images/png/menu/menu_" .. self.optionShit[i] .. ".xml"))
        menuItem:addByPrefix("idle", self.optionShit[i] .. " basic", 24)
        menuItem:addByPrefix("selected", self.optionShit[i] .. " white", 24)
        menuItem:play("idle")
        menuItem.ID = i
        menuItem:screenCenter("X")
        menuItem.camera = self.camGame
        local scr = (#self.optionShit - 4) * 0.135
        if #self.optionShit < 5 then scr = 0 end
        menuItem.scrollFactor = {x = 0, y = scr}
        self.menuItems:add(menuItem)
    end

    self:changeItem()

    self.selectedSomethin = false

    self.super.enter(self)

    MusicBeatState:fadeIn(0.3)
end

function MainMenuState:changeItem(huh)
    local huh = huh or 0

    self.curSelected = self.curSelected + huh

    if self.curSelected > #self.menuItems.members then
        self.curSelected = 1
    elseif self.curSelected < 1 then
        self.curSelected = #self.menuItems.members
    end

    for i, item in ipairs(self.menuItems.members) do
        item:play("idle")
        item:centerOffsets()
        if item.ID == self.curSelected then
            item:play("selected")
            local add = 0
            if #self.menuItems.members > 4 then
                add = #self.menuItems.members * 8
            end
            self.camFollow.y = item:getMidpoint().y - add - 400
            item:centerOffsets()
        end
    end
end

function MainMenuState:update(dt)
    self.super.update(self, dt)
    Conductor.songPosition = Conductor.songPosition + 1000 * dt
    for i, member in ipairs(self.members) do
        if member.update then 
            member:update(dt) 
        end
    end

    -- set camgame position
    self.camGame.x = CoolUtil.coolLerp(self.camGame.x, self.camFollow.x, 10, dt)
    self.camGame.y = CoolUtil.coolLerp(self.camGame.y, self.camFollow.y, 10, dt)

    if not self.selectedSomethin then
        if input:pressed("m_down") then
            self:changeItem(1)
        elseif input:pressed("m_up") then
            self:changeItem(-1)
        end

        if input:pressed("m_back") then
            self.selectedSomethin = true
            MusicBeatState:fadeOut(0.3,
                function()
                    MusicBeatState:switchState(TitleState)
                end
            )
        elseif input:pressed("m_confirm") then
            if self.optionShit[self.curSelected] == "donate" then
                love.system.openURL("https://ninja-muffin24.itch.io/funkin")
            else
                self.selectedSomethin = true

                -- todo. flicker

                for i, item in ipairs(self.menuItems.members) do
                    if item.ID ~= self.curSelected then
                        Timer.tween(0.4, item, {alpha = 0}, "out-quad")
                    else
                        Timer.after(1, function()
                            -- todo. flicker
                            local daChoice = self.optionShit[self.curSelected]

                            if daChoice == "story_mode" then
                                MusicBeatState:fadeOut(0.3,
                                    function()
                                        MusicBeatState:switchState(StoryMenuState)
                                    end
                                )
                            elseif daChoice == "freeplay" then
                                -- FreeplayMenuState
                            elseif daChoice == "mods" then
                                -- ModsMenuState
                            elseif daChoice == "credits" then
                                -- CreditsState
                            elseif daChoice == "options" then
                                -- OptionsMenuState
                            end
                        end)
                    end
                end
            end
        end
    end
end

function MainMenuState:draw()
    love.graphics.push()
        -- gross........
        for i, member in ipairs(self.members) do
            if member.draw then 
                if member ~= self.menuItems then
                    if member.scrollFactor then
                        love.graphics.translate(self.camGame.x * member.scrollFactor.x, -self.camGame.y * member.scrollFactor.y)
                    end
                    member:draw() 
                    if member.scrollFactor then
                        love.graphics.translate(-self.camGame.x * member.scrollFactor.x, self.camGame.y * member.scrollFactor.y)
                    end
                else
                    for i2, item in ipairs(member.members) do
                        if item.scrollFactor then
                            love.graphics.translate(self.camGame.x * item.scrollFactor.x, -self.camGame.y * item.scrollFactor.y)
                        end
                        item:draw()
                        if item.scrollFactor then
                            love.graphics.translate(-self.camGame.x * item.scrollFactor.x, self.camGame.y * item.scrollFactor.y)
                        end
                    end
                end
            end
        end
    love.graphics.pop()
end

return MainMenuState