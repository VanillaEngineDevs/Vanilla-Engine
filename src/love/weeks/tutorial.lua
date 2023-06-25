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

local zoomTimer
local zoom = {}

return {
	enter = function(self, from, songNum, songAppend)
		weeks:enter()

		difficulty = songAppend
		song = songNum

		stageBack = graphics.newImage(graphics.imagePath("week1/stage-back"))
		stageFront = graphics.newImage(graphics.imagePath("week1/stage-front"))
		curtains = graphics.newImage(graphics.imagePath("week1/curtains"))

		stageFront.y = 400
		curtains.y = -100

		enemy = girlfriend -- For compatibility with weeks

		girlfriend.x, girlfriend.y = 30, -90
		boyfriend.x, boyfriend.y = 260, 100

		enemyIcon:animate("girlfriend", false)

		self:load()
	end,

	load = function(self)
		weeks:load()

		zoom[1] = 1

		inst = nil
		voices = love.audio.newSource("songs/tutorial/tutorial.ogg", "stream")

		self:initUI()

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		weeks:generateNotes("data/tutorial/tutorial/tutorial" .. difficulty .. ".json")
	end,

	update = function(self, dt)
		oldMusicThres = musicThres
		if countingDown or love.system.getOS() == "Web" then -- Source:tell() can't be trusted on love.js!
			musicTime = musicTime + 1000 * dt
		else
			if not graphics.isFading() then
				local time = love.timer.getTime()
				local seconds = voices:tell("seconds")

				musicTime = musicTime + (time * 1000) - previousFrameTime
				previousFrameTime = time * 1000

				if lastReportedPlaytime ~= seconds * 1000 then
					lastReportedPlaytime = seconds * 1000
					musicTime = (musicTime + lastReportedPlaytime) / 2
				end
			end
		end
		absMusicTime = math.abs(musicTime)
		musicThres = math.floor(absMusicTime / 100) -- Since "musicTime" isn't precise, this is needed

		beatHandler.update(dt)

		for i = 1, #events do
			if events[i].eventTime <= musicTime then
				local oldBpm = bpm

				if events[i].bpm then
					bpm = events[i].bpm
					if not bpm then bpm = oldBpm end
				end

				if camTimer then
					Timer.cancel(camTimer)
				end
				if zoomTimer then
					Timer.cancel(zoomTimer)
				end
				if events[i].mustHitSection then
					camTimer = Timer.tween(1.25, camera, {x = -boyfriend.x + 100, y = -boyfriend.y + 75}, "out-quad")
					zoomTimer = Timer.tween(1.25, zoom, {1}, "in-bounce")
				else
					camTimer = Timer.tween(1.25, camera, {x = -girlfriend.x - 100, y = -girlfriend.y + 75}, "out-quad")
					zoomTimer = Timer.tween(1.25, zoom, {1.25}, "in-bounce")
				end

				table.remove(events, i)

				break
			end
		end

		if (beatHandler.onBeat() and beatHandler.getBeat() % camera.camBopInterval == 0 and camera.zooming and camera.zoom < 1.35 and not camera.locked) then 
			camera.zoom = camera.zoom + 0.015 * camera.camBopIntensity
			uiScale.zoom = uiScale.zoom + 0.03 * camera.camBopIntensity
		end

		if camera.zooming and not camera.locked then 
			camera.zoom = util.lerp(camera.defaultZoom, camera.zoom, util.clamp(1 - (dt * 3.125), 0, 1))
			uiScale.zoom = util.lerp(1, uiScale.zoom, util.clamp(1 - (dt * 3.125), 0, 1))
		end
		
		girlfriend:update(dt)
		boyfriend:update(dt)

		girlfriend:beat(beatHandler.getBeat())
		boyfriend:beat(beatHandler.getBeat())

		if musicThres ~= oldMusicThres and (musicThres == 185 or musicThres == 280) then
			girlfriend:animate("cheer", false)
			boyfriend:animate("hey", false)
		end

		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.zoom * zoom[1], camera.zoom * zoom[1])

			love.graphics.push()
				love.graphics.translate(camera.x * 0.9, camera.y * 0.9)

				stageBack:draw()
				stageFront:draw()
				girlfriend:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(camera.x, camera.y)

				boyfriend:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(camera.x * 1.1, camera.y * 1.1)

				curtains:draw()
			love.graphics.pop()
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function(self)
		stageBack = nil
		stageFront = nil
		curtains = nil

		graphics.clearCache()

		weeks:leave()
	end
}
