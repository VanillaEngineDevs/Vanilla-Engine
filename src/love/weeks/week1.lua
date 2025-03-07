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

local stage

return {
	enter = function(self, from, songNum, songAppend, _songExt, _audioAppend)
		weeks:enter()

		stage = stages["stage.base"]

		if _songExt == "-erect" or _songExt == "-pico" then
			stage = stages["stage.erect"]
		end

		stage:enter(_songExt)

		song = songNum
		difficulty = songAppend
		songExt = _songExt
		audioAppend = _audioAppend

		self:load()
	end,

	load = function(self)
		weeks:load()
		stage:load()

		if song == 3 then
			inst = love.audio.newSource("songs/dadbattle/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/dadbattle/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/dadbattle/Voices-dad" .. songExt .. ".ogg", "stream")
			if girlfriend.name == "nene" then
				girlfriend.soundData = love.sound.newSoundData("songs/dadbattle/Inst" .. songExt .. ".ogg")
				girlfriend.multiplier = 3
			end
		elseif song == 2 then
			inst = love.audio.newSource("songs/fresh/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/fresh/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/fresh/Voices-dad" .. songExt .. ".ogg", "stream")
			if girlfriend.name == "nene" then
				girlfriend.soundData = love.sound.newSoundData("songs/fresh/Inst" .. songExt .. ".ogg")
				girlfriend.multiplier = 3
			end
		else
			inst = love.audio.newSource("songs/bopeebo/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/bopeebo/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/bopeebo/Voices-dad" .. songExt .. ".ogg", "stream")
			if girlfriend.name == "nene" then
				girlfriend.soundData = love.sound.newSoundData("songs/bopeebo/Inst" .. songExt .. ".ogg")
				girlfriend.multiplier = 3
			end
		end

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()
		if song == 3 then
			weeks:generateNotes("data/songs/dadbattle/dadbattle-chart" .. songExt .. ".json", "data/songs/dadbattle/dadbattle-metadata" .. songExt .. ".json", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/fresh/fresh-chart" .. songExt .. ".json", "data/songs/fresh/fresh-metadata" .. songExt .. ".json", difficulty)
		else
			weeks:generateNotes("data/songs/bopeebo/bopeebo-chart" .. songExt .. ".json", "data/songs/bopeebo/bopeebo-metadata" .. songExt .. ".json", difficulty)
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

		enemy = nil
		boyfriend = nil
		girlfriend = nil

		graphics.clearCache()

		weeks:leave()
	end
}
