---@class MainMenuState : MusicBeatState
local MainMenuState = MusicBeatState:extend()
MainMenuState.overrideMusic = false

function MainMenuState:new(overrideMusic)
    self.overrideMusic = overrideMusic or false
    MusicBeatState.new(self)
end

function MainMenuState:create()
    -- todo: FunkinCamera
    --Game.cameras.reset(Funkincamera("mainMenu"))

    self.transIn = TransitionableState.defaultTransIn
    self.transOut = TransitionableState.defaultTransOut

    if not self.overrideMusic then
        self:playMenuMusic()
    end

    self.persistentDraw = true
    self.persistentUpdate = true

    local bg = Sprite(0, 0, Paths.image("menuBG"))
    bg.scrollFactor.x = 0
    bg.scrollFactor.y = 0.17
    bg:setGraphicSize(math.floor(bg.width * 1.2))
    bg:updateHitbox()
    bg:screenCenter()
    self:add(bg)

    self.camFollow = Object(0, 0, 1, 1)
    self:add(self.camFollow)

    self.magenta = Sprite(0, 0, Paths.image("menuDesat"))
    -- TODO: colour
    self.magenta.scrollFactor.x = bg.scrollFactor.x
    self.magenta.scrollFactor.y = bg.scrollFactor.y
    self.magenta:setGraphicSize(math.floor(bg.width))
    self.magenta:updateHitbox()
    self.magenta.x = bg.x
    self.magenta.y = bg.y
    self.magenta.visible = false

    self:add(self.magenta)

    self.menuItems = MenuTypedList(AtlasMenuItem)
    self:add(self.menuItems)
    self.menuItems.onChange:add(self.onMenuItemChange)
    self.menuItems.onAcceptPress:add(function(_)
        --Flicker
    end)

    self.menuItems.enabled = true

    self:createMenuItem("storymode", "mainmenu/storymode", function()
        self:startExitState(StoryMenuState)
    end)

    self:createMenuItem("freeplay", "mainmenu/freeplay", function()
    
    end)

    self:createMenuItem("merch", "mainmenu/merch", function()
    
    end, love.system.getOS() ~= "Web")

    self:createMenuItem("options", "mainmenu/options", function()
    
    end)

    self:createMenuItem("credits", "mainmenu/credits", function()
        love.event.quit()
    end)

    local spacing = 160
    local top = (Game.height - (spacing * (self.menuItems.length - 1))) / 2
    for i = 1, self.menuItems.length do
        local menuItem = self.menuItems.members[i]
        menuItem.x = Game.width / 2
        menuItem.y = top + spacing * (i - 1)
        menuItem.scrollFactor.x = 0
        menuItem.scrollFactor.y = 0.4
    end

    self.menuItems:selectItem(0)

    MusicBeatState.create(self)
end

function MainMenuState:playMenuMusic()
    FunkinSound:playMusic("freakyMenu", {
        persist = true,
        overrideExisting = true,
        restartTrack = false
    })
end

function MainMenuState:createMenuItem(name, atlas, callback, fireInstantly)
    local item = AtlasMenuItem(0, 0, name, Paths.getSparrowAtlas(atlas), callback)
    item.fireInstantly = fireInstantly
    item.ID = self.menuItems.length
    item.scrollFactor:set()

    item.centered = true
    item:changeAnim("idle")

    self.menuItems:addItem(name, item)
end

function MainMenuState:update(dt)
    MusicBeatState.update(self, dt)
    
    Conductor:update(Game.sound.music:tell() * 1000)

    if Game.sound.music ~= nil and Game.sound.music.volume < 0.8 then
        Game.sound.music.volume = math.min(Game.sound.music.volume + 0.5 * dt, 1) 
    end
end

function MainMenuState:resetCamStuff(snap)
    local snap = snap == nil and true or snap

    Game.camera:follow(self.camFollow, nil, 0.06)

    if snap then Game.camera:snapToTarget() end
end

return MainMenuState