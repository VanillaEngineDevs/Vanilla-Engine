local Stage = BaseStage:extend()

Stage.upperBoppers = nil
Stage.bottomBoppers = nil
Stage.santa = nil

function Stage:create()
    local bg = BGSprite("stages/christmas/bgWalls", -1000, -500, 0.2, 0.2)
    bg:setGraphicSize(math.floor(bg.width * 0.8))
    bg:updateHitbox()
    self:add(bg)

    self.upperBoppers = BGSprite("stages/christmas/upperBop", -240, -90, 0.33, 0.33, {"Upper Crowd Bob"})
    self.upperBoppers:setGraphicSize(math.floor(self.upperBoppers.width * 0.85))
    self.upperBoppers:updateHitbox()
    self:add(self.upperBoppers)

    local bgEscalator = BGSprite("stages/christmas/bgEscalator", -1100, -600, 0.3, 0.3)
    bgEscalator:setGraphicSize(math.floor(bgEscalator.width * 0.9))
    bgEscalator:updateHitbox()
    self:add(bgEscalator)

    local tree = BGSprite("stages/christmas/christmasTree", 370, -250, 0.4, 0.4)
    self:add(tree)

    self.bottomBoppers = BGSprite("stages/christmas/bottomBop", -300, 140, 0.9, 0.9, {"Bottom Level Boppers Idle"})
    self.bottomBoppers:addByPrefix("hey", "Bottom Level Boppers HEY", 24, false)
    self.bottomBoppers.heyTimer = 0
    self:add(self.bottomBoppers)

    local fgSnow = BGSprite("stages/christmas/fgSnow", -600, 700)
    self:add(fgSnow)

    self.santa = BGSprite("stages/christmas/santa", -840, 150, 1, 1, {"santa idle in fear"})
    self:add(self.santa)
    self:setDefaultGF("gf-christmas")

    if PlayState.isStoryMode and not PlayState.seenCutscene then
        PlayState.endCallback = self.eggnogEndCutscene
    end
end

function Stage:update(dt)
    if self.bottomBoppers.heyTimer > 0 then
        self.bottomBoppers.heyTimer = self.bottomBoppers.heyTimer - dt
        if self.bottomBoppers.heyTimer <= 0 then
            self.bottomBoppers:dance(true)
            self.bottomBoppers.heyTimer = 0
        end
    end
end

function Stage:beatHit()
    self:everyoneDance()
end

function Stage:eventCalled(eventName, v1, v2, fv1, fv2, strumTime)
    if eventName == "Hey!" then
        if v1:trim() == "bf" or v1:trim() == "boyfriend" or v1:trim() == "0" then
            return
        end
        self.bottomBoppers:play("hey", true)
        self.bottomBoppers.heyTimer = fv2
    end
end

function Stage:everyoneDance()
    self.upperBoppers:dance(true)
    if self.bottomBoppers.heyTimer <= 0 then
        self.bottomBoppers:dance(true)
    end
    self.santa:dance()
end

function Stage:eggnogEndCutscene()
    if not PlayState.storyPlaylist[2] then
        PlayState:endSong()
        return
    end

    local nextSong = Paths.formatToSongPath(PlayState.storyPlaylist[2])
    if nextSong == "winter-horrorland" then
        Paths.sound("assets/sounds/week5/Lights_Shut_off.ogg"):play()
        local blackshit = Sprite(-push:getWidth() * PlayState.camGame.zoom, -push:getHeight() * PlayState.camGame.zoom)
        blackshit:makeGraphic(push:getWidth()*3, push:getHeight()*3, hexToColor(0x00000000))
        blackshit.color = hexToColor(0x00000000)
        blackshit.scrollFactor = {x=0, y=0}
        self:add(blackshit)

        PlayState.camHUD.visible = false

        PlayState.inCutscene = true
        PlayState.canPause = false

        Timer.after(1.5, function() PlayState:endSong() end)
    else
        PlayState:endSong()
    end
end

return Stage