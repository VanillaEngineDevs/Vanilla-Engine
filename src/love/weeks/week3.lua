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
	enter = function(self, from, songNum, songAppend)
		weeks:enter()

		stages["city"]:enter()

		song = songNum
		difficulty = songAppend

		camera.zoom = 1
		camera.defaultZoom = 1

		enemyIcon:animate("pico", false)

		self:load()
	end,

	load = function(self)
		weeks:load()
		stages["city"]:load()

		if song == 3 then
			inst = love.audio.newSource("songs/week3/blammed/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week3/blammed/Voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/week3/philly/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week3/philly/Voices.ogg", "stream")
		else
			inst = love.audio.newSource("songs/week3/pico/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week3/pico/Voices.ogg", "stream")
		end

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/week3/blammed/blammed" .. difficulty .. ".json")
		elseif song == 2 then
			weeks:generateNotes("data/week3/philly/philly" .. difficulty .. ".json")
		else
			weeks:generateNotes("data/week3/pico/pico" .. difficulty .. ".json")
		end
	end,

	update = function(self, dt)
		weeks:update(dt)
		stages["city"]:update(dt)

		if health >= 1.595 then
			if enemyIcon:getAnimName() == "pico" then
				enemyIcon:animate("pico losing", false)
			end
		else
			if enemyIcon:getAnimName() == "pico losing" then
				enemyIcon:animate("pico", false)
			end
		end

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
