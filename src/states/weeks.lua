local weeks = {}

weeks._ratingTimers = {}
weeks.camTween, weeks.bumpTween = nil, nil

weeks._useAltAnims = false

weeks.healthlerp = 1
weeks.dying = false

weeks.noteSprites = nil

local isResetting = false
local resettingTime = {0}
local camZoomTween

weeks.UI_VISIBLE = true

local weekStates = {
	sickCounter = 0,
	goodCounter = 0,
	badCounter = 0,
	shitCounter = 0,
	missCounter = 0,
	maxCombo = 0,
	score = 0
}

local states = {
    sickCounter = 0,
    goodCounter = 0,
    badCounter = 0,
    shitCounter = 0,
    missCounter = 0,
    maxCombo = 0,
    combo = 0,
    total = 0,
    score = 0,
    ratingPercent = 0.0,
    nps = {},
    maxNPS = 0
}

local hudFade = {1}

local FLASH = {0}
local countdownFade = {0}

weeks.songs = {}

local WEEKID = ""
local SONGID = ""

weeks.smoothReset = true
weeks.currentSongNum = 1
weeks.difficulty = "normal"
weeks.songExt = ""
weeks.audioAppend = ""

local quitPressed = false

local CAM_LERP_POINT = { x = 0, y = 0 }

local healthIconPreloads = {}
local inHolds = {false, false, false, false}
local eventScripts

local COUNTDOWN_STEPS ={
    BEFORE = 1,
    THREE = 2,
    TWO = 3,
    ONE = 4,
    GO = 5,
    AFTER = 6
}
weeks.countdownStep = 1

local function loadEventScript(id)
    if eventScripts[id] then
        return eventScripts[id]
    end

    local path = "assets/scripts/events/" .. id .. ".lua"

    if not love.filesystem.getInfo(path) then
        return nil
    end

    local Event = Object:extend()

    local env = setmetatable({
        Event = Event,
        add = function(obj)
            weeks:add(obj)
        end,
        remove = function(obj)
            weeks:remove(obj)
        end,
        getBoyfriend = function()
            return weeks.boyfriend
        end,
        getEnemy = function()
            return weeks.enemy
        end,
        getCamera = function()
            return uiCam
        end,
        weeks = weeks,
        CONSTANTS = CONSTANTS,
    }, {
        __index = _G
    })

    local chunk = love.filesystem.load(path)
    setfenv(chunk, env)
    chunk()

    local event = Event()

    eventScripts[id] = event

    return event
end

function weeks:enter(_, songNum, songAppend, _songExt, _audioAppend, _, weekID)
    self.timer = Timer.new()
    camera.cameraZoom = 1
    -- self:showUI()
    self.mayPauseGame = false
    self.isInCutscene = false
    self.gameoverType = "character"
    camera.IS_CLASSIC_MOVEMENT = false
    weekStates = {
        sickCounter = 0,
        goodCounter = 0,
        badCounter = 0,
        shitCounter = 0,
        missCounter = 0,
        maxCombo = 0,
        total = 0,
        score = 0
    }
    states = {
        sickCounter = 0,
        goodCounter = 0,
        badCounter = 0,
        shitCounter = 0,
        missCounter = 0,
        maxCombo = 0,
        combo = 0,
        total = 0,
        score = 0,
        ratingPercent = 0.0,
        nps = {},
        maxNPS = 0
    }

    beatHandler.reset()
    self.smoothReset = true

    countdownFade = {0}

    self.conductor = Conductor.new()

    WEEKID = weekID or "tutorial"
    weeks.currentSongNum = songNum or 1
    weeks.difficulty = songAppend or "normal"
    weeks.songExt = _songExt or ""
    weeks.audioAppend = _audioAppend or ""

    eventScripts = {}
    for _, name in ipairs(love.filesystem.getDirectoryItems("assets/scripts/events/")) do
        loadEventScript(name:gsub(".lua$", ""))
        print(name:gsub(".lua$", ""))
    end

    self.CURCHART = {
        BOYFRIEND = {},
        ENEMY = {},
        EVENTS = {}
    }
    
    self:load()
end

function weeks:load(wasntRestart)
    camera.bopIntensity = CONSTANTS.DEFAULT_BOP_INTENSITY
    camera.zoomRate = CONSTANTS.DEFAULT_ZOOM_RATE
    camera.zoomRateOffset = CONSTANTS.DEFAULT_ZOOM_OFFSET
    camera.bopMultiplier = 1
    uiCam.bopIntensity = 0.015 * 2
    camera.camBopIntensity = 1
    camera.camBopInterval = 4
    camera.centered = true

    self.mayPauseGame = false
    self.inSong = true
    if wasntRestart == nil then wasntRestart = true end
    self.dying = false
    self.useBuiltInGameover = true

    self.paused = false
    -- pauseScreen:setup()

    self.healthGainMult = 1
    self.healthLossMult = 1
    self.ignoreHealthClamping = false
    self.health = CONSTANTS.WEEKS.HEALTH.STARTING
    self.healthLerp = self.health

    self._useAltAnims = false
    self.objects = {}

    self.stageShader = nil
    self.uiShader = nil

    states = {
        sickCounter = 0,
        goodCounter = 0,
        badCounter = 0,
        shitCounter = 0,
        missCounter = 0,
        maxCombo = 0,
        combo = 0,
        total = 0,
        score = 0,
        ratingPercent = 0.0,
        nps = {},
        maxNPS = 0
    }

    self.hudFade = {1}

    if wasntRestart then
        if self.boyfriend then
            camera.x, camera.y = -self.boyfriend.x + 100, -self.boyfriend.y + 75
        else
            camera.x, camera.y = 0, 0
        end
    end

    isResetting = false

    self.songEvents = {}
    if not wasntRestart then
        local bfPoint = self.boyfriend and self.boyfriend:getCameraPoint() or {x = 0, y = 0}
        camera:forcePos(bfPoint.x, bfPoint.y)

        for _, event in ipairs(self.CURCHART.EVENTS) do
            table.insert(self.songEvents, event)
        end

        self.stage:call("onSongRetry")
        self.song:call("onSongRetry")
        for _, obj in ipairs(self.objects) do
            if obj.call then
                obj:call("onSongRetry")
            end
        end
    end

    previousFrameTime = love.timer.getTime() * 1000

    if wasntRestart and not graphics.isFading() then
        self:generateNotes(self.songs[self.currentSongNum], self.difficulty)
        graphics:fadeInWipe(0.6)

        if self.boyfriend then
            local bfpoint = self.boyfriend:getCameraPoint()
            camera.x = bfpoint.x
            camera.y = bfpoint.y
            camera.defaultX = bfpoint.x
            camera.defaultY = bfpoint.y
            camera.targetX = bfpoint.x
            camera.targetY = bfpoint.y
            CAM_LERP_POINT.x = bfpoint.x
            CAM_LERP_POINT.y = bfpoint.y
        end
    end

    self.healthbar = Healthbar()

    local vwoosh = 0.5
    musicTime = (-vwoosh * 1000) + (self.conductor:getBeatLengthsMS() * -5)

    self.enemyPlayfield:initVwoosh()
    self.boyfriendPlayfield:initVwoosh()
    self.enemyPlayfield:update(0)
    self.boyfriendPlayfield:update(0)
    self.timer:after(vwoosh, function()
        self:vwooshArrows(self.enemyPlayfield)
        self:vwooshArrows(self.boyfriendPlayfield)
        self:performCountdown(vwoosh)
    end)

    self.songEnded = false

    status.setLoading(false)
end

function weeks:initUI(mode)
    self.sounds = {
    }

    if not pixel then
        self:setNoteSprites(
            love.filesystem.load("sprites/receptor.lua"),
            love.filesystem.load("sprites/left-arrow.lua"),
            love.filesystem.load("sprites/down-arrow.lua"),
            love.filesystem.load("sprites/up-arrow.lua"),
            love.filesystem.load("sprites/right-arrow.lua")
        )

        self.sounds.countdown = {
            three = love.audio.newSource("sounds/countdown-3.ogg", "static"),
            two = love.audio.newSource("sounds/countdown-2.ogg", "static"),
            one = love.audio.newSource("sounds/countdown-1.ogg", "static"),
            go = love.audio.newSource("sounds/countdown-go.ogg", "static")
        }
    else
        self:setNoteSprites(
            love.filesystem.load("sprites/receptor.lua"),
            love.filesystem.load("sprites/left-arrow.lua"),
            love.filesystem.load("sprites/down-arrow.lua"),
            love.filesystem.load("sprites/up-arrow.lua"),
            love.filesystem.load("sprites/right-arrow.lua")
        )
        self.sounds.countdown = {
            three = love.audio.newSource("sounds/pixel/countdown-3.ogg", "static"),
            two = love.audio.newSource("sounds/pixel/countdown-2.ogg", "static"),
            one = love.audio.newSource("sounds/pixel/countdown-1.ogg", "static"),
            go = love.audio.newSource("sounds/pixel/countdown-date.ogg", "static")
        }
    end
end

function weeks:preloadIcon(path, name, scale)
    name = name or path
    if not healthIconPreloads[name] then
        healthIconPreloads[name] = icon.newIcon(icon.imagePath(path), scale or 1)
    end

    return healthIconPreloads[name]
end

function weeks:setNoteSprites(receptors, left, down, up, right)
    self.noteSprites = {
        left,
        down,
        up,
        right,
        receptors
    }
end

function weeks:getStates()
    return states
end

function weeks:vwooshArrows(playfield)
    local vwooshTime = 0.5
    for i, receptor in ipairs(playfield.receptors) do
        receptor.alpha = 0
        receptor.y = receptor.y - playfield.vwooshYAmt
        local vwooshSteps = vwooshTime / #playfield.receptors
        Timer.after(vwooshSteps * (i-1), function()
            local target = CONSTANTS.WEEKS.STRUM_Y * (settings.downscroll and -1 or 1)

            Timer.tween(vwooshSteps, receptor, {
                alpha = receptor.finishedAlpha,
                y = target
            }, "out-circ", function()
                receptor.alpha = receptor.finishedAlpha
                receptor.y = target
            end)
        end)
    end
end

function weeks:generateNotes(name, diff)
    local chartPath = "data/songs/" .. name .. "/" .. name .. "-chart" .. self.songExt .. ".lua"
    local metadataPath = "data/songs/" .. name .. "/" .. name .. "-metadata" .. self.songExt .. ".lua"
    if not love.filesystem.getInfo(chartPath) then
        chartPath = "data/songs/" .. name .. "/" .. name .. "-chart" .. self.songExt .. ".json"
    end
    if not love.filesystem.getInfo(metadataPath) then
        metadataPath = "data/songs/" .. name .. "/" .. name .. "-metadata" .. self.songExt .. ".json"
    end

    self.song = Song.getSong(name .. self.songExt)

    local chart = chartPath
    local metadata = metadataPath
    local chartData
    if string.endsWith(chart, ".json") then
        chartData = json.decode(love.filesystem.read(chart))
    else
        chartData = love.filesystem.load(chart)()
    end

    chart = chartData.notes[diff] or chartData.notes["normal"]

    if string.endsWith(metadata, ".json") then
        metadata = json.decode(love.filesystem.read(metadata))
    else
        metadata = love.filesystem.load(metadata)()
    end

    if metadata.playData and metadata.playData.noteStyle then
        if metadata.playData.noteStyle == "pixel" then
            self:initUI("pixel")
        else
            self:initUI("normal")
        end
    else
        self:initUI("normal")
    end

    self.boyfriendPlayfield = playfield(true, self.noteSprites[5])
    self.boyfriendPlayfield.offsetX = 250
    self.enemyPlayfield = playfield(false, self.noteSprites[5], CHARACTER_TYPE.DAD)

    self.chart = chartData
    self.metadata = metadata
    SONGID = name
    self.conductor:mapBPMChanges(metadata)
    metadata.playData = metadata.playData or {}
    metadata.playData.characters = metadata.playData.characters or {}
    metadata.playData.characters.opponent = metadata.playData.characters.opponent or "dad"
    metadata.playData.characters.player = metadata.playData.characters.player or "bf"
    metadata.playData.characters.girlfriend = metadata.playData.characters.girlfriend
    self.boyfriend = Character.getCharacter(metadata.playData.characters.player)
    self.enemy = Character.getCharacter(metadata.playData.characters.opponent)
    self.girlfriend = Character.getCharacter(metadata.playData.characters.girlfriend)

    self.inst = love.audio.newSource("songs/" .. name .. "/Inst" .. self.songExt .. ".ogg", "stream")
    local voicesBFPath = "songs/" .. name .. "/Voices-" .. metadata.playData.characters.player .. self.songExt .. ".ogg"
    local voicesEnemyPath = "songs/" .. name .. "/Voices-" .. metadata.playData.characters.opponent .. self.songExt .. ".ogg"
    local voiceConversions = {
        ["pico-playable"] = "pico",
        ["pico-pixel"] = "pico",
        ["pico-blazin"] = "pico",
        ["pico-dark"] = "pico",
        ["pico-christmas"] = "pico",
        ["pico-holding-nene"] = "pico",

        ["bf-car"] = "bf",
        ["bf-pixel"] = "bf",
        ["bf-christmas"] = "bf",
        ["bf-holding-gf"] = "bf",
        ["bf-dark"] = "bf",

        ["tankman-bloody"] = "tankman",

        ["mom-car"] = "mom",

        ["spooky-dark"] = "spooky",
    }
    local vocals = metadata.playData.characters.playerVocals and metadata.playData.characters.playerVocals[1] or metadata.playData.characters.player
    local vocalsEnemy = metadata.playData.characters.opponentVocals and metadata.playData.characters.opponentVocals[1] or metadata.playData.characters.opponent
    if not love.filesystem.getInfo(voicesBFPath) then
        voicesBFPath = "songs/" .. name .. "/Voices-" .. vocals .. self.songExt .. ".ogg"
        if not love.filesystem.getInfo(voicesBFPath) and voiceConversions[vocals] then
            voicesBFPath = "songs/" .. name .. "/Voices-" .. voiceConversions[vocals] .. self.songExt .. ".ogg"
        end
    end

    if not love.filesystem.getInfo(voicesEnemyPath) then
        voicesEnemyPath = "songs/" .. name .. "/Voices-" .. vocalsEnemy .. self.songExt .. ".ogg"
        if not love.filesystem.getInfo(voicesEnemyPath) and voiceConversions[vocalsEnemy] then
            voicesEnemyPath = "songs/" .. name .. "/Voices-" .. voiceConversions[vocalsEnemy] .. self.songExt .. ".ogg"
        end
    end
    if love.filesystem.getInfo(voicesBFPath) then
        self.voicesBF = love.audio.newSource(voicesBFPath, "stream")
    else
        self.voicesBF = nil
    end
    if love.filesystem.getInfo(voicesEnemyPath) then
        self.voicesEnemy = love.audio.newSource(voicesEnemyPath, "stream")
    else
        self.voicesEnemy = nil
    end

    self.boyfriend.zIndex = 10
    self.enemy.zIndex = 8
    if self.girlfriend then self.girlfriend.zIndex = 9 end

    self.boyfriend.characterType = CHARACTER_TYPE.BF
    self.enemy.characterType = CHARACTER_TYPE.DAD
    if self.girlfriend then self.girlfriend.characterType = CHARACTER_TYPE.GF end

    self.boyfriend.flipX = not self.boyfriend._data.flipX
    self.enemy.flipX = self.enemy._data.flipX
    if self.girlfriend then self.girlfriend.flipX = self.girlfriend._data.flipX end

    self.boyfriend:dance()
    self.enemy:dance()
    if self.girlfriend then self.girlfriend:dance() end

    self.stage = Stage.getStage(metadata.playData.stage or "mainStage")
    self.stage:build()
    self.stage:call("postCreate")
    self.song:call("postCreate")
    if self.boyfriend.call then self.boyfriend:call("postCreate") end
    if self.enemy.call then self.enemy:call("postCreate") end
    if self.girlfriend and self.girlfriend.call then self.girlfriend:call("postCreate") end
    camera.zoom = self.stage.cameraZoom or 1.0
    camera.defaultZoom = 1

    self.boyfriend.name = "bf"
    self:add(self.boyfriend)
    self.enemy.name = "enemy"
    self:add(self.enemy)
    if self.girlfriend then self.girlfriend.name = "gf" end
    if self.girlfriend then self:add(self.girlfriend) end
    self:sort()

    self.boyfriend:updateHitbox()
    self.boyfriend.x = self.boyfriend.x - self.boyfriend.width / 2
    self.boyfriend.y = self.boyfriend.y - self.boyfriend.height

    self.enemy:updateHitbox()
    self.enemy.x = self.enemy.x - self.enemy.width / 2
    self.enemy.y = self.enemy.y - self.enemy.height

    if self.girlfriend then
        self.girlfriend:updateHitbox()
        self.girlfriend.x = self.girlfriend.x - self.girlfriend.width / 2 - 150
        self.girlfriend.y = self.girlfriend.y - self.girlfriend.height
    end

    local bfpoint = self.boyfriend:getCameraPoint()

    camera.x = bfpoint.x
    camera.y = bfpoint.y
    camera.defaultX = bfpoint.x
    camera.defaultY = bfpoint.y
    camera.targetX = bfpoint.x
    camera.targetY = bfpoint.y
    CAM_LERP_POINT.x = bfpoint.x
    CAM_LERP_POINT.y = bfpoint.y

    local events = {}

    for _, timeChange in ipairs(metadata.timeChanges) do
        local time = timeChange.t
        local bpm_ = timeChange.bpm

        table.insert(events, {time = time, bpm = bpm_, type="bpm"})

        if not bpm then bpm = bpm_ end
        if not crochet then crochet = ((60/bpm) * 1000) end
        if not stepCrochet then stepCrochet = crochet / 4 end
    end

    if not bpm then bpm = 120 end

    local _speed = 1
    if chartData.scrollSpeed[self.difficulty] then
        _speed = chartData.scrollSpeed[self.difficulty]
    elseif chartData.scrollSpeed["default"] then
        _speed = chartData.scrollSpeed["default"]
    end

    weeks.speed = _speed * 1.06

    for _, noteData in ipairs(chart) do
        if noteData.d > 3 then
            self.enemyPlayfield:addNote(noteData, self.noteSprites[noteData.d%4+1])
        else
            self.boyfriendPlayfield:addNote(noteData, self.noteSprites[noteData.d%4+1])
        end
    end

    self.CURCHART.EVENTS = {}
    for _, event in ipairs(chartData.events) do
        table.insert(self.CURCHART.EVENTS, event)
        table.insert(self.songEvents, event)
    end

    table.sort(self.CURCHART.EVENTS, function(a, b) return a.t < b.t end)
    table.sort(self.songEvents, function(a, b) return a.t < b.t end)

    self.enemyPlayfield:sortNotes()
    self.boyfriendPlayfield:sortNotes()
end

function weeks:pauseCountdown()
    if self.countdownTimer then
        self.countdownTimer.active = false
    end
    self.countingDown = false
end

function weeks:resumeCountdown()
    if self.countdownTimer then
        self.countdownTimer.active = true
    end
    self.countingDown = true
end

function weeks:stopCountdown()
    if self.countdownTimer then
        Timer.cancel(self.countdownTimer)
        self.countdownTimer = nil
    end
    self.countingDown = false
end

function weeks:performCountdown()
    self.mayPauseGame = false
    self.countingDown = true

    self.countdownStep = COUNTDOWN_STEPS.BEFORE
    local event = eventCreator:countdownStart()
    self.stage:call("onCountdownStart", event)
    self.song:call("onCountdownStart", event)
    if event.cancelled then
        self:stopCountdown()
        return
    end

    self:stopCountdown()

    musicTime = self.conductor:getBeatLengthsMS() * -4

    self.countdownTimer = Timer.after(self.conductor:getBeatLengthsMS()/1000, function()
        self.countingDown = true
        if self.countdownStep == COUNTDOWN_STEPS.BEFORE then
            self.countdownStep = COUNTDOWN_STEPS.THREE
            audio.playSound(self.sounds.countdown[CONSTANTS.WEEKS.COUNTDOWN_SOUNDS[4]])
        elseif self.countdownStep == COUNTDOWN_STEPS.THREE then
            self.countdownStep = COUNTDOWN_STEPS.TWO
            -- self.countdown:animate(CONSTANTS.WEEKS.COUNTDOWN_ANIMS[3])
            audio.playSound(self.sounds.countdown[CONSTANTS.WEEKS.COUNTDOWN_SOUNDS[3]])
        elseif self.countdownStep == COUNTDOWN_STEPS.TWO then
            self.countdownStep = COUNTDOWN_STEPS.ONE
            -- self.countdown:animate(CONSTANTS.WEEKS.COUNTDOWN_ANIMS[2])
            audio.playSound(self.sounds.countdown[CONSTANTS.WEEKS.COUNTDOWN_SOUNDS[2]])
        elseif self.countdownStep == COUNTDOWN_STEPS.ONE then
            self.countdownStep = COUNTDOWN_STEPS.GO
            -- self.countdown:animate(CONSTANTS.WEEKS.COUNTDOWN_ANIMS[1])
            audio.playSound(self.sounds.countdown[CONSTANTS.WEEKS.COUNTDOWN_SOUNDS[1]])
        else
            self.countdownStep = COUNTDOWN_STEPS.AFTER
        end

        -- if we are not two, one, or go, do not set countdownFade[1] to 1
        if self.countdownStep == COUNTDOWN_STEPS.TWO or
            self.countdownStep == COUNTDOWN_STEPS.ONE or
        self.countdownStep == COUNTDOWN_STEPS.GO then
            countdownFade[1] = 1
            Timer.tween(self.conductor:getBeatLengthsMS()/1000, countdownFade, {0}, "in-out-cubic")
        else
            countdownFade[1] = 0
        end

        event = eventCreator:countdownTick(self.countdownStep)
        self.stage:call("onCountdownTick", event)
        self.song:call("onCountdownTick", event)
        if event.cancelled then
            self:pauseCountdown()
            return
        end

        if self.countdownStep == COUNTDOWN_STEPS.AFTER then
            print("Countdown finished, starting song!")
            self:stopCountdown()
            self.mayPauseGame = true

            --[[ musicTime = inst:getDuration("seconds") * 1000 - 5000 ]]
            if self.inst then self.inst:play() end
            if self.voicesBF then self.voicesBF:play() end
            if self.voicesEnemy then self.voicesEnemy:play() end

            --[[ inst:seek(musicTime / 1000)
            voicesBF:seek(musicTime / 1000)
            voicesEnemy:seek(musicTime / 1000) ]]
        end
    end, 5)
end

function weeks:update(dt)
    self.timer:update(dt)
    if self.countingDown or love.system.getOS() == "Web" then -- Source:tell() can't be trusted on love.js!\
        previousFrameTime = love.timer.getTime() * 1000
        musicTime = musicTime + 1000 * dt
    else
        if not graphics.isFading() and (self.inst and self.inst:isPlaying()) then
            local time = love.timer.getTime()
            local seconds = self.inst:isPlaying() and self.inst:tell("seconds") or musicTime / 1000

            musicTime = musicTime + (time * 1000) - previousFrameTime
            previousFrameTime = time * 1000

            if lastReportedPlaytime ~= seconds * 1000 then
                lastReportedPlaytime = seconds * 1000
                musicTime = (musicTime + lastReportedPlaytime) / 2
            end
        else
            previousFrameTime = love.timer.getTime() * 1000
        end
    end
    beatHandler.update(dt)
    self.conductor.musicTime = musicTime
    self.conductor:update(dt)

    local decayRate = 0.95
    local elapsed = dt * 60

    if camera.zoomRate > 0 then
        camera.bopMultiplier = util.lerp(1.0, camera.bopMultiplier, math.pow(decayRate, elapsed))
        local zoomPlusBop = camera.currentZoom * camera.bopMultiplier
        camera.zoom = zoomPlusBop

        uiCam.zoom = util.lerp(1, uiCam.zoom, math.pow(decayRate, elapsed))
    end

    self.stage:call("onUpdate", dt)
    self.song:call("onUpdate", dt)
    if self.conductor.onStep then
        self.stage:call("onStepHit", self.conductor.curStep)
        self.song:call("onStepHit", self.conductor.curStep)

        local MAX_RELATIVE_CAM_ZOOM = 1.35

        if camera.zooming and
            uiCam.zoom < (MAX_RELATIVE_CAM_ZOOM * 1) and
            camera.zoomRate > 0 and
            (self.conductor.curStep + (camera.zoomRateOffset or CONSTANTS.DEFAULT_ZOOM_OFFSET) * CONSTANTS.STEPS_PER_BEAT) % (camera.zoomRate * CONSTANTS.STEPS_PER_BEAT) == 0 
        then
            camera.bopMultiplier = camera.bopIntensity
            uiCam.zoom = uiCam.zoom + uiCam.bopIntensity * 1
        end
    end
    if self.conductor.onBeat then
        self.stage:call("onBeatHit", self.conductor.curBeat)
        self.song:call("onBeatHit", self.conductor.curBeat)
    end
    for _, obj in ipairs(self.objects) do
        if obj.update then
            obj:update(dt)
            if obj.call then
                obj:call("onUpdate", dt)
            end
        end

        if self.conductor.onStep and obj.onStepHit then
            obj:onStepHit(self.conductor.curStep)
            if obj.call then
                obj:call("onStepHit", self.conductor.curStep)
            end
        end

        if self.conductor.onBeat and obj.onBeatHit then
            obj:onBeatHit(self.conductor.curBeat)
            if obj.call then
                obj:call("onBeatHit", self.conductor.curBeat)
            end
            if obj.bopper then
                obj:play(obj.thefuckinganim .. obj.suffix)
            end
        end
    end

    self.boyfriendPlayfield:update(dt)
    self.enemyPlayfield:update(dt)

    if musicTime >= 0 then
        for _, event in ipairs(self.songEvents) do
            if musicTime >= event.t then
                if eventScripts[event.e] then
                    eventScripts[event.e]:on(event.t, event.v)
                end

                local processed = {name = event.e, value = event.v}
                self.stage:call("onSongEvent", processed)
                self.song:call("onSongEvent", processed)
                for _, obj in ipairs(self.objects) do
                    if obj.call then obj:call("onSongEvent", processed) end
                end

                table.remove(self.songEvents, 1)
            else
                break
            end
        end
    end

    self:updateUI(dt)
end

function weeks:updateUI(dt)
    if paused then return end

    if not self.ignoreHealthClamping then
        self.health = util.clamp(self.health, CONSTANTS.WEEKS.HEALTH.MIN, CONSTANTS.WEEKS.HEALTH.MAX)
    end
    if self.health > CONSTANTS.WEEKS.HEALTH.LOSING_THRESHOLD and self.healthbar.p2Icon:getCurFrame() == 2 then
        self.healthbar.p2Icon:setFrame(1)
    elseif self.health <= 0 and self.useBuiltinGameover then -- Game over
        if not settings.practiceMode and not self.dying then
            self.dying = true
            self:onDeath()
        end
    elseif self.health <= CONSTANTS.WEEKS.HEALTH.LOSING_THRESHOLD and self.healthbar.p2Icon:getCurFrame() == 1 then
        self.healthbar.p2Icon:setFrame(2)
    end
    self.healthLerp = util.coolLerp(self.healthLerp, self.health, 0.15)

    self.healthbar:update(dt)

    if camera.IS_CLASSIC_MOVEMENT then
        local adjustedLerp = 1 - math.pow(1.0 - 0.04, dt * 60)
        camera.x = camera.x + (CAM_LERP_POINT.x - camera.x) * adjustedLerp
        camera.y = camera.y + (CAM_LERP_POINT.y - camera.y) * adjustedLerp
    end

    for i, note in ipairs(states.nps) do
        if note - love.timer.getTime() <= -1 then
            table.remove(states.nps, i)
        end
    end
end

function weeks:calculateRating()
    if settings.accuracyMode == "complex" then
        states.ratingPercent = states.score / ((states.sickCounter + states.goodCounter + states.badCounter + states.shitCounter + states.missCounter) * 500)
        if states.ratingPercent == nil or states.ratingPercent < 0 then
            states.ratingPercent = 0
        elseif states.ratingPercent > 1 then
            states.ratingPercent = 1
        end
    else
        local sickRating = 1
        local goodRating = 0.85
        local badRating = 0.67
        local shitRating = 0.5

        local totalHit = states.sickCounter + states.goodCounter + states.badCounter + states.shitCounter + states.missCounter

        states.ratingPercent = (states.sickCounter * sickRating +
            states.goodCounter * goodRating +
            states.badCounter * badRating +
            states.shitCounter * shitRating) /
            totalHit
    end
end

function weeks:judgeNote(msTiming)
    if msTiming <= CONSTANTS.WEEKS.JUDGE_THRES[settings.judgePreset].SICK_THRES then
        return "sick"
    elseif msTiming < CONSTANTS.WEEKS.JUDGE_THRES[settings.judgePreset].GOOD_THRES then
        return "good"
    elseif msTiming < CONSTANTS.WEEKS.JUDGE_THRES[settings.judgePreset].BAD_THRES then
        return "bad"
    elseif msTiming < CONSTANTS.WEEKS.JUDGE_THRES[settings.judgePreset].SHIT_THRES then
        return "shit"
    else
        return "miss"
    end
end

function weeks:scoreNote(msTiming)
    if msTiming > CONSTANTS.WEEKS.JUDGE_THRES[settings.judgePreset].MISS_THRES then
        return CONSTANTS.WEEKS.MISS_SCORE
    else
        if msTiming < CONSTANTS.WEEKS.JUDGE_THRES[settings.judgePreset].PERFECT_THRES then
            return CONSTANTS.WEEKS.MAX_SCORE
        else
            local factor = 1 - 1 / (1 + math.exp(-CONSTANTS.WEEKS.SCORING_SLOPE * (msTiming - CONSTANTS.WEEKS.SCORING_OFFSET)))
            local score = math.floor(CONSTANTS.WEEKS.MAX_SCORE * factor + CONSTANTS.WEEKS.MIN_SCORE)
            return score
        end
    end
end

function weeks:setStageShader(shader)
    self.stageShader = shader
end

function weeks:setUIShader(shader)
    self.uiShader = shader
end

function weeks:getSongID()
    return SONGID
end

function weeks:getCamera()
    return camera
end

function weeks:getCameraLerpPoint()
    return CAM_LERP_POINT
end

function weeks:getAudio(name)
    if name == "inst" then return self.inst
    elseif name == "enemy" then return self.voicesEnemy
    elseif name == "bf" then return self.voicesBF
    end
end

function weeks:add(object, sort)
    sort = sort == nil and false or sort
    table.insert(self.objects, object)
    if object.characterType then
        self.stage:call("addCharacter", object, object.name or "")
        self.song:call("addCharacter", object, object.name or "")
    end
    if sort then
        self:sort()
    end
end

function weeks:get(name)
    for _, obj in ipairs(self.objects) do
        if obj.name == name then
            return obj
        end
    end
    return nil
end

function weeks:getProps()
    return self.objects
end

function weeks:getCharacter(name)
    name = name or "boyfriend"
    for _, obj in ipairs(self.objects) do
        if obj.characterType then
            if obj.name == name then
                return obj
            end
        end
    end
end

function weeks:remove(object, sort)
    for i, obj in ipairs(self.objects) do
        if obj == object then
            table.remove(self.objects, i)
            return
        end
    end

    if sort then
        self:sort()
    end
end

function weeks:sort()
    table.sort(self.objects, function(a, b)
        return (a.zIndex or 0) < (b.zIndex or 0)
    end)
end

function weeks:cancelCameraZoomTween()
    if camZoomTween then
        Timer.cancel(camZoomTween)
        camZoomTween = nil
    end
end

function weeks:checkSongOver()
    if musicTime >= math.floor(self.inst:getDuration("seconds") * 1000)-10 and not self.songEnded then
        self.songEnded = true
        self:endSong()
    end
end

function weeks:endSong()
end

function weeks:onDeath()
    if quitPressed then return end
    if self.camTween then Timer.cancel(self.camTween) end
    if self.inst then self.inst:stop() end
    if self.voicesBF then self.voicesBF:stop() end
    if self.voicesEnemy then self.voicesEnemy:stop() end
    Gamestate.push(gameoverSubstate)
end

function weeks:debugKeyPressed(k)
end

function weeks:renderStage()
    if not self.stageCanvas then self.stageCanvas = love.graphics.newCanvas(1280, 720) end
    local lastCanvas = love.graphics.getCanvas()

    love.graphics.setCanvas({self.stageCanvas, stencil = true})
        love.graphics.clear()
        love.graphics.push()
            love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
            love.graphics.scale(camera.zoom, camera.zoom)
            love.graphics.translate(-graphics.getWidth() / 2, -graphics.getHeight() / 2)

            for _, object in ipairs(self.objects) do
                if object.draw then
                    object:draw(camera)
                    if object.call then
                        object:call("onDraw", camera)
                    end
                end
            end
        love.graphics.pop()
    love.graphics.setCanvas({lastCanvas, stencil = true})

    local lastShader = love.graphics.getShader()
    love.graphics.setShader(self.stageShader)
    love.graphics.draw(self.stageCanvas)
    love.graphics.setShader(lastShader)
end

function weeks:drawUI()
    if not self.UI_VISIBLE then return end
	if not self.uiCanvas then self.uiCanvas = love.graphics.newCanvas(1280, 720) end

    local lastCanvas = love.graphics.getCanvas()
	love.graphics.setCanvas({self.uiCanvas, stencil = true})
        love.graphics.clear()
        love.graphics.push()
            love.graphics.translate(1280/2, 720/2)
            love.graphics.scale(0.7, 0.7)
            love.graphics.scale(uiCam.zoom, uiCam.zoom)
            love.graphics.translate(uiCam.x, uiCam.y)
            graphics.setColor(1, 1, 1)

            self.enemyPlayfield:draw()
            self.boyfriendPlayfield:draw()
        love.graphics.pop()

        love.graphics.push()
            graphics.setColor(1, 1, 1, FLASH[1])
            love.graphics.rectangle("fill", -1000, -1000, 25000, 10000)
            graphics.setColor(1, 1, 1)
        love.graphics.pop()

        self.healthbar:draw(hudFade[1])
    love.graphics.setCanvas({lastCanvas, stencil = true})
    local lastShader = love.graphics.getShader()
    love.graphics.setShader(self.uiShader)
    love.graphics.draw(self.uiCanvas)
    love.graphics.setShader(lastShader)
end

function weeks:draw()
    self:renderStage()
    self:drawUI()
end

function weeks:leave()
    if self.inst then self.inst:stop(); self.inst = false end
    if self.voicesBF then self.voicesBF:stop(); self.voicesBF = nil end
    if self.voicesEnemy then self.voicesEnemy:stop(); self.voicesEnemy = nil end

    self.timer:clear()
end

return weeks