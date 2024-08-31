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
	enter = function(self, from, songNum, songAppend, isErect)
		weeks:enter()

		stages["hauntedHouse"]:enter()

		song = songNum
		difficulty = songAppend
		erectMode = isErect

		camera.zoom = 1.1
		camera.defaultZoom = 1.1

		sounds["thunder"] = {
			love.audio.newSource("sounds/week2/thunder1.ogg", "static"),
			love.audio.newSource("sounds/week2/thunder2.ogg", "static")
		}

		self:load()
	end,

	load = function(self)
		if song == 3 then
			enemy = BaseCharacter("sprites/characters/monster.lua")

			enemy.x, enemy.y = -610, 120

			enemyIcon = icon.newIcon(icon.imagePath("monster"))

			inst = love.audio.newSource("songs/monster/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/monster/Voices-bf" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/monster/Voices-monster" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/south/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/south/Voices-bf" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/south/Voices-spooky" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
		else
			inst = love.audio.newSource("songs/spookeez/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/spookeez/Voices-bf" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/spookeez/Voices-spooky" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
		end
		
		weeks:load()
		stages["hauntedHouse"]:load()

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/songs/monster/monster-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/monster/monster-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/south/south-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/south/south-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)
		else
			weeks:generateNotes("data/songs/spookeez/spookeez-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/spookeez/spookeez-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)
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
