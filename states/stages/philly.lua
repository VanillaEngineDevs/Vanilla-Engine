local Stage = BaseStage:extend()

local PhillyGlowParticle = require "states.stages.objects.PhillyGlowParticle"
local PhillyGlowGradient = require "states.stages.objects.PhillyGlowGradient"

Stage.phillyLightsColors = {}
Stage.phillyWindow = nil
Stage.phillyStreet = nil
Stage.phillyTrain = nil
Stage.curLight = -1

Stage.blammedLightsBlack = nil
Stage.phillyGlowGradient = nil
Stage.phillyGlowParticles = Group()
Stage.phillyWindowEvent = nil
Stage.curLightEvent = -1

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

    self.phillyStreet = BGSprite("stages/philly/street", -40, 50)
    self:add(self.phillyStreet)
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

function Stage:eventPushed(event)
    if event.event == "Philly Glow" then
        self.blammedLightsBlack = Sprite(push:getWidth() * -0.5, push:getHeight() * -0.5)
        self.blammedLightsBlack:makeGraphic(math.floor(push:getWidth()*2), math.floor(push:getHeight()*2), hexToColor(0x00000000))
        self.blammedLightsBlack.color = {0, 0, 0, 1}
        self.blammedLightsBlack.visible = false
        self:insert(table.indexOf(PlayState.members, self.phillyStreet), self.blammedLightsBlack)
        
        self.phillyWindowEvent = BGSprite("stages/philly/window", self.phillyWindow.x, self.phillyWindow.y, 0.3, 0.3)
        self.phillyWindowEvent:setGraphicSize(math.floor(self.phillyWindowEvent.width * 0.85))
        self.phillyWindowEvent:updateHitbox()
        self.phillyWindowEvent.visible = false
        self:insert(table.indexOf(PlayState.members, self.blammedLightsBlack)+1, self.phillyWindowEvent)

        self.phillyGlowGradient = PhillyGlowGradient(-400, 225)
        self.phillyGlowGradient.visible = false
        self:insert(table.indexOf(PlayState.members, self.blammedLightsBlack)+2, self.phillyGlowGradient)

        Paths.image("stages/philly/particle") -- precache
        self.phillyGlowParticles = Group()
        self.phillyGlowParticles.visible = false
        self:insert(table.indexOf(PlayState.members, self.phillyGlowGradient)+1, self.phillyGlowParticles)
    end
end

function Stage:eventCalled(eventName, v1, v2, fv1, fv2, strumTime)
    if eventName == "Philly Glow" then
        if not fv1 then fv1 = 0 end
        local lightId = math.round(fv1)

        local chars = {PlayState.boyfriend, PlayState.gf, PlayState.dad}

        if lightId == 0 then
            if self.phillyGlowGradient.visible then
                self:doFlash()
                PlayState.camGame.zoom = PlayState.camGame.zoom + 0.5
                PlayState.camHUD.zoom = PlayState.camHUD.zoom + 0.1

                self.blammedLightsBlack.visible = false
                self.phillyWindowEvent = false
                self.phillyGlowGradient = false
                self.phillyGlowParticles = false
                self.curLightEvent = -1

                for _, char in ipairs(chars) do
                    char.color = {1, 1, 1, 1}
                end
                self.phillyStreet.color = {1, 1, 1, 1}
            end
        elseif lightId == 1 then
            self.curLightEvent = love.math.randomIgnore( 1, 5, self.curLightEvent)
            local color = self.phillyLightsColors[self.curLightEvent]

            if not self.phillyGlowGradient.visible then
                self:doFlash()
                PlayState.camGame.zoom = PlayState.camGame.zoom + 0.5
                PlayState.camHUD.zoom = PlayState.camHUD.zoom + 0.1

                self.blammedLightsBlack.visible = true
                --self.blammedLightsBlack.alpha = 1
                self.phillyWindowEvent.visible = true
                self.phillyGlowGradient.visible = true
                self.phillyGlowParticles.visible = true
            end

            local charColor = color
            for _, char in ipairs(chars) do
                char.color = charColor
            end
            -- for all in phillyGlowParticles, set color to color
            for _, particle in ipairs(self.phillyGlowParticles.members) do
                particle.color = color
            end
            self.phillyGlowGradient.color = color
            self.phillyWindowEvent.color = color
            self.phillyStreet.color = color
        elseif lightId == 2 then
            local particlesNum = love.math.random(8, 12)
            local width = (2000 / particlesNum)
            local color = self.phillyLightsColors[self.curLightEvent]

            for j = 0, 2 do
                for i = 0, particlesNum-1 do
                    local particle = PhillyGlowParticle(-400 + width * i + love.math.random(-width/5, width/5), self.phillyGlowGradient.originalY + 200 + (love.math.random(0, 125) + j * 40), color)
                    self.phillyGlowParticles:add(particle)
                end
            end
            self.phillyGlowGradient:bop()
        end
    end
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

function Stage:doFlash()

end

return Stage