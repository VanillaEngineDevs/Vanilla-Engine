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
	enter = function(self, from, songNum, songAppend)
		weeks:enter()

		stages["stage"]:enter()

		song = songNum
		difficulty = songAppend

		enemyIcon:animate("dad", false)

		self:load()
	end,

	load = function(self)
		weeks:load()
		stages["stage"]:load()

		if song == 3 then
			inst = love.audio.newSource("songs/dadbattle/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/dadbattle/Voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/fresh/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/fresh/Voices.ogg", "stream")
		else
			inst = love.audio.newSource("songs/bopeebo/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/bopeebo/Voices.ogg", "stream")
		end

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/songs/dadbattle/dadbattle-chart.json", "data/songs/dadbattle/dadbattle-metadata.json", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/fresh/fresh-chart.json", "data/songs/fresh/fresh-metadata.json", difficulty)
		else
			weeks:generateNotes("data/songs/bopeebo/bopeebo-chart.json", "data/songs/bopeebo/bopeebo-metadata.json", difficulty)
		end
	end,

	update = function(self, dt)
		weeks:update(dt)
		stages["stage"]:update(dt)

		if song == 1 and musicThres ~= oldMusicThres and math.fmod(absMusicTime + 500, 480000 / bpm) < 100 then
			boyfriend:animate("hey", false)
		end

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
