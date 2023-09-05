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

local hauntedHouse

return {
	enter = function(self, from, songNum, songAppend)
		weeks:enter()

		stages["hauntedHouse"]:enter()

		song = songNum
		difficulty = songAppend

		camera.zoom = 1.1
		camera.defaultZoom = 1.1

		sounds["thunder"] = {
			love.audio.newSource("sounds/week2/thunder1.ogg", "static"),
			love.audio.newSource("sounds/week2/thunder2.ogg", "static")
		}

		enemyIcon:animate("skid and pump", false)

		self:load()
	end,

	load = function(self)
		weeks:load()
		stages["hauntedHouse"]:load()

		if song == 3 then
			enemy = love.filesystem.load("sprites/monster.lua")()

			enemy.x, enemy.y = -610, 120

			enemyIcon:animate("monster", false)

			inst = love.audio.newSource("songs/monster/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/monster/Voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/south/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/south/Voices.ogg", "stream")
		else
			inst = love.audio.newSource("songs/spookeez/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/spookeez/Voices.ogg", "stream")
		end

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/monster/monster" .. difficulty .. ".json")
		elseif song == 2 then
			weeks:generateNotes("data/south/south" .. difficulty .. ".json")
		else
			weeks:generateNotes("data/spookeez/spookeez" .. difficulty .. ".json")
		end
	end,

	update = function(self, dt)
		weeks:update(dt)
		stages["hauntedHouse"]:update(dt)

		if beatHandler.onBeat() then
			if enemy:getAnimName() == "idle" then
				enemy:setAnimSpeed(14.4 / (120 / bpm))
			end
		end

		weeks:checkSongOver()
		
		weeks:updateUI(dt)
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.zoom, camera.zoom)

			stages["hauntedHouse"]:draw()
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function(self)
		stages["hauntedHouse"]:leave()

		graphics.clearCache()

		weeks:leave()
	end
}
