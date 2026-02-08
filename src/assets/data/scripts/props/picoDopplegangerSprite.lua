local picoDopplegangerSprite = Object:extend()

function picoDopplegangerSprite:set_shouldSing(v)
    self.shouldSing = v
    if not v then
        self.sprite.curFrame = 1
    end
end

function picoDopplegangerSprite:new(x, y)
    suffix = suffix or ""
    self.sprite = graphics.newTextureAtlas()

    print(EXTEND_LIBRARY("week3:philly/erect/pico_doppleganger", true))
    self.sprite:load(EXTEND_LIBRARY("week3:philly/erect/pico_doppleganger", true))

    self.sprite:addAnimByPrefix("shootPlayer", "shootPlayer", 24, false)
    self.sprite:addAnimByPrefix("shootOpponent", "shootOpponent", 24, false)
    self.sprite:addAnimByPrefix("explodePlayer", "explodePlayer", 24, false)
    self.sprite:addAnimByPrefix("explodeOpponent", "explodeOpponent", 24, false)
    self.sprite:addAnimByPrefix("cigarettePlayer", "cigarettePlayer", 24, false)
    self.sprite:addAnimByPrefix("cigaretteOpponent", "cigaretteOpponent", 24, false)
    self.sprite:addAnimByPrefix("loop", "loop", 24, true)

    self.x = x or 0
    self.y = y or 0
    self.sprite.x = self.x
    self.sprite.y = self.y
    self.scroll = {x = 1, y = 1}
    self.offsets = {0, 0}
    self.angle = 0
    self.shouldSing = false
    self.active = true
    self.suffix = ""
    self.mustHit = true
    self.cutsceneSound = nil
    self.visible = true
    self.shader = nil
end

function picoDopplegangerSprite:doAnim(suffix, shoot, explode, timer)
    self.suffix = suffix

    timer:after(0.3, function()
        self.cutsceneSound = love.audio.newSource(EXTEND_LIBRARY_SFX("week3:cutscene/picoGasp.ogg", true), "stream")
        self.cutsceneSound:play()
    end)

    if shoot then
        self.sprite:play("shoot"..suffix, true, false)

        Timer.after(6.29, function()
            self.cutsceneSound = love.audio.newSource(EXTEND_LIBRARY_SFX("week3:cutscene/picoShoot.ogg", true), "stream")
            self.cutsceneSound:play()
        end)
        Timer.after(10.33, function()
            self.cutsceneSound = love.audio.newSource(EXTEND_LIBRARY_SFX("week3:cutscene/picoSpin.ogg", true), "stream")
            self.cutsceneSound:play()
        end)
    else
        if explode then
            self.sprite:play("explode"..suffix, true, false)

            Timer.after(3.7, function()
                self.cutsceneSound = love.audio.newSource(EXTEND_LIBRARY_SFX("week3:cutscene/picoCigarette2.ogg", true), "stream")
                self.cutsceneSound:play()
            end)
            Timer.after(8.75, function()
                self.cutsceneSound = love.audio.newSource(EXTEND_LIBRARY_SFX("week3:cutscene/picoExplode.ogg", true), "stream")
                self.cutsceneSound:play()
            end)
        else
            self.sprite:play("cigarette"..suffix, true, false)
            Timer.after(3.7, function()
                self.cutsceneSound = love.audio.newSource(EXTEND_LIBRARY_SFX("week3:cutscene/picoCigarette.ogg", true), "stream")
                self.cutsceneSound:play()
            end)
        end
    end
end

function picoDopplegangerSprite:startLoop()
    self.sprite:play("loop", true, true)
end

function picoDopplegangerSprite:update(dt)
    -- my dumbass set the positions without the camera set.
    self.sprite.x = self.x + 195
    self.sprite.y = self.y + 215
    self.sprite.flipX = self.flipX
    self.sprite.flipY = self.flipY
    self.sprite.angle = self.angle
    self.sprite.scroll = self.scroll
    self.sprite.shader = self.shader
    self.sprite:update(dt)
end

function picoDopplegangerSprite:draw(camera)
    if not self.visible then return end
    self.sprite:draw(camera)
end

return picoDopplegangerSprite