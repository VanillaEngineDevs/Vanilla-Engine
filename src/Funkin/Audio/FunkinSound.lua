---@class FunkinSound : Sound
FunkinSound = Sound:extend()
FunkinSound.pool = Group()
FunkinSound.MAX_VOLUME = 1

function FunkinSound:new()
    Sound.new(self)

    self.muted = false
    self._shouldPlay = false
    self._time = 0
end

function FunkinSound.construct()
    local sound = FunkinSound()

    FunkinSound.pool:add(sound)
    Game.sound.list:add(sound)

    return sound
end

---@param dt number
function FunkinSound:update(dt)
    if not self:isPlaying() and not self._shouldPlay then return end

    if self._time < 0 then
        local dtMS = dt * Constants.MS_PER_SEC
        self._time = self._time + dtMS
        if self._time >= 0 then
            Sound.play(self)
            self._shouldPlay = false
        end
    else
        Sound.update(self, dt)
    end
end

function FunkinSound:togglePlayback()
    if self:isPlaying() then
        self:pause()
    else
        self:resume()
    end

    return self
end

---@param forceRestart? boolean
---@param startTime? number
---@param endTime? number
function FunkinSound:play(forceRestart, startTime, endTime)
    local startTime = startTime or 0
    if not self.exists then return self end

    if forceRestart then
        --self:cleanup()
    elseif self:isPlaying() then
        return self
    end

    if startTime < 0 then
        self.active = true
        self._shouldPlay = true
        self._time = startTime
        self.endTime = endTime
        return self
    else
        if self.paused then
            self:resume()
        else
            self:startSound(startTime)
        end
    end

    self.endTime = endTime

    return self
end

function FunkinSound:pause()
    if self._shouldPlay then
        self._shouldPlay = false
        self.paused = true
        self.active = false
    else
        Sound.pause(self)
    end

    return self
end

function FunkinSound:resume()
    if self._time < 0 then
        self._shouldPlay = true
        self.paused = false
        self.active = true
    else
        Sound.resume(self)
    end
    return self
end

function FunkinSound:clone() 
    local fSound = FunkinSound()
    fSound.source = self.source--[[@as love.Source]]:clone() 

    return fSound
end

---@alias FunkinSoundPlayMusicParams {startingVolume: number, suffix: string, overrideExisting: boolean, restartTrack: boolean, loop: boolean, mapTimeChanges: boolean, pathsFunction: string, partialParams: any, onComplete: function, onLoad: function}

local params_fallback = {
    startingVolume = 1,
    suffix = "",
    overrideExisting = false,
    restartTrack = false,
    loop = true,
    mapTimeChanges =  true,
    pathsFunction = "MUSIC",
    partialParams = nil,
    onComplete = function() end,
    onLoad = function() end
}

---@param key string
---@param params? FunkinSoundPlayMusicParams
function FunkinSound:playMusic(key, params)
    local params = table.mergeWithoutOverride(params or {}, params_fallback)

    if not params.overrideExisting and (Game.sound.music and Game.sound.music.exists) then return false end

    if not params.restartTrack and (Game.sound.music and Game.sound.music.exists) then
        local existingSound = Game.sound.music
        if existingSound._label == Paths.music(key .. "/" .. key) then
            return false
        end
    end

    if Game.sound.music ~= nil then
        Game.sound.music.fadeDuration = nil
        Game.sound.music:stop()
        Game.sound.music:kill()
    end

    if params.mapTimeChanges then
        local songMusicData = SongRegistry:parseMusicData(key)
        if songMusicData ~= nil then
            Conductor:mapTimeChanges(songMusicData)
        else
            print("Tried and failed to find music metadata for " .. key)
        end
    end

    local pathsFunction = params.pathsFunction

    local suffix = params.suffix
    local pathToUse = ""
    if pathsFunction == "INST" then
        pathToUse = Paths.inst(key, suffix)
    else
        pathToUse = Paths.music(key .. "/" .. key)
    end

    local music = self:load(pathToUse, params.startingVolume, params.loop, false, true)
    music._label = pathToUse
    Game.sound.music = music
    Game.sound.music.volume = params.startingVolume or 1
    Game.sound.music:setVolume()

    music:play()
end

function FunkinSound:load(soundPath, volume, looped, autoDestroy, autoPlay, onComplete, onLoad)
    local sound = FunkinSound.pool:recycle(FunkinSound.construct)
    Sound.load(sound, soundPath, autoDestroy, onComplete)
    sound.volume = volume or 1
    sound.volume = 1
    Game.sound.list:add(sound)
    sound.loop = looped
    sound:setLooping(looped)

    if onLoad then onLoad() end

    return sound
end

function FunkinSound:playOnce(key, volume, onComplete, onLoad, important)
    local sound = self:load(key, volume or 1, false, true, true, onComplete, onLoad)
    sound:play(true)
    return sound
end

return FunkinSound