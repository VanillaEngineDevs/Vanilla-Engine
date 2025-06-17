---@class SoundManager
local SoundManager = {}
SoundManager.list = Group()
SoundManager.music = nil

SoundManager.mute = false
SoundManager.volume = 1
SoundManager.pitch = 1

---@param asset (string|love.Source)
---@param autoDestroy? boolean
---@param ... any
function SoundManager.load(asset, autoDestroy, ...)
	if autoDestroy == nil then autoDestroy = true end
	return SoundManager.list:recycle(Sound):load(asset, autoDestroy, ...)
end

---@param asset (string|love.Source)
---@param volume? number
---@param looped? boolean
---@param autoDestroy? boolean
---@param onComplete? function
---@param ... any
function SoundManager.play(asset, volume, looped, autoDestroy, onComplete, ...)
	return SoundManager.load(asset, autoDestroy, onComplete):play(volume, looped, ...)
end

---@param asset (string|love.Source)
function SoundManager.loadMusic(asset)
	local music = SoundManager.music
	if not music then
		music = Sound()
		music.persist = true
		SoundManager.music = music
		SoundManager.list:add(music)
	end

	return music:load(asset)
end

---@param asset (string|love.Source)
---@param volume? number
---@param looped? boolean
---@param ... any
function SoundManager.playMusic(asset, volume, looped, ...)
	if looped == nil then looped = true end
	return SoundManager.loadMusic(asset):play(volume, looped, ...)
end

---@param dt number
function SoundManager.update(dt)
	SoundManager.list:update(dt)
end

---@param mute boolean
---@param volume number
---@param pitch number
function SoundManager:adjust(mute, volume, pitch)
	SoundManager.mute, SoundManager.volume = mute, volume
	SoundManager.pitch = pitch
end

---@param mute boolean
function SoundManager.setMute(mute)
	SoundManager.mute = mute
end

---@param volume number
function SoundManager.setVolume(volume)
	SoundManager.volume = volume
end

---@param pitch number
function SoundManager.setPitch(pitch)
	SoundManager.pitch = pitch
end

---@param force boolean
function SoundManager.destroy(force)
	table.remove(SoundManager.list.members, function(t, i)
		local sound = t[i]
		if force or not sound.persist then
			sound:destroy()
			return true
		end
	end)
end

---@param path string
function SoundManager.cache(path)
	SoundManager.load(path, false)
end

return SoundManager
