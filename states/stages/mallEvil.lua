local Stage = BaseStage:extend()

Stage.upperBoppers = nil
Stage.bottomBoppers = nil
Stage.santa = nil

function Stage:create()
    local bg = BGSprite("stages/christmas/evilBG", -400, -500, 0.2, 0.2)
    bg:setGraphicSize(math.floor(bg.width * 0.8))
    bg:updateHitbox()
    self:add(bg)

    local tree = BGSprite("stages/christmas/evilTree", 300, -300, 0.4, 0.4)
    self:add(tree)

    local fgSnow = BGSprite("stages/christmas/evilSnow", -200, 700)
    self:add(fgSnow)

    self:setDefaultGF("gf-christmas")

    if PlayState.isStoryMode and not PlayState.seenCutscene then
        if PlayState.songName == "winter-horrorland" then
            PlayState.startCallback = self.winterHorrorlandCutscene
        end
    end
end

function Stage:winterHorrorlandCutscene()
    PlayState.camHUD.visible = false
    self.inCutscene = true
    Paths.sound("assets/sounds/week5/Lights_Turn_On.ogg"):play()
    PlayState.camGame.zoom = 1.5
    PlayState.camGame.x, PlayState.camGame.y = 400, -2050

    local blackscreen = Sprite()
    blackscreen:makeGraphic(math.floor(push:getWidth()*2), math.floor(push:getHeight()*2), hexToColor(0x00000000))
    blackscreen.color = {0, 0, 0, 1}
    blackscreen.scrollFactor = {x = 0, y = 0}
    self:add(blackscreen)

    Timer.tween(0.7, blackscreen, {alpha = 0}, "linear", function() --[[ self:remove(blackscreen) ]] end)

    Timer.after(0.7, function()
        PlayState.camHUD.visible = true
        Timer.tween(2.5, PlayState.camGame, {zoom = PlayState.defaultCamZoom}, "in-out-quad", function()
            PlayState:startCountdown()
        end)
    end)
end

return Stage