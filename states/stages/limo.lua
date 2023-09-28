local Stage = BaseStage:extend()

local BackgroundDancer = require "states.stages.objects.BackgroundDancer"

Stage.grpLimoDancers = Group()
Stage.fastCar = nil
Stage.fastCarCanDrive = true

function Stage:create()
    local bg = BGSprite("stages/limo/limoSunset", -120, -50, 0.1, 0.1)
    self:add(bg)

    local bgLimo = BGSprite("stages/limo/bgLimo", -150, 480, 0.4, 0.4, {"Henchmen on rail"}, true)
    self:add(bgLimo)

    self.grpLimoDancers = Group()
    self:add(self.grpLimoDancers)

    for i = 0, 3 do
        local dancer = BackgroundDancer((370 * i) + 320 + bgLimo.x, bgLimo.y - 400)
        dancer.scrollFactor = {x = 0.4, y = 0.4}
        dancer.camera = PlayState.camGame
        self.grpLimoDancers:add(dancer)
    end
end

function Stage:createPost()
    --self:addBehindGf(self.fastCar)

    local limo = BGSprite("stages/limo/limoDrive", -120, 550, 1, 1, {"Limo stage"}, true)
    self:addBehindBF(limo)
end

function Stage:beatHit()
    for i, dancer in ipairs(self.grpLimoDancers.members) do
        dancer.danceDir = not dancer.danceDir
        dancer:dance()
    end
end

return Stage