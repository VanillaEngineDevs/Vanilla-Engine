local SaveVariables = {
    downScroll = false,
    middleScroll = false,
    opponentStrums = true,
    showFPS = true,
    flashing = true,
    autoPause = true
    splashAlpha = 0.6,
    shaders = true,
    --framerate = 60, --todo.
    camZooms = true,
    noteOffset = 0,
    ghostTapping = true,
    timeBarType = "Time Left",
    scoreZoom = true,
    noReset = false,
    healthBarAlpha = 1
    --hitSoundVolume = 0 --todo.
    pauseMusic = "breakfast",
    comboStacking = true,
    gameplaySettings = {
        scrollspeed = 1,
        scrolltype = "multiplicative",
        songspeed = 1,
        healthgain = 1,
        healthloss = 1,
        instakill = false,
        practice = false,
        botplay = false,
        opponentplay = false
    },
    comboOffset = {0,0,0,0},
    ratingoffset = 0,
    sickWindow = 45,
    goodWindow = 90,
    badWindow = 135,
    safeFrames = 10
}

local ClientPrefs = {}

ClientPrefs.data = nil
ClientPrefs.defaultData = nil