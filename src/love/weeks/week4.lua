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

local sunset

local bgLimo, limoDancer, limo

return {
	enter = function(self, from, songNum, songAppend, isErect)
		weeks:enter()

		stages["sunset"]:enter()

		song = songNum
		difficulty = songAppend
		erectMode = isErect

		enemyIcon:animate("mommy mearest", false)

		self:load()
	end,

	load = function(self)
		weeks:load()
		stages["sunset"]:load()

		if song == 3 then
			inst = love.audio.newSource("songs/milf/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/milf/Voices-bf" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/milf/Voices-mom" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/high/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/high/Voices-bf" .. (erectMode and "-car-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/high/Voices-mom" .. (erectMode and "-car-erect" or "") .. ".ogg", "stream")
		else
			inst = love.audio.newSource("songs/satin-panties/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/satin-panties/Voices-bf" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/satin-panties/Voices-mom" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
		end

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/songs/milf/milf-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/milf/milf-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/high/high-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/high/high-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)
		else
			weeks:generateNotes("data/songs/satin-panties/satin-panties-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/satin-panties/satin-panties-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)
		end
	end,

	update = function(self, dt)
		weeks:update(dt)
		stages["sunset"]:update(dt)

		-- Hardcoded M.I.L.F camera scaling
		if song == 3 and musicTime > 56000 and musicTime < 67000 and musicThres ~= oldMusicThres and math.fmod(absMusicTime, 60000 / bpm) < 100 then
			if camScaleTimer then Timer.cancel(camScaleTimer) end
			if uiScaleTimer then Timer.cancel(uiScaleTimer) end

			camScaleTimer = Timer.tween((60 / bpm) / 16, camera, {zoom = camera.zoom * 1.05}, "out-quad", function() camScaleTimer = Timer.tween((60 / bpm), camera, {zoom = camera.defaultZoom}, "out-quad") end)

			uiScaleTimer = Timer.tween((60 / bpm) / 16, uiScale, {zoom = uiScale.zoom * 1.03}, "out-quad", function() camScaleTimer = Timer.tween((60 / bpm), uiScale, {x = 1, y = 1}, "out-quad") end)
			camera.zooming = false
		elseif song == 3 and musicTime > 67000 then 
			camera.zooming = true
		end

		if not camera.zooming then 
			camera.zoom = util.lerp(camera.defaultZoom, camera.zoom, util.clamp(1 - (dt * 3.125), 0, 1))
			uiScale.zoom = util.lerp(1, uiScale.zoom, util.clamp(1 - (dt * 3.125), 0, 1))
		end -- so the camera actually unzooms

		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.zoom, camera.zoom)

			stages["sunset"]:draw()
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function()
		stages["sunset"]:leave()

		graphics.clearCache()

		weeks:leave()
	end
}
