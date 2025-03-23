--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten

Copyright (C) 2021  HTV04

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]

local animations = {
	"singLEFT",
	"singDOWN",
	"singUP",
	"singRIGHT",
	"singLEFT",
	"singDOWN",
	"singUP",
	"singRIGHT"
}
local stage

local inPicoCutscene = false

previousFrameTime = 0

return {
	enter = function(self, from, songNum, songAppend, _songExt, _audioAppend)
		weeks:enter()

		stage = stages["city.base"]
		if _songExt == "-erect" or _songExt == "-pico" then
			stage = stages["city.erect"]
		end

		if _songExt == "-pico" then
			--inPicoCutscene = true
		end

		stage:enter(_songExt)

		song = songNum
		difficulty = songAppend
		songExt = _songExt
		audioAppend = _audioAppend

		camera.zoom = 1
		camera.defaultZoom = 1

		self:load()
	end,

	load = function(self)
		weeks:load()
		stage:load()

		if song == 3 then
			inst = love.audio.newSource("songs/blammed/Inst" .. songExt .. ".ogg", "stream")
			if girlfriend.name == "nene" then
				girlfriend.soundData = love.sound.newSoundData("songs/blammed/Inst" .. songExt .. ".ogg")
			end
			voicesBF = love.audio.newSource("songs/blammed/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/blammed/Voices-pico-enemy" .. songExt .. ".ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/philly-nice/Inst" .. songExt .. ".ogg", "stream")
			if girlfriend.name == "nene" then
				girlfriend.soundData = love.sound.newSoundData("songs/philly-nice/Inst" .. songExt .. ".ogg")
			end
			voicesBF = love.audio.newSource("songs/philly-nice/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/philly-nice/Voices-pico-enemy" .. songExt .. ".ogg", "stream")
		else
			inst = love.audio.newSource("songs/pico/Inst" .. songExt .. ".ogg", "stream")
			if girlfriend.name == "nene" then
				girlfriend.soundData = love.sound.newSoundData("songs/pico/Inst" .. songExt .. ".ogg")
			end
			voicesBF = love.audio.newSource("songs/pico/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/pico/Voices-pico-enemy" .. songExt .. ".ogg", "stream")
		end

		self:initUI()

		if not inPicoCutscene then
			weeks:setupCountdown()
		end
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/songs/blammed/blammed-chart" .. songExt .. ".json", "data/songs/blammed/blammed-metadata" .. songExt .. ".json", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/philly-nice/philly-nice-chart" .. songExt .. ".json", "data/songs/philly-nice/philly-nice-metadata" .. songExt .. ".json", difficulty)
		else
			weeks:generateNotes("data/songs/pico/pico-chart" .. songExt .. ".json", "data/songs/pico/pico-metadata" .. songExt .. ".json", difficulty)
		end
	end,

	onNoteHit = function(self, character, noteType, rating, id)
		if noteType == "censor" then
			local animName = animations[id] .. " swear"
			character:animate(animName)
			return true
		end
	end,

	update = function(self, dt)
		weeks:update(dt)
		stage:update(dt)

		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.zoom, camera.zoom)

			stage:draw()
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function(self)
		stage:leave()

		graphics.clearCache()

		weeks:leave()
	end
}
