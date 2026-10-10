local hasPlayedCutscene = false

function Song:onCreate()

end

function Song:onUpdate(dt)

end

function Song:onCountdownStart(event)
end

function Song:onSongEnd(event)
    if not hasPlayedCutscene then
        hasPlayedCutscene = true
        event:cancel()
        self:startCutscene()
    end
end

function Song:startCutscene()
    local normalSanta = get("santa")
    normalSanta.visible = false

    local santaDead = graphics.newTextureAtlas()
    santaDead:load(EXTEND_LIBRARY("week5:christmas/santa_speaks_assets", true))
    santaDead.x = -460
    santaDead.y = 500
    santaDead.zIndex = normalSanta.zIndex + 1
    santaDead.shader = normalSanta.shader

    add(santaDead)
    weeks:sort()

    santaDead:play("santa whole scene", true, false)

    getEnemy().visible = false
    local parentsShoot = graphics.newTextureAtlas()
    parentsShoot:load(EXTEND_LIBRARY("week5:christmas/parents_shoot_assets", true))
    parentsShoot.x = -470
    parentsShoot.y = 495
    parentsShoot.zIndex = normalSanta.zIndex - 1
    parentsShoot.shader = normalSanta.shader

    add(parentsShoot)
    weeks:sort()

    parentsShoot:play("parents whole scene", true, false)

    getBoyfriend().danceEvery = 0
    getEnemy().danceEvery = 0

    Timer.tween(2.8, getCamera(), {x = santaDead.x + 550, y = santaDead.y}, "out-expo")
    Timer.tween(2, getCamera(), {zoom = 0.73}, "in-out-quad")

    santaSound = love.audio.newSource(EXTEND_LIBRARY_SFX("week5:santa_emotion.ogg", true), "stream")
    santaSound:play()

    shootSound = love.audio.newSource(EXTEND_LIBRARY_SFX("week5:santa_shot_n_falls.ogg", true), "stream")

    Timer.after(2.8, function()
        Timer.tween(9, getCamera(), {x = santaDead.x + 400, y = santaDead.y}, "in-out-quart")
        Timer.tween(9, getCamera(), {zoom = 0.79}, "in-out-quad")
    end)

    Timer.after(11.375, function()
        audio.playSound(shootSound)
    end)

    Timer.after(12.83, function()
        getCamera():shake(0.005, 0.2)
        Timer.tween(9, getCamera(), {x = santaDead.x + 410, y = santaDead.y + 80}, "out-expo")
    end)

    Timer.after(15, function()
        graphics.fadeOut(1)
    end)

    Timer.after(16, function()
        weeks:endSong()
    end)
end
