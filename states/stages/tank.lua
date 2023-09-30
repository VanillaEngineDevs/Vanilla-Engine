local Stage = BaseStage:extend()

local TankmenBG = require "states.stages.objects.TankmenBG"

Stage.tankWatchTower = nil
Stage.tankGround = nil
Stage.tankmanRun = nil
Stage.foregroundSprites = nil

function Stage:create()
    local sky = BGSprite("stages/tank/tankSky", -400, -400, 0, 0)
    self:add(sky)

    local clouds = BGSprite("stages/tank/tankClouds", love.math.random(-700, -100), love.math.random(-20, 20), 0.1, 0.1)
    clouds.active = true
    clouds.velocity.x = love.math.randomFloat(5, 15)
    self:add(clouds)

    local mountains = BGSprite("stages/tank/tankMountains", -300, -20, 0.2, 0.2)
    mountains:setGraphicSize(math.floor(mountains.width * 1.2))
    mountains:updateHitbox()
    self:add(mountains)

    local buildings = BGSprite("stages/tank/tankBuildings", -200, 0, 0.3, 0.3)
    buildings:setGraphicSize(math.floor(buildings.width * 1.1))
    buildings:updateHitbox()
    self:add(buildings)

    local ruins = BGSprite("stages/tank/tankRuins", -200, 0, 0.35, 0.35)
    ruins:setGraphicSize(math.floor(ruins.width * 1.1))
    ruins:updateHitbox()
    self:add(ruins)

    local smokeLeft = BGSprite("stages/tank/smokeLeft", -200, -100, 0.4, 0.4, {"SmokeBlurLeft"}, true)
    self:add(smokeLeft)
    local smokeRight = BGSprite("stages/tank/smokeRight", 1100, -100, 0.4, 0.4, {"SmokeRight"}, true)
    self:add(smokeRight)

    self.tankWatchTower = BGSprite("stages/tank/tankWatchtower", 100, 50, 0.5, 0.5, {"watchtower gradient color"})
    self:add(self.tankWatchTower)

    --[[ self.tankGround = BackGroundTank()
    self:add(self.tankGround) ]] -- causes stack overflow? gotta investigate...
    self.tankGround = BGSprite("stages/tank/tankRolling", 0, 0, 0.5, 0.5, {"BG tank w lighting"}, true)
    self.tankGround.tankSpeed = love.math.random(5, 7)
    self.tankGround.tankAngle = love.math.random(-90, 45)
    self.tankGround.offsetX = 400
    self.tankGround.offsetY = 1300

    self.tankmanRun = Group()
    self:add(self.tankmanRun)

    local ground = BGSprite("stages/tank/tankGround", -420, -150)
    ground:setGraphicSize(math.floor(ground.width * 1.15))
    self:add(ground)

    self.foregroundSprites = Group()
    self.foregroundSprites:add(BGSprite("stages/tank/tank0", -500, 650, 1.7, 1.5, {"fg"}))
    self.foregroundSprites:add(BGSprite("stages/tank/tank1", -300, 750, 2, 0.2, {"fg"}))
    self.foregroundSprites:add(BGSprite("stages/tank/tank2", 450, 940, 1.5, 1.5, {"foreground"}))
    self.foregroundSprites:add(BGSprite("stages/tank/tank4", 1300, 900, 1.5, 1.5, {"fg"}))
    self.foregroundSprites:add(BGSprite("stages/tank/tank5", 1620, 700, 1.5, 1.5, {"fg"}))
    self.foregroundSprites:add(BGSprite("stages/tank/tank3", 1300, 1200, 3.5, 2.5, {"fg"}))

    if songName== "stress" then self:setDefaultGF("pico-speaker")
    else self:setDefaultGF("gf-tankmen") end
end

function Stage:createPost()
    TankmenBG.animationNotes = PlayState.gf.animationNotes -- the lols
    self:add(self.foregroundSprites)

    if PlayState.gf.curCharacter == "pico-speaker" then
        local firstTank = TankmenBG(20, 500, true)
        firstTank:resetShit(20, 600, true)
        firstTank.strumTime = 10
        firstTank.visible = false
        self.tankmanRun:add(firstTank)

        for i = 1, #TankmenBG.animationNotes do
            if love.math.random(16) == 1 then
                local tankBih = TankmenBG(500, 200 + love.math.random(50, 100), TankmenBG.animationNotes[i][2] < 2)
                tankBih.strumTime = TankmenBG.animationNotes[i][1]
                tankBih:resetShit(500, 200 + love.math.random(50, 100), TankmenBG.animationNotes[i][2] < 2)

                self.tankmanRun:add(tankBih)
            end
        end
    end
end

function Stage:update(dt)
    self.super.update(self, dt)

    self.tankGround.tankAngle = self.tankGround.tankAngle + dt * self.tankGround.tankSpeed
    self.tankGround.angle = self.tankGround.tankAngle - 90 + 15
    self.tankGround.x = self.tankGround.offsetX + 1500 * math.cos(math.pi/180 * (self.tankGround.tankAngle + 180))
    self.tankGround.y = self.tankGround.offsetY + 1100 * math.sin(math.pi/180 * (self.tankGround.tankAngle + 180))
end

function Stage:countdownTick(count, num)
    if num % 2 == 0 then
        self:everyoneDance()
    end
end

function Stage:beatHit()
    self:everyoneDance()
end

function Stage:everyoneDance()
    self.tankWatchTower:dance()
    for i, dancer in ipairs(self.foregroundSprites.members) do
        dancer:dance()
    end
end

function Stage:eventPushed(event)
    if event.event == "Trigger BG Ghouls" then
        
    end
end

function Stage:eventCalled(eventName, v1, v2, fv1, fv2, strumTime)
    if eventName == "Trigger BG Ghouls" then
        
    end
end

return Stage