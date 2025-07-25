--[[
    A simple FFT module for LÖVE.
]]

local loveFFT = {}

function loveFFT:init(fftSize, smoothing) -- The number of samples used to calculate FFT, must be a power of 2
    if fftSize == nil then
        fftSize = 2048
    end
    local fftArray = {}
    for i = 1, fftSize/2 do fftArray[i] = 0 end
    self.fftSize = fftSize
    self.fftArray = fftArray
    self.threadFFT = love.thread.newThread("lib/fft/ffthread.lua")
    self.threadFFT:start(fftSize)
    self.channelFFT = love.thread.getChannel("fft")
    self.channelToFFT = love.thread.getChannel("toFFT")
    self.smoothing = smoothing or 0.03 -- lower = smoother, higher = more responsive
end

function loveFFT:setFFTSize(fftSize) -- Usually, avoid setting FFTSize in run time to save you from chores
    self.threadFFT:release()
    self.threadFFT = love.thread.newThread("li/fft/ffthread.lua")
    self.threadFFT:start(fftSize)
    self.channelFFT:clear()
    self.channelToFFT:clear()
end

function loveFFT:getFFTSize()
    return self.fftSize
end

function loveFFT:getFFTArray()
    return self.fftArray
end

function loveFFT:setSoundData(soundDataOrPath) -- The sound data or path to the sound data
    if type(soundDataOrPath) == "string" then
        self.soundData = love.sound.newSoundData(soundDataOrPath)
    elseif type(soundDataOrPath) == "userdata" and soundDataOrPath:typeOf("SoundData") then
        self.soundData = soundDataOrPath
    else
        error("Invalid sound data or path.\n\nWhen you use setSoundData, you should provide a path to the audio file or a SoundData object that is created using love.sound.newSoundData.")
    end
    self.sampleRate = self.soundData:getSampleRate()
    self.bitDepth = self.soundData:getBitDepth()
    self.channelCount = self.soundData:getChannelCount()
end

function loveFFT:getSoundData()
    return self.soundData
end

function loveFFT:updatePlayTime(time) -- Sync with audio playback position and start an FFT computation in a separate thread
    self.playPosition = time
    self:push()
    local err = self.threadFFT:getError()
    if err then
        error(err)
    end
end

function loveFFT:setPlayPosition(time) -- Set the audio playback position but does not start an FFT computation
    self.playPosition = time
end

function loveFFT:getPlayPosition() -- Why do you need this? Getting playback position from the Audio object is better
    return self.playPosition
end

function loveFFT:push() -- Launch a new FFT computation in a separate thread using self.playPosition. Set the position using self.updatePlayTime or self.setPlayPosition
    local sample = self.playPosition * self.sampleRate
    local toFFT = {}
    for i = 1, self.fftSize do
        toFFT[i] = 0
        for j = 1, self.channelCount do
            util.tryExcept(function() toFFT[i] = toFFT[i] + self.soundData:getSample(sample + i - 1, j) end)
        end
    end
    -- Send to thread
    self.channelToFFT:push(toFFT)
end

function loveFFT:get() -- Gets the result of an FFT computation. This function promises a non-blocking call and yields a valid list
    -- Get from thread
    if self.channelFFT:getCount() > 0 then
        self.fftArray = self.channelFFT:pop()
        return self.fftArray, true
    else
        return self.fftArray, false
    end
end

function loveFFT:release() -- Releases the thread and clears the channel. According to LOVE documentation, this is necessary on Android platforms. But based on my personal experience, it is always unnecessary to call this function
    self.threadFFT:release()
    self.channelFFT:clear()
    self.channelToFFT:clear()
end

-- Aliases
loveFFT.pop = loveFFT.get
loveFFT.destroy = loveFFT.release
loveFFT.tell = loveFFT.getPlayPosition

return loveFFT