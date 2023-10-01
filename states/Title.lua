local TitleState = MusicBeatState:extend()
TitleState.music = nil
TitleState.music = love.audio.newSource("assets/music/freakyMenu.ogg", "stream")
TitleState.music:setLooping(true)
    
function TitleState:enter()
    
    if not TitleState.music:isPlaying() then
        TitleState.music:play()
    end
    self.danceLeft = true
    Conductor.changeBPM(102)
    self.logo = Sprite(-150, -100)
    self.logo:setFrames(Paths.getAtlas("menu/logoBumpin", "assets/images/png/menu/logoBumpin.xml"))
    self.logo:addByPrefix("bump", "logo bumpin", 24, false)
    self.logo:play("bump")

    self.gfTitle = Sprite(512, 40)
    self.gfTitle:setFrames(Paths.getAtlas("menu/gfDanceTitle", "assets/images/png/menu/gfDanceTitle.xml"))
    self.gfTitle:addByIndices("danceLeft", "gfDance", {30, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}, 24, false)
    self.gfTitle:addByIndices("danceRight", "gfDance", {16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29}, 24, false)
    self.gfTitle:play("danceLeft")

    self.enterText = Sprite(100, 576)
    self.enterText:setFrames(Paths.getAtlas("menu/titleEnter", "assets/images/png/menu/titleEnter.xml"))
    self.enterText:addByPrefix("idle", "Press Enter to Begin", 24, true)
    self.enterText:addByPrefix("flash", "ENTER PRESSED", 24, false)
    self.enterText:play("idle")

    if not firstStartup then
        MusicBeatState:fadeIn(0.3)
    end

    --TestSpr = AtlasSprite()
    --TestSpr:construct("stages/tank/cutscenes/stressPico")
end

function TitleState:update(dt)
    self.super.update(self, dt)
    Conductor.songPosition = Conductor.songPosition + 1000 * dt
    self.logo:update(dt)
    self.gfTitle:update(dt)
    self.enterText:update(dt)

    if input:pressed("accept") then
        self.enterText:play("flash")
        self.enterText.offset.x = -9
        self.enterText.offset.y = -4
        Sound.play(Paths.sound("assets/sounds/confirmMenu.ogg"))
        Timer.after(0.7, function()
            MusicBeatState:fadeOut(0.3,
            function()
                MusicBeatState:switchState(MainMenuState)
            end)
        end)
    end
end

function TitleState:beatHit()
    self.super.beatHit(self)

    if self.gfTitle then
        self.danceLeft = not self.danceLeft
        if self.danceLeft then
            self.gfTitle:play("danceLeft")
        else
            self.gfTitle:play("danceRight")
        end
    end

    if self.logo then
        self.logo:play("bump")
    end
end

function TitleState:draw()
    self.gfTitle:draw()
    self.logo:draw()
    self.enterText:draw()
end

function TitleState:leave()
    self.logo = nil
    self.gfTitle = nil
    self.enterText = nil
end

return TitleState