local title = MusicBeatState:extend()

function title:enter()
    self.danceLeft = true
    Conductor.changeBPM(102)
    self.logo = Sprite(-150, -100)
    self.logo:setFrames(Paths.getSparrowAtlas("menu/logoBumpin", love.filesystem.read("assets/images/png/menu/logoBumpin.xml")))
    self.logo:addByPrefix("bump", "logo bumpin", 24, false)
    self.logo:play("bump")

    self.gfTitle = Sprite(512, 40)
    self.gfTitle:setFrames(Paths.getSparrowAtlas("menu/gfDanceTitle", love.filesystem.read("assets/images/png/menu/gfDanceTitle.xml")))
    self.gfTitle:addByIndices("danceLeft", "gfDance", {30, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}, 24, false)
    self.gfTitle:addByIndices("danceRight", "gfDance", {16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29}, 24, false)
    self.gfTitle:play("danceLeft")

    self.enterText = Sprite(100, 576)
    self.enterText:setFrames(Paths.getSparrowAtlas("menu/titleEnter", love.filesystem.read("assets/images/png/menu/titleEnter.xml")))
    self.enterText:addByPrefix("idle", "Press Enter to Begin", 24, true)
    self.enterText:addByPrefix("flash", "ENTER PRESSED", 24, false)
    self.enterText:play("idle")
end

function title:update(dt)
    self.super.update(self, dt)
    Conductor.songPosition = Conductor.songPosition + 1000 * dt
    self.logo:update(dt)
    self.gfTitle:update(dt)
    self.enterText:update(dt)

    if input:pressed("m_confirm") then
        self.enterText:play("flash")
        self.enterText.offset.x = -9
        self.enterText.offset.y = -4
        Gamestate.switch(PlayState)
    end
end

function title:beatHit()
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

function title:draw()
    self.gfTitle:draw()
    self.logo:draw()
    self.enterText:draw()
end

function title:leave()
    self.logo = nil
    self.gfTitle = nil
    self.enterText = nil
end

return title