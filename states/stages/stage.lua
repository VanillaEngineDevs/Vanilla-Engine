local Stage = BaseStage:extend()

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

return Stage