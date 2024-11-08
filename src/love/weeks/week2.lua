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

		stage = stages["hauntedHouse.base"]

		if _songExt == "-erect" or _songExt == "-pico" then
			stage = stages["hauntedHouse.erect"]
		end

		stage:enter()

		song = songNum
		difficulty = songAppend
		songExt = _songExt
		audioAppend = _audioAppend

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

			inst = love.audio.newSource("songs/monster/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/monster/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/monster/Voices-monster" .. songExt .. ".ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/south/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/south/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/south/Voices-spooky" .. songExt .. ".ogg", "stream")
		else
			inst = love.audio.newSource("songs/spookeez/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/spookeez/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/spookeez/Voices-spooky" .. songExt .. ".ogg", "stream")
		end
		
		weeks:load()
		stage:load()

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/songs/monster/monster-chart" .. songExt .. ".json", "data/songs/monster/monster-metadata" .. songExt .. ".json", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/south/south-chart" .. songExt .. ".json", "data/songs/south/south-metadata" .. songExt .. ".json", difficulty)
		else
			weeks:generateNotes("data/songs/spookeez/spookeez-chart" .. songExt .. ".json", "data/songs/spookeez/spookeez-metadata" .. songExt .. ".json", difficulty)
		end
	end,

	update = function(self, dt)
		weeks:update(dt)
		stage:update(dt)

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

			stage:draw()
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function(self)
		graphics.clearCache()

		weeks:leave()
	end
}
