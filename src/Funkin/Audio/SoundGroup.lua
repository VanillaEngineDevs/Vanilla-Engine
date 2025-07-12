---@class SoundGroup : Group
local SoundGroup = Group:extend()

function SoundGroup:new()
    self.time = 0
    self.volume = 1
    self.muted = false
    self.pitch = 1
    self.playing = true

    Group.new(self)
end

---@deprecated Use add() instead")
---@param song string
---@return SoundGroup
function SoundGroup:build(song, files)
    local result = SoundGroup()

    if files == nil then
        result:add(FunkinSound())
        return result
    end

    for _, sndFile in ipairs(files) do
        print("Loading sound: " .. sndFile)
        local snd = FunkinSound:load(Paths.voices(song, sndFile))
        result:add(snd)
    end

    return result
end
  
---@param targetTime number
---@return number
function SoundGroup:checkSyncError(targetTime)
    local error = 0

    self:forEachAlive(function(snd)
        if targetTime == nil then
            targetTime = snd.time
        else
            local diff = snd.time - targetTime
            if math.abs(diff) > math.abs(error) then
                error = diff
            end
        end
    end)

    return error
end

---@param sound FunkinSound
---@return (FunkinSound|nil)
function SoundGroup:add(sound)
    local result = Group.add(self, sound)

    if result == nil then return nil end

    result.time = self.time

    result.onComplete = function()
        self:onComplete()
    end

    result.pitch = self.pitch
    result.volume = self.volume

    return result
end

function SoundGroup:onComplete() -- Override
end

function SoundGroup:pause()
    self:forEachAlive(function(snd)
        snd:pause()
        self.playing = false
    end)
end

function SoundGroup:play(forceRestart, startTime, endTime)
    self:forEachAlive(function(snd)
        snd:play(forceRestart, startTime or 0, endTime)
        self.playing = true
    end)
end

function SoundGroup:resume()
    self:forEachAlive(function(snd)
        snd:resume()
        self.playing = true
    end)
end

function SoundGroup:fadeIn(duration, to, onComplete)
    self:forEachAlive(function(snd)
        snd:fadeIn(duration, to or 1, onComplete)
    end)
end

function SoundGroup:fadeOut(duration, to, onComplete)
    self:forEachAlive(function(snd)
        snd:fadeOut(duration, to or 0, onComplete)
    end)
end

function SoundGroup:stop()
    self:forEachAlive(function(snd)
        snd:stop()
        self.playing = false
    end)
end

function SoundGroup:clear()
    self:stop()
    Group.clear(self)
end

function SoundGroup:get_time()
    local firstAlive = self:getFirstAlive()
    if firstAlive then
        return firstAlive.time
    else
        return 0
    end
end

function SoundGroup:set_time(time)
    self.time = time
    self:forEachAlive(function(snd)
        snd.time = time
    end)
end

function SoundGroup:forEachAlive(callback)
    for _, snd in ipairs(self.members) do
        if snd.alive then
            callback(snd)
        end
    end
end

function SoundGroup:getFirstAlive()
    for _, snd in ipairs(self.members) do
        if snd.alive then
            return snd
        end
    end
end

return SoundGroup