local PUPIL_STATE_NORMAL = 0
local PUPIL_STATE_LEFT = 1

local pupilState = PUPIL_STATE_NORMAL

local abot, abotViz, stereoBG, eyeWhites, pupil

local muzzleFlash

local shootTimes = {}
local shootDirs = {}

function Character:postCreate()
    self.data.x = self.data.x + 230
    self.data.y = self.data.y + 60

    stereoBG = graphics.newSparrowAtlas()
    stereoBG:load(EXTEND_LIBRARY("shared:characters/abot/stereoBG", false))
    eyeWhites = graphics.newSparrowAtlas()
    eyeWhites:load("#FFFFFF")
    eyeWhites.scale.x = 120
    eyeWhites.scale.y = 60

    pupil = graphics.newTextureAtlas()
    pupil:load(EXTEND_LIBRARY("shared:characters/abot/systemEyes", true))
    pupil.x = self.data.x
    pupil.y = self.data.y
    pupil.zIndex = self.data.zIndex - 5
    pupil:playSymbol("", true, false, 18)
    pupil.onFrameChange:connect(function(_, frameNumber, _)
        if frameNumber == 17 then
            pupil:pause()
        end
    end)
    pupil.onAnimationFinished:connect(function(name)
        pupil:pause()
    end)

    abot = graphics.newTextureAtlas()
    abot:load(EXTEND_LIBRARY("shared:characters/abot/abotSystem", true))

    abot:playSymbol("", true, false, 1)

    --[[ muzzleFlash = new FunkinSprite(0, 0);
    muzzleFlash.frames = Paths.getSparrowAtlas("characters/otis/muzzle-flashes/otis_flashes", "shared");
    muzzleFlash.animation.addByPrefix('shoot1', 'shoot back0', 24, false);
    muzzleFlash.animation.addByPrefix('shoot2', 'shoot back low0', 24, false);
    muzzleFlash.animation.addByPrefix('shoot3', 'shoot forward0', 24, false);
    muzzleFlash.animation.addByPrefix('shoot4', 'shoot forward low0', 24, false);]]
    muzzleFlash = graphics.newSparrowAtlas()
    muzzleFlash:load(EXTEND_LIBRARY("shared:characters/otis/muzzle-flashes/otis_flashes", false))
    muzzleFlash:addAnimByPrefix("shoot1", "shoot back0", 24, false)
    muzzleFlash:addAnimByPrefix("shoot2", "shoot back low0", 24, false)
    muzzleFlash:addAnimByPrefix("shoot3", "shoot forward0", 24, false)
    muzzleFlash:addAnimByPrefix("shoot4", "shoot forward low0", 24, false)

    muzzleFlash.onAnimationFinished:connect(function(name)
        self:updateMuzzle()
    end)

    self:initTimemap()
end

function Character:updateMuzzle()
    muzzleFlash.visible = false
end

function Character:dance(force)
    if abot then
        abot:playSymbol("", true, false, 1)
    end
    self.data:dance(force)
end

local refreshed = false

function Character:initTimemap()
    shootTimes = {}
    shootDirs = {}

    local animNotes = weeks:getChart().notes["picospeaker"]
    if not animNotes then
        print("NO PICOSPEAKER CHART")
    end

    table.sort(animNotes, function (a, b)
        return a.t < b.t
    end)

    for _, note in ipairs(animNotes) do
        print("Added shoot note at time " .. note.t .. " with direction " .. note.d)
        table.insert(shootTimes, note.t)
        table.insert(shootDirs, note.d)
    end
end

function Character:onUpdate(dt)
    if not refreshed then
        abot.x = self.data.x - 150 - (-self.data.offsets[1])
        abot.y = self.data.y + 115 - (-self.data.offsets[2])
        abot.zIndex = self.data.zIndex - 10
        weeks:add(abot)

        -- abotViz

        eyeWhites.x = abot.x + 40
        eyeWhites.y = abot.y + 250
        eyeWhites.zIndex = abot.zIndex - 10
        weeks:add(eyeWhites)

        pupil.x = abot.x + 60
        pupil.y = abot.y + 238
        pupil.zIndex = eyeWhites.zIndex + 5
        weeks:add(pupil)

        stereoBG.x = abot.x + 150
        stereoBG.y = abot.y + 30
        stereoBG.zIndex = eyeWhites.zIndex - 8
        weeks:add(stereoBG)

        muzzleFlash.zIndex = self.data.zIndex - 1
        weeks:add(muzzleFlash)

        abot.shader = self.data.shader
        eyeWhites.shader = self.data.shader
        pupil.shader = self.data.shader
        stereoBG.shader = self.data.shader

        weeks:sort()

        refreshed = true
    end

    while #shootTimes > 0 and (shootTimes[1] or -1000) <= weeks.conductor.musicTime do
        table.remove(shootTimes, 1)
        local nextDir = table.remove(shootDirs, 1)

        self:playPicoAnimation(nextDir)
    end
end

function Character:playPicoAnimation(dir)
    --muzzleFlash.visible = true
    if dir == 0 then
        self.data:play("shoot1", true, false)
        --[[ muzzleFlash.x, muzzleFlash.y = self.data.x + 550, self.data.y - 300
        muzzleFlash:play("shoot1", true, false) ]]
    elseif dir == 1 then
        self.data:play("shoot2", true, false)
        --[[ muzzleFlash.x, muzzleFlash.y = self.data.x + 950, self.data.y - 50
        muzzleFlash:play("shoot2", true, false) ]]
    elseif dir == 2 then
        self.data:play("shoot3", true, false)
        --[[  muzzleFlash.x, muzzleFlash.y = self.data.x - 350, self.data.y - 50
        muzzleFlash:play("shoot3", true, false) ]]
    elseif dir == 3 then
        self.data:play("shoot4", true, false)
        --[[ muzzleFlash.x, muzzleFlash.y = self.data.x - 350, self.data.y - 100
        muzzleFlash:play("shoot4", true, false) ]]
    end
end

function Character:onSongEvent(event)
    if event.name == "FocusCamera" then
        local char = tonumber(event.value.char or "0") or 0
        if char == 0 and pupilState ~= PUPIL_STATE_NORMAL then
            pupil:playSymbol("", true, false, 17) -- look right
            pupilState = PUPIL_STATE_NORMAL
        elseif char == 1 and pupilState ~= PUPIL_STATE_LEFT then
            pupil:playSymbol("", true, false, 0) -- look left
            pupilState = PUPIL_STATE_LEFT
        end
    end
end
