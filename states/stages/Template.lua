local Stage = BaseStage:extend()

function Stage:create()
    local bg = BGSprite("stages/stage/stageback", -600, -200, 0.9, 0.9)
    self:add(bg)

end

return Stage