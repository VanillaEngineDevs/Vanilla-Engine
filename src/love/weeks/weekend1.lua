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

local stageBack, stageFront, curtains

return {
	enter = function(self, from, songNum, songAppend, isErect)
		weeks:enter()

		stages["stage"]:enter()

		song = songNum
		difficulty = songAppend
		erectMode = isErect

		enemyIcon:animate("dad", false)

		self:load()
	end,

	load = function(self)
		weeks:load()
		stages["stage"]:load()

		if song == 3 then
			inst = love.audio.newSource("songs/2hot/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/2hot/Voices-bf" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/2hot/Voices-dad" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/lit-up/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/lit-up/Voices-bf" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/lit-up/Voices-dad" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
		else
			inst = love.audio.newSource("songs/darnell/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/darnell/Voices-bf" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/darnell/Voices-dad" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
		end

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()
		if song == 3 then
			weeks:generateNotes("data/songs/2hot/2hot-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/2hot/2hot-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/lit-up/lit-up-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/lit-up/lit-up-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)
		else
			weeks:generateNotes("data/songs/darnell/darnell-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/darnell/darnell-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)
		end
	end,

	update = function(self, dt)
		weeks:update(dt)
		stages["stage"]:update(dt)

		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.zoom, camera.zoom)

			stages["stage"]:draw()
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function(self)
		stages["stage"]:leave()

		enemy = nil
		boyfriend = nil
		girlfriend = nil

		graphics.clearCache()

		weeks:leave()
	end
}
