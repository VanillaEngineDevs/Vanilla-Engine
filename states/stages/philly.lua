local Stage = BaseStage:extend()

Stage.phillyLightsColors = {}
Stage.phillyWindow = nil
Stage.phillyStreet = nil
Stage.phillyTrain = nil
Stage.curLight = -1

function Stage:create()
    local bg = BGSprite("stages/philly/sky", -100, 0, 0.1, 0.1)
    bg:updateHitbox()
    self:add(bg)

    local city = BGSprite("stages/philly/city", -10, 0, 0.3, 0.3)
    city:setGraphicSize(math.floor(city.width * 0.85))
    city:updateHitbox()
    self:add(city)

    self.phillyLightsColors = {
        hexToColor(0xFF31A2Fd),
        hexToColor(0xFF31FD8C),
        hexToColor(0xFFFB33F5),
        hexToColor(0xFFFD4531),
        hexToColor(0xFFFBA633)
    }
    self.phillyWindow = BGSprite("stages/philly/window", city.x, city.y, 0.3, 0.3)
    self.phillyWindow:setGraphicSize(math.floor(self.phillyWindow.width * 0.85))
    self.phillyWindow:updateHitbox()
    self:add(self.phillyWindow)
    self.phillyWindow.alpha = 0

    local streetBehind = BGSprite("stages/philly/behindTrain", -40, 50)
    self:add(streetBehind)

    phillyStreet = BGSprite("stages/philly/street", -40, 50)
    self:add(phillyStreet)
end

function Stage:createPost()
    -- Resize Boyfriend and dad from Playstate
    PlayState.boyfriend:setGraphicSize(math.floor(PlayState.boyfriend.width * 0.85))
    PlayState.boyfriend:updateHitbox()
    PlayState.dad.scale = PlayState.boyfriend.scale
    PlayState.gf.scale = PlayState.boyfriend.scale

    -- for reasons, simply dance them all
    PlayState.boyfriend:dance()
    PlayState.dad:dance()
    PlayState.gf:dance()
end

function Stage:update(dt)
    self.phillyWindow.alpha = self.phillyWindow.alpha - (Conductor.crochet / 1000) * dt * 1.5
end

function Stage:beatHit()
    if PlayState.curBeat % 4 == 0 then
        self.curLight = love.math.randomIgnore(1, 5, self.curLight)
        self.phillyWindow.color = self.phillyLightsColors[self.curLight]
        self.phillyWindow.alpha = 1
    end
end

return Stage