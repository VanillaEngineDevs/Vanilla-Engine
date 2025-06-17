---@class VoicesGroup : SoundGroup
local VoicesGroup = SoundGroup:extend()

function VoicesGroup:new()
    SoundGroup.new(self)
    self.playerVoices = Group()
    self.opponentVoices = Group()
    self.playerVoicesOffset = 0
    self.opponentVoicesOffset = 0

    self.playerVolume = 1
    self.opponentVolume = 1
end

function VoicesGroup:addPlayerVoice(sound)
    self:add(sound)
    self.playerVoices:add(sound)
end

function VoicesGroup:set_playerVolume(volume)
    self.playerVoices:forEachAlive(function(voice)
        voice.volume = volume
    end)
    self.playerVolume = volume
end

function VoicesGroup:set_time(time)
    self:forEachAlive(function(snd)
        snd.time = time
    end)

    self.playerVoices:forEachAlive(function(voice)
        voice.time = voice.time - self.playerVoicesOffset
    end)
    self.opponentVoices:forEachAlive(function(voice)
        voice.time = voice.time - self.opponentVoicesOffset
    end)

    return time
end

function VoicesGroup:set_playerVoicesOffset(offset)
    self.playerVoices:forEachAlive(function(voice)
        voice.time = voice.time + self.playerVoicesOffset
        voice.time = voice.time - offset
    end)
    self.playerVoicesOffset = offset
end

function VoicesGroup:set_opponentVoicesOffset(offset)
    self.opponentVoices:forEachAlive(function(voice)
        voice.time = voice.time + self.opponentVoicesOffset
        voice.time = voice.time - offset
    end)
    self.opponentVoicesOffset = offset
end

function VoicesGroup:addOpponentVoice(sound)
    self:add(sound)
    self.opponentVoices:add(sound)
end

function VoicesGroup:set_opponentVolume(volume)
    self.opponentVoices:forEachAlive(function(voice)
        voice.volume = volume
    end)
    self.opponentVolume = volume
end

function VoicesGroup:getPlayerVoice(index)
    return self.playerVoices.members[index]
end

function VoicesGroup:getOpponentVoice(index)
    return self.opponentVoices.members[index]
end

--[[ function VoicesGroup:getPlayerVoiceWaveform()
    if self.playerVoices.members.length == 0 then return nil end

    return self.playerVoices.members[1].waveformData
end

function VoicesGroup:getOpponentVoiceWaveform()
    if self.opponentVoices.members.length == 0 then return nil end

    return self.opponentVoices.members[1].waveformData
end ]]

function VoicesGroup:getPlayerVoiceLength()
    if self.playerVoices.members.length == 0 then return 0 end

    return self.playerVoices.members[1].length
end

function VoicesGroup:getOpponentVoiceLength()
    if self.opponentVoices.members.length == 0 then return 0 end

    return self.opponentVoices.members[1].length
end

function VoicesGroup:clear()
    self.playerVoices:clear()
    self.opponentVoices:clear()
    SoundGroup.clear(self)
end

function VoicesGroup:destroy()
    if self.playerVoices then
        self.playerVoices:destroy()
        self.playerVoices = nil
    end

    if self.opponentVoices then
        self.opponentVoices:destroy()
        self.opponentVoices = nil
    end

    SoundGroup.destroy(self)
end

return VoicesGroup