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

local difficulty

local sky, city, cityWindows, behindTrain, street
local winColors, winColor

return {
	enter = function(self, from, songNum, songAppend)
		pauseColor = {131, 19, 73}
		weeks:enter()
		stages["city"]:enter()

		week = 3

		song = songNum
		difficulty = songAppend

		cam.sizeX, cam.sizeY = 1, 1
		camScale.x, camScale.y = 1, 1

		weeks:setIcon("enemy", "pico")

		self:load()
	end,

	load = function(self)
		weeks:load()
		stages["city"]:load()

		if song == 3 then
			inst = love.audio.newSource("songs/week3/blammed/inst.ogg", "stream")
			voices = love.audio.newSource("songs/week3/blammed/voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/week3/philly-nice/inst.ogg", "stream")
			voices = love.audio.newSource("songs/week3/philly-nice/voices.ogg", "stream")
		else
			inst = love.audio.newSource("songs/week3/pico/inst.ogg", "stream")
			voices = love.audio.newSource("songs/week3/pico/voices.ogg", "stream")
		end

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("songs/week3/blammed/" .. difficulty .. ".json")
			weeks:generateEvents("songs/week3/blammed/events.json")
		elseif song == 2 then
			weeks:generateNotes("songs/week3/philly-nice/" .. difficulty .. ".json")
			weeks:generateEventsOld("songs/week3/philly-nice/events.json")
		else
			weeks:generateNotes("songs/week3/pico/" .. difficulty .. ".json")
		end
	end,

	update = function(self, dt)
		weeks:update(dt)
		stages["city"]:update(dt)	

		if health >= 80 then
			if enemyIcon:getAnimName() == "pico" then
				weeks:setIcon("enemy", "pico losing")
			end
		else
			if enemyIcon:getAnimName() == "pico losing" then
				weeks:setIcon("enemy", "pico")
			end
		end

		if not (countingDown or graphics.isFading()) and not (inst:isPlaying() and voices:isPlaying()) and not paused then
			if storyMode and song < 3 then
				if score > highscores[weekNum-1].scores[song] then
					highscores[weekNum-1].scores[song] = score
					saveHighscores()
				end
				newAccuracy = convertedAcc:gsub("%%", "")
				if tonumber(newAccuracy) > highscores[weekNum-1].accuracys[song] then
					highscores[weekNum-1].accuracys[song] = tonumber(newAccuracy)
					saveHighscores()
				end
				song = song + 1

				self:load()
			else
				status.setLoading(true)

				graphics.fadeOut(
					0.5,
					function()
						Gamestate.switch(menu)

						status.setLoading(false)
					end
				)
			end
		end

		weeks:updateUI(dt)
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(extraCamZoom.sizeX, extraCamZoom.sizeY)
			love.graphics.scale(cam.sizeX, cam.sizeY)
			love.graphics.scale(camZoom.sizeX, camZoom.sizeY)

			stages["city"]:draw()

			weeks:drawRating(0.9)
		love.graphics.pop()
		weeks:drawTimeLeftBar()
		weeks:drawHealthBar()
		if not paused then

			weeks:drawUI()
		end
	end,

	leave = function(self)
		stages["city"]:leave()
		weeks:leave()
	end
}
