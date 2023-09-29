local Stage = BaseStage:extend()

local DadBattleFog = require "states.stages.objects.DadBattleFog"

Stage.dadbattleBlack = nil
Stage.dadbattleLight = nil
Stage.dadbattleFog = nil

function Stage:create()
    local bg = BGSprite("stages/stage/stageback", -600, -200, 0.9, 0.9)
    self:add(bg)

    local stageFront = BGSprite("stages/stage/stagefront", -650, 600, 0.9, 0.9)
    stageFront:setGraphicSize(math.floor(stageFront.width * 1.1))
    stageFront:updateHitbox()
    self:add(stageFront)

    local stageLight = BGSprite("stages/stage/stage_light", -125, -100, 0.9, 0.9)
    stageLight:setGraphicSize(math.floor(stageLight.width * 1.1))
    stageLight:updateHitbox()
    self:add(stageLight)

    local stageLight = BGSprite("stages/stage/stage_light", 1225, -100, 0.9, 0.9)
    stageLight:setGraphicSize(math.floor(stageLight.width * 1.1))
    stageLight:updateHitbox()
    stageLight.flipX = true
    self:add(stageLight)

    local stageCurtains = BGSprite("stages/stage/stagecurtains", -500, -300, 1.3, 1.3)
    stageCurtains:setGraphicSize(math.floor(stageCurtains.width * 0.9))
    stageCurtains:updateHitbox()
    self:add(stageCurtains)
end

function Stage:eventPushed(event)
    if event.event == "Dadbattle Spotlight" then
        -- Preload for events
        self.dadbattleBlack = BGSprite(nil, -800, -400, 0, 0)
        self.dadbattleBlack:makeGraphic(math.floor(push:getWidth()*2), math.floor(push:getHeight()*2), hexToColor(0x00000000))
        self.dadbattleBlack.color = {0, 0, 0, 1}
        self.dadbattleBlack.alpha = 0.25
        self.dadbattleBlack.visible = false
        self:addInfrontBF(self.dadbattleBlack)

        self.dadbattleLight = BGSprite("stages/stage/spotlight", 400, -400)
        self.dadbattleLight.alpha = 0.375
        self.dadbattleLight.blend = "add"
        self.dadbattleLight.visible = false
        self:addInfrontBF(self.dadbattleLight)

        self.dadbattleFog = DadBattleFog()
        self.dadbattleFog.visible = false
        self:addInfrontBF(self.dadbattleFog)
    end
end

function Stage:eventCalled(eventName, v1, v2, fv1, fv2, strumTime)
    if eventName == "Dadbattle Spotlight" then
        if not fv1 then fv1 = 0 end
        local val = math.round(fv1)
        print(val)

        if val == 1 or val == 2 or val == 3 then
            if val == 1 then -- enable
                self.dadbattleBlack.visible = true
                self.dadbattleLight.visible = true
                self.dadbattleFog.visible = true
                PlayState.defaultCamZoom = PlayState.defaultCamZoom + 0.12
            end

            local who = PlayState.dad
            if val > 2 then who = PlayState.boyfriend end
            self.dadbattleLight.alpha = 0

            Timer.after(0.12, function() self.dadbattleLight.alpha = 0.375 end)

            self.dadbattleLight.x, self.dadbattleLight.y = who:getMidpoint().x - self.dadbattleLight.width/2, who:getMidpoint().y - self.dadbattleLight.height/2
            Timer.tween(1.5, self.dadbattleFog, {alpha = 0.7}, "in-out-quad")
        else
            self.dadbattleBlack.visible = false
            self.dadbattleLight.visible = false
            PlayState.defaultCamZoom = PlayState.defaultCamZoom - 0.12
            Timer.tween(1.5, self.dadbattleFog, {alpha = 0}, "in-out-quad", function() self.dadbattleFog.visible = false end)
        end
    end
end

return Stage