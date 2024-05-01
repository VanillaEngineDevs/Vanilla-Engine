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

local gameCanvas, intensity

return {
	enter = function(self, from, songNum, songAppend, isErect)
		weeks:enter()

		stages["streets"]:enter()

		song = songNum
		difficulty = songAppend
		erectMode = isErect

		enemyIcon:animate("dad", false)

		gameCanvas = love.graphics.newCanvas(1280, 720)

		shaders["rain"]:send("uScale", 0.0075)
		--[[ shaders["rain"]:send("uIntensity", 0.1) ]]
		intensity = 0
		

		self:load()
	end,

	load = function(self)
		weeks:load()
		stages["streets"]:load()

		if song == 3 then
			inst = love.audio.newSource("songs/2hot/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/2hot/Voices-pico" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/2hot/Voices-darnell" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			rainShaderStartIntensity = 0.2
			rainShaderEndIntensity = 0.4
		elseif song == 2 then
			inst = love.audio.newSource("songs/lit-up/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/lit-up/Voices-pico" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/lit-up/Voices-darnell" .. (erectMode and "-erect" or "") .. ".ogg", "stream")

			rainShaderStartIntensity = 0.1
			rainShaderEndIntensity = 0.2
		else
			inst = love.audio.newSource("songs/darnell/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/darnell/Voices-pico" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/darnell/Voices-darnell" .. (erectMode and "-erect" or "") .. ".ogg", "stream")

			rainShaderStartIntensity = 0
			rainShaderEndIntensity = 0.1
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
		intensity = math.remapToRange(musicTime/1000, 0, inst:getDuration(), rainShaderStartIntensity, rainShaderEndIntensity)
		shaders["rain"]:send("uTime", love.timer.getTime())
		shaders["rain"]:send("uIntensity", intensity)
		weeks:update(dt)
		stages["streets"]:update(dt)

		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

	draw = function(self)
		love.graphics.setShader(shaders["rain"])
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.zoom, camera.zoom)

			stages["streets"]:draw()
		love.graphics.pop()
		love.graphics.setShader()

		weeks:drawUI()
	end,

	leave = function(self)
		stages["streets"]:leave()

		enemy = nil
		boyfriend = nil
		girlfriend = nil

		graphics.clearCache()

		weeks:leave()
	end
}
