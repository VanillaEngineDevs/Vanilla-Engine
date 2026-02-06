local gameover = {}
gameover.isEnding = false
gameover.isStarting = true

gameover.musicSuffix = ""
gameover.animationSuffix = ""
gameover.blueBallSuffix = ""

gameover._vol = {0}

gameover.mustNotExit = false

local CAMERA_ZOOM_DURATION = 0.5

local fromState = nil

function gameover:enter(from)
    if boyfriend then
        boyfriend.isDead = true
    end
    self.retryed = false

    self:setCameraTarget()

    musicTime = 0
    weeks.conductor:update(0)

    hapticUtil:vibrate(0, CONSTANTS.HAPTICS.DEFAULT_VIBRATION_DURATION)

    Timer.after(1, function()
        self.canInput = true
    end)
    self.members = {}

    self:add(boyfriend)

    fromState = from
end

function gameover:add(member)
    table.insert(self.members, member)
end

function gameover:remove(member)
    for i, v in ipairs(self.members) do
        if v == member then
            table.remove(self.members, i)
            return
        end
    end
end

function gameover:sort()
    table.sort(self.members, function(a, b)
        return (a.zIndex or 0) < (b.zIndex or 0)
    end)
end

function gameover:resolveMusicPath(suffix, starting, ending)
    local basePath = "gameplay/gameover/gameOver"
    if ending then
        basePath = basePath .. "End"
    elseif starting then
        basePath = basePath .. "Start"
    end

    local musicPath = "assets/shared/music/" .. basePath .. suffix .. ".ogg"
    while not love.filesystem.getInfo(musicPath) and #suffix > 0 do
        local parts = {}
        for part in string.gmatch(suffix, "[^-]+") do
            table.insert(parts, part)
        end
        table.remove(parts)
        suffix = table.concat(parts, "-")
        musicPath = "assets/shared/music/" .. basePath .. suffix .. ".ogg"
    end
    if not love.filesystem.getInfo(musicPath) then
        return nil
    end
    print("Resolved music path: " .. musicPath)
    return musicPath
end

function gameover:startDeathMusic(startingVol, force)
    local musicPath = self:resolveMusicPath(self.musicSuffix, self.isStarting, self.isEnding)
    local function onComplete()
    end

    if self.isStarting then
        if musicPath == nil then
            self.isStarting = false
            musicPath = self:resolveMusicPath(self.musicSuffix, self.isStarting, self.isEnding)
        else
            function onComplete()
                self.isStarting = false
                self:startDeathMusic(1, true)
            end
        end
    end

    if musicPath == nil then
        print("No valid game over music found")
        return
    elseif (self.gameOverMusic == nil or not self.gameOverMusic:isPlaying()) or force then
        if self.gameOverMusic then
            self.gameOverMusic:stop()
        end
        self.gameOverMusic = love.audio.newSource(musicPath, "stream")
        self.gameOverMusic:setVolume(startingVol or 1)
        self._vol[1] = startingVol or 1
        self.gameOverMusic:setLooping(not (self.isEnding or self.isStarting))
        self.gameOverMusic:play()
        self.musicPlaying = true
        self._onComplete = onComplete
    end
end

function gameover:setCameraTarget()
    local targetCameraZoom = weeks.stage.cameraZoom or 1
    if boyfriend then
        local bfpoint = {boyfriend:getMidpoint()}
        local offsets = boyfriend:getDeathCameraOffsets()
        CAM_LERP_POINT.x = bfpoint[1] + offsets[1] + 50
        CAM_LERP_POINT.y = bfpoint[2] + offsets[2] - 25
        targetCameraZoom = targetCameraZoom * (boyfriend:getDeathCameraZoom())
    end

    self.targetCameraZoom = targetCameraZoom
end

function gameover:playBlueBalledSFX()
    self.blueballed = true

    if love.filesystem.getInfo("assets/shared/sounds/gameplay/gameover/fnf_loss_sfx" .. self.blueBallSuffix .. ".ogg") then
        love.audio.newSource("assets/shared/sounds/gameplay/gameover/fnf_loss_sfx" .. self.blueBallSuffix .. ".ogg", "static"):play()
    else
        print("No blueballed SFX found at: " .. "assets/shared/sounds/gameplay/gameover/fnf_loss_sfx" .. self.blueBallSuffix .. ".ogg")
    end
end

function gameover:confirmDeath()
    if not self.isEnding then
        self.isEnding = true
        self.hasPlayedDeathQuote = true
        if self.deathQuoteSound then
            self.deathQuoteSound:stop()
            self.deathQuoteSound = nil
        end

        self:startDeathMusic(1, true)

        if boyfriend then
            boyfriend:play("deathConfirm" .. self.animationSuffix, true, false)
        end

        local FADE_TIMER = (self.gameOverMusic:getDuration()*1000) / 7000

        Timer.after(FADE_TIMER, function()
            local function endShit()
                Gamestate.pop()
                if fromState then
                    weeks:load(false)
                end
                if boyfriend then
                    boyfriend.isDead = false
                    boyfriend:dance()
                end
                camera.zoom = weeks.stage.cameraZoom or 1
            end

            local function resetPlaying(pixel)
                if pixel then
                    graphics.fadeIn(1)
                else
                    graphics.fadeIn(1, function()
                    end)
                end
                endShit()
            end

            if self.musicSuffix == "-pixel" then
                graphics.fadeOut(2, function()
                    resetPlaying(true)
                end)
            else
                graphics.fadeOut(2, function()
                    print("Gameover fade out complete.")
                    resetPlaying(false)
                end)
            end
        end)
    end
end

function gameover:playDeathQuote()
    if self.isEnding then return end
    if boyfriend == nil then return end

    local deathQuote = boyfriend:getDeathQuote()
    if not deathQuote then return end

    if self.deathQuoteSound then
        self.deathQuoteSound:stop()
        self.deathQuoteSound = nil
    end

    self:startDeathMusic(0.2, false)
    boyfriend:play("deathLoop" .. self.animationSuffix, true, true)
    self.deathQuoteSound = love.audio.newSource(deathQuote, "static")
    self.deathQuoteSound:play()
    Timer.after(self.deathQuoteSound:getDuration(), function()
        print("Death quote finished playing.")
        Timer.tween(4, self._vol, {1}, "linear", function()
            print("Volume tween complete.")
        end)
    end)
end

function gameover:update(dt)
    if self.musicPlaying then
        if self.gameOverMusic then
            self.gameOverMusic:setVolume(self._vol[1])
        end
        if self.gameOverMusic and not self.gameOverMusic:isPlaying() then
            self.musicPlaying = false
            if self._onComplete then
                self._onComplete()
                self._onComplete = nil
            end
        end
    end
    for _, member in ipairs(self.members) do
        member:update(dt)
        if member.call then
            member:call("onUpdate", dt)
        end
    end
    if not self.hasStartedAnimation then
        self.hasStartedAnimation = true

        if not boyfriend then
            self:playBlueBalledSFX()
        else
            if boyfriend:hasAnimation("fakeoutDeath") and love.math.random() < (1 / 4096) then
                boyfriend:play("fakeoutDeath", true, false)
            else
                boyfriend:play("firstDeath", true, false)
                self:playBlueBalledSFX()
            end
        end
    end

    local adjustedLerp = 1 - math.pow(1.0 - (0.04/2), dt * 60)
    camera.x = camera.x + (CAM_LERP_POINT.x - camera.x) * adjustedLerp
    camera.y = camera.y + (CAM_LERP_POINT.y - camera.y) * adjustedLerp
    camera.zoom = util.lerp(self.targetCameraZoom, camera.zoom, math.pow(1/100, dt / CAMERA_ZOOM_DURATION))

    -- something sokmething confirm inputs
    if self.canInput and self.blueballed and not self.mustNotExit then
        if input:pressed("confirm") then
            self.retryed = true
            self.blueballed = false
            self:confirmDeath()
        end
    end

    if self.gameOverMusic ~= nil and self.gameOverMusic:isPlaying() then
        musicTime = musicTime + dt
        weeks.conductor:update(dt)
    elseif boyfriend then
        if boyfriend:getDeathQuote() ~= nil then
            if not boyfriend.sprite.curAnim then return end
            if boyfriend.sprite.curAnim.name:startsWith("firstDeath") and boyfriend.sprite.animFinished then
                self.hasPlayedDeathQuote = true
                self:playDeathQuote()
            end
        else
            if boyfriend.sprite.curAnim.name:startsWith("firstDeath") and boyfriend.sprite.animFinished then
                self:startDeathMusic(1, false)
                boyfriend:play("deathLoop" .. self.animationSuffix, true, true)
            end
        end
    end
end

function gameover:draw()
    love.graphics.push()
        love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
        love.graphics.scale(camera.zoom, camera.zoom)
        love.graphics.translate(-graphics.getWidth() / 2, -graphics.getHeight() / 2)

        for _, member in ipairs(self.members) do
            member:draw(camera)
        end
    love.graphics.pop()
end

function gameover:leave()
    if boyfriend then
        boyfriend.isDead = false
    end
    self.musicSuffix = ""
    self.animationSuffix = ""
    self.blueBallSuffix = ""
    self.isEnding = false
    self.isStarting = true
    self._vol = {0}
    self.mustNotExit = false
    self.canInput = false
    self.hasStartedAnimation = false
    self.targetCameraZoom = 1
    self.gameoverMusic = nil
    self.musicPlaying = false
    self.blueballed = false
    self.members = {}

    if boyfriend and boyfriend.call and self.retryed then
        boyfriend:call("onSongRetry")
    end
end

return gameover