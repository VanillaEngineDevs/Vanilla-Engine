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

local sky, city, cityWindows, behindTrain, street

return {
	enter = function(self, from, songNum, songAppend, isErect)
		weeks:enter()

		stages["city"]:enter()

		song = songNum
		difficulty = songAppend
		hasErect = isErect

		camera.zoom = 1
		camera.defaultZoom = 1

		enemyIcon:animate("pico", false)

		self:load()
	end,

	load = function(self)
		weeks:load()
		stages["city"]:load()

		if song == 3 then
			inst = love.audio.newSource("songs/blammed/Inst" .. (hasErect and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/blammed/Voices-bf" .. (hasErect and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/blammed/Voices-pico" .. (hasErect and "-erect" or "") .. ".ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/philly/Inst" .. (hasErect and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/philly/Voices-bf" .. (hasErect and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/philly/Voices-pico" .. (hasErect and "-erect" or "") .. ".ogg", "stream")
		else
			inst = love.audio.newSource("songs/pico/Inst" .. (hasErect and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/pico/Voices-bf" .. (hasErect and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/pico/Voices-pico" .. (hasErect and "-erect" or "") .. ".ogg", "stream")
		end

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/songs/blammed/blammed-chart" .. (hasErect and "-erect" or "") .. ".json", "data/songs/blammed/blammed-metadata" .. (hasErect and "-erect" or "") .. ".json", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/philly/philly-chart" .. (hasErect and "-erect" or "") .. ".json", "data/songs/philly/philly-metadata" .. (hasErect and "-erect" or "") .. ".json", difficulty)
		else
			weeks:generateNotes("data/songs/pico/pico-chart" .. (hasErect and "-erect" or "") .. ".json", "data/songs/pico/pico-metadata" .. (hasErect and "-erect" or "") .. ".json", difficulty)
		end
	end,

	update = function(self, dt)
		weeks:update(dt)
		stages["city"]:update(dt)

		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

	draw = function(self)
		local curWinColor = winColors[winColor]

		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.zoom, camera.zoom)

			stages["city"]:draw()
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function(self)
		stages["city"]:leave()

		graphics.clearCache()

		weeks:leave()
	end
}
