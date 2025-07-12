---@diagnostic disable: undefined-doc-class, missing-parameter
---@class Sound : Basic
local Sound = Basic:extend()

function Sound:new()
    Basic.new(self)

    self:revive()
    self.visible, self.cameras = nil, nil
    self._label = ""
end

function Sound:revive()
	self:reset(true)
	self.volume = 1
	self.pitch = 1
	self.duration = 0
	self.wasPlaying = false
	Basic.revive(self)
end

---@param cleanup boolean
function Sound:reset(cleanup)
    if cleanup then
		--self:cleanup()
	elseif self.source ~= nil then
		self:stop()
	end

	self.wasPlaying = false
	self.looped = false
	self.autoDestroy = false
	self.radius = 0
	self:cancelFade()
	self:setVolume(1)
	self:setPitch(1)
end

---@param duration number
---@param startVolume number
---@param endVolume number
function Sound:fade(duration, startVolume, endVolume)
	self.fadeElapsed = 0
	self.fadeDuration = duration
	self.startVolume = startVolume
	self.endVolume = endVolume
end

function Sound:cancelFade()
	self.fadeDuration = nil
end

function Sound:cleanup()
	self.active = false
	self.target = nil
	self.onComplete = nil

	if self.source ~= nil then
		self:stop()
		if self.isSource and self.source.release then
			self.source--[[@as love.Object]]:release()
		end
	end
	self.paused = true
	self.isFinishedB = false
	self.isSource = false
	self.source = nil
end

function Sound:destroy()
	Basic.destroy(self)
	self:cleanup()
end

function Sound:kill()
	Basic.kill(self)
	self:reset(self.autoDestroy)
end

---@param asset string
---@param autoDestroy boolean
---@param onComplete function
function Sound:load(asset, autoDestroy, onComplete)
	if asset == nil then return end

	self.isSource = type(asset) ~= "userdata"
	self.source = self.isSource and love.audio.newSource(asset, "stream") or asset
	return self:init(autoDestroy, onComplete)
end

---@param autoDestroy boolean
---@param onComplete function
function Sound:init(autoDestroy, onComplete)
	if autoDestroy ~= nil then self.autoDestroy = autoDestroy end
	if onComplete ~= nil then self.onComplete = onComplete end

	self.active = true

	if self.source then
		self.duration = self.source--[[@as love.Source]]:getDuration()
	end

	return self
end

---@param volume number
---@param looped boolean
---@param pitch number
---@param restart boolean
function Sound:play(volume, looped, pitch, restart)
	if not self.active or not self.source then return self end

	if restart then
		pcall(self.source.stop, self.source)
	elseif self:isPlaying() then
		return self
	end

	self.paused = false
	self.isFinishedB = false
	self:setVolume(volume)
	self:setLooping(looped)
	self:setPitch(pitch)
	pcall(self.source.play, self.source)
	return self
end

function Sound:playAtTime(looped, time)
	if not self.active or not self.source then return self end

	if self:isPlaying() then
		return self
	end

	self.paused = false
	self.isFinishedB = false
	self:setLooping(looped)
	self:seek(time/1000)
	pcall(self.source.play, self.source)
	return self
end

---@param startTime number
function Sound:startSound(startTime)
    if not self.active or not self.source then return self end

    self.paused = false
    self.isFinishedB = false
    self:setVolume()
    self:setLooping()
    self:setPitch()
    self:seek(startTime/1000)
    pcall(self.source.play, self.source)
    return self
end

function Sound:pause()
	self.paused = true
	if self.source then pcall(self.source.pause, self.source) end
	return self
end

function Sound:resume()
	self.paused = false
	if self.source then pcall(self.source.play, self.source) end
	return self
end

function Sound:stop()
	self.paused = true
	if self.source then pcall(self.source.stop, self.source) end
	return self
end

---@param dt number
function Sound:update(dt)
	local isFinished = self:isFinished()
	if isFinished and not self.isFinishedB then
		local onComplete = self.onComplete
		if self.autoDestroy then
			self:kill()
		else
			self:stop()
		end

		if onComplete then onComplete() end
	end

	self.isFinishedB = isFinished

	if self.fadeDuration then
		self.fadeElapsed = self.fadeElapsed + dt
		if self.fadeElapsed < self.fadeDuration then
			self:setVolume(math.lerp(self.startVolume, self.endVolume, self.fadeElapsed / self.fadeDuration))
		else
			self:setVolume(self.endVolume)
			self.fadeStartTime, self.fadeDuration, self.startVolume, self.endVolume = nil, nil, nil, nil
		end
	end
end

function Sound:isPlaying()
	if not self.source then return false end
	local success, playing = pcall(self.source.isPlaying, self.source)
	return success and playing
end

function Sound:isFinished()
	return self.active and not self.paused and not self:isPlaying() and
		not self:isLooping()
end

function Sound:tell()
	if not self.source then return 0 end
	local success, position = pcall(self.source.tell, self.source)
	return success and position or 0
end

---@param position number
function Sound:seek(position)
	if not self.source then return false end
	return pcall(self.source.seek, self.source, position)
end

function Sound:getDuration()
	if not self.source then return -1 end
	local success, duration = pcall(self.source.getDuration, self.source)
	return success and duration or -1
end

---@param volume number
function Sound:setVolume(volume)
	self.volume = volume or self.volume
	if not self.source then return false end
	return pcall(self.source.setVolume, self.source, self:getActualVolume())
end

function Sound:getActualVolume()
	local vol = self.volume
	if type(vol) ~= "number" then self.volume = 1; vol = 1 end
	return vol * (Game.sound.mute and 0 or 1) * (Game.sound.volume or 1)
end

function Sound:getVolume() return self.volume end

---@param pitch number
function Sound:setPitch(pitch)
	self.pitch = pitch or self.pitch
	if not self.source then return false end
	return pcall(self.source.setPitch, self.source, self:getActualPitch())
end

function Sound:getActualPitch()
	return self.pitch * (Game.sound.pitch or 1)
end

function Sound:getPitch() return self.pitch end

---@param loop? boolean
function Sound:setLooping(loop)
	if not self.source then return false end
	return pcall(self.source.setLooping, self.source, loop or false)
end

function Sound:isLooping()
	if not self.source then return end
	local success, loop = pcall(self.source.isLooping, self.source)
	if success then return loop end
end

return Sound