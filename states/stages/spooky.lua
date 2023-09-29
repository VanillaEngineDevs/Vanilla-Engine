local Stage = BaseStage:extend()

Stage.lightningStrikeBeat = 0
Stage.lightningOffset = 8

function Stage:create()
    self.bg = BGSprite("stages/spooky/halloween_bg", -200, -100, 1, 1, {"halloweem bg0", "halloweem bg lightning strike"})
    self:add(self.bg)
end

function Stage:createPost()
end

function Stage:beatHit()
    if love.math.random(10) and PlayState.curBeat > self.lightningStrikeBeat + self.lightningOffset then
        self:lightningStrikeShit()
    end
end

function Stage:lightningStrikeShit()
    self.bg:play("halloweem bg lightning strike", true)
    self.bg.callback = function() 
        self.bg:dance(true)
        print("ohhohohhhhhh SHITTTTTTTT")
    end
    -- todo. thunder sound

    self.lightningStrikeBeat = PlayState.curBeat
    self.lightningOffset = love.math.random(8, 24)

    if PlayState.boyfriend.animOffsets["scared"] then
        PlayState.boyfriend:playAnim("scared", true)
    end

    if PlayState.dad.animOffsets["scared"] then
        PlayState.dad:playAnim("scared", true)
    end

    if PlayState.gf and PlayState.gf.animOffsets["scared"] then
        PlayState.gf:playAnim("scared", true)
    end
end

return Stage