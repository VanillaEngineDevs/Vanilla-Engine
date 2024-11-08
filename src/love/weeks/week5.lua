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

__scaryIntro = false

return {
	enter = function(self, from, songNum, songAppend, _songExt, _audioAppend)
		weeks:enter()

		stages["mall.base"]:enter()

		camera.zoom = 0.7
		camera.defaultZoom = 0.7

		sounds.lightsOff = love.audio.newSource("sounds/week5/lights-off.ogg", "static")
		sounds.lightsOn = love.audio.newSource("sounds/week5/lights-on.ogg", "static")

		song = songNum
		difficulty = songAppend
		songExt = _songExt
		audioAppend = _audioAppend

		self:load()
	end,

	load = function(self)
		if song == 3 then
			camera.defaultZoom = 0.9

			if __scaryIntro then
				camera.x, camera.y = -150, 750
				camera.zoom = 2.5

				graphics.setFade(1)
			else
				camera.zoom = 0.9
			end

			enemy = BaseCharacter("sprites/characters/monster-christmas.lua")

			enemy.x, enemy.y = -780, 420

			enemyIcon = icon.newIcon(icon.imagePath("monster"))

			inst = love.audio.newSource("songs/winter-horrorland/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/winter-horrorland/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/winter-horrorland/Voices-monster" .. songExt .. ".ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/eggnog/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/eggnog/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/eggnog/Voices-parents-christmas" .. songExt .. ".ogg", "stream")
		else
			inst = love.audio.newSource("songs/cocoa/Inst.ogg", "stream")
			voicesBF = love.audio.newSource("songs/cocoa/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/cocoa/Voices-parents-christmas" .. songExt .. ".ogg", "stream")
		end
		
		weeks:load()
		stages["mall.base"]:load()


		self:initUI()

		if __scaryIntro then
			Timer.after(
				5,
				function()
					__scaryIntro = false

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
			weeks:generateNotes("data/songs/winter-horrorland/winter-horrorland-chart" .. songExt .. ".json", "data/songs/winter-horrorland/winter-horrorland-metadata" .. songExt .. ".json", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/eggnog/eggnog-chart" .. songExt .. ".json", "data/songs/eggnog/eggnog-metadata" .. songExt .. ".json", difficulty)
		else
			weeks:generateNotes("data/songs/cocoa/cocoa-chart" .. songExt .. ".json", "data/songs/cocoa/cocoa-metadata" .. songExt .. ".json", difficulty)
		end
	end,

	onNoteHit = function(self, character, noteType, rating, id) 
		-- rating is "EnemyHit" when an enemy hits it. Can be used to determine if the player hit it or the enemy hit it when needed
		-- Return "true" to not play ANY animations, return "false" or nothing to play the default animations
		if rating == "EnemyHit" then
			if noteType == "mom" then
				weeks:setAltAnims(true)
			end
		end
	end,

	update = function(self, dt)
		if not __scaryIntro then
			weeks:update(dt)
			stages["mall.base"]:update(dt)

			if not (__scaryIntro or countingDown or graphics.isFading()) and not (inst:isPlaying() and voicesBF:isPlaying()) and not paused then
				if storyMode and song < 3 then
					weeks:saveData()
					song = song + 1

					-- Winter Horrorland setup
					if song == 3 then
						__scaryIntro = true

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

			stages["mall.base"]:draw()
		love.graphics.pop()

		if not __scaryIntro then
			weeks:drawUI()
		end
	end,

	leave = function()
		walls = nil
		escalator = nil

		santa = nil

		graphics.clearCache()

		stages["mall.base"]:leave()
		weeks:leave()
	end
}
