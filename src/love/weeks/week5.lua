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

local walls, escalator, christmasTree, snow

local topBop, bottomBop, santa

local scaryIntro = false

return {
	enter = function(self, from, songNum, songAppend)
		weeks:enter()

		stages["mall"]:enter()

		camera.zoom = 0.7
		camera.defaultZoom = 0.7

		sounds.lightsOff = love.audio.newSource("sounds/week5/lights-off.ogg", "static")
		sounds.lightsOn = love.audio.newSource("sounds/week5/lights-on.ogg", "static")

		song = songNum
		difficulty = songAppend

		enemyIcon:animate("dearest duo", false)

		self:load()
	end,

	load = function(self)
		weeks:load()
		stages["mall"]:load()

		if song == 3 then
			camera.defaultZoom = 0.9

			if scaryIntro then
				camera.x, camera.y = -150, 750
				camera.zoom = 2.5

				graphics.setFade(1)
			else
				camera.zoom = 0.9
			end

			enemy = love.filesystem.load("sprites/week5/monster.lua")()

			enemy.x, enemy.y = -780, 420

			enemyIcon:animate("monster", false)

			inst = love.audio.newSource("songs/week5/winter-horrorland/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week5/winter-horrorland/Voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/week5/eggnog/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week5/eggnog/Voices.ogg", "stream")
		else
			inst = love.audio.newSource("songs/week5/cocoa/Inst.ogg", "stream")
			voices = love.audio.newSource("songs/week5/cocoa/Voices.ogg", "stream")
		end

		self:initUI()

		if scaryIntro then
			Timer.after(
				5,
				function()
					scaryIntro = false

					camTimer = Timer.tween(2, camera, {x = -boyfriend.x + 100, y = -boyfriend.y + 75, sizeX = 0.9, sizeY = 0.9}, "out-quad")

					weeks:setupCountdown()
				end
			)

			audio.playSound(sounds.lightsOn)
		else
			weeks:setupCountdown()
		end
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/week5/winter-horrorland/winter-horrorland" .. difficulty .. ".json")
		elseif song == 2 then
			weeks:generateNotes("data/week5/eggnog/eggnog" .. difficulty .. ".json")
		else
			weeks:generateNotes("data/week5/cocoa/cocoa" .. difficulty .. ".json")
		end
	end,

	update = function(self, dt)
		if not scaryIntro then
			weeks:update(dt)
			stages["mall"]:update(dt)

			if song == 3 then
				if health >= 1.595 then
					if enemyIcon:getAnimName() == "monster" then
						enemyIcon:animate("monster losing", false)
					end
				else
					if enemyIcon:getAnimName() == "monster losing" then
						enemyIcon:animate("monster", false)
					end
				end
			else
				if health >= 1.595 then
					if enemyIcon:getAnimName() == "dearest duo" then
						enemyIcon:animate("dearest duo losing", false)
					end
				else
					if enemyIcon:getAnimName() == "dearest duo losing" then
						enemyIcon:animate("dearest duo", false)
					end
				end
			end

			if not (scaryIntro or countingDown or graphics.isFading()) and not (inst:isPlaying() and voices:isPlaying()) and not paused then
				if storyMode and song < 3 then
					weeks:saveData()
					song = song + 1

					-- Winter Horrorland setup
					if song == 3 then
						scaryIntro = true

						audio.playSound(sounds.lightsOff)

						graphics.setFade(0)

						Timer.after(3, function() self:load() end)
					else
						self:load()
					end
				else
					weeks:saveData()
					status.setLoading(true)

					graphics:fadeOutWipe(
					0.7,
						function()
							Gamestate.switch(menu)

							status.setLoading(false)
						end
					)
				end
			end

			weeks:updateUI(dt)
		end
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.zoom, camera.zoom)

			stages["mall"]:draw()
		love.graphics.pop()

		if not scaryIntro then
			weeks:drawUI()
		end
	end,

	leave = function()
		walls = nil
		escalator = nil

		santa = nil

		graphics.clearCache()

		stages["mall"]:leave()
		weeks:leave()
	end
}
