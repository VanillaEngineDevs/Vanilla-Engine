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

return {
	enter = function(self, from, songNum, songAppend, isErect)
		love.graphics.setDefaultFilter("nearest")
		weeks:enter("pixel")

		stages["school"]:enter()

		camera.defaultZoom = 0.85
		camera.zoom = 0.85

		fakeBoyfriend = love.filesystem.load("sprites/pixel/boyfriend-dead.lua")()

		fakeBoyfriend.x, fakeBoyfriend.y = 300, 190

		boyfriendIcon:animate("boyfriend (pixel)", false)
		enemyIcon:animate("senpai", false)

		pixelFont = love.graphics.newFont("fonts/pixel.fnt")

		song = songNum
		difficulty = songAppend
		hasErect = isErect

		self:load()

		musicPos = 0
	end,

	load = function(self)
		weeks:load()
		if song == 3 then
			school = love.filesystem.load("sprites/week6/evil-school.lua")()
			enemy = love.filesystem.load("sprites/week6/spirit.lua")()
			stages["evilSchool"]:enter()
			stages["evilSchool"]:load()
			stages["school"]:leave()
			enemyIcon:animate("spirit", false)
		elseif song == 2 then
			enemy = love.filesystem.load("sprites/week6/senpai-angry.lua")()

			stages["school"]:load()
		else
			enemy = love.filesystem.load("sprites/week6/senpai.lua")()
			stages["school"]:load()
		end

		if song == 3 then
			inst = love.audio.newSource("songs/thorns/Inst" .. (hasErect and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/thorns/Voices-bf" .. (hasErect and "-pixel-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/thorns/Voices-spirit" .. (hasErect and "-erect" or "") .. ".ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/roses/Inst" .. (hasErect and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/roses/Voices-bf" .. (hasErect and "-pixel-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/roses/Voices-senpai" .. (hasErect and "-angry-erect" or "") .. ".ogg", "stream")
		else
			inst = love.audio.newSource("songs/senpai/Inst" .. (hasErect and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/senpai/Voices-bf" .. (hasErect and "-pixel-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/senpai/Voices-senpai" .. (hasErect and "-erect" or "") .. ".ogg", "stream")
		end
		enemy.x, enemy.y = -340, -20

		self:initUI()
	end,

	initUI = function(self)
		weeks:initUI("pixel")

		if song == 3 then
			weeks:generateNotes("data/songs/thorns/thorns-chart" .. (hasErect and "-erect" or "") .. ".json", "data/songs/thorns/thorns-metadata" .. (hasErect and "-erect" or "") .. ".json", difficulty)
			if storyMode and not died then
				dialogue.set("data/songs/thorns/thornsDialogue.txt")
				dialogue.addSpeaker("dad", graphics.newImage(graphics.imagePath("week6/spiritFaceForward")), 400, 250, 6, 6, false)
				dialogue.setSpeakerBox("dad", love.filesystem.load("sprites/week6/scaryDialogueBox.lua")(), 650, 375, 6, 6, true, false)

				dialogue.removeSpeaker("bf")
				dialogue.removeSpeakerBox("bf")

				dialogue.setMusic(love.audio.newSource("music/pixel/LunchboxScary.ogg", "stream"))

				dialogue.setCallback(
					function()
						weeks:setupCountdown()
					end
				)
			else
				weeks:setupCountdown()
			end
		elseif song == 2 then
			weeks:generateNotes("data/songs/roses/roses-chart" .. (hasErect and "-erect" or "") .. ".json", "data/songs/roses/roses-metadata" .. (hasErect and "-erect" or "") .. ".json", difficulty)
			if storyMode and not died then
				dialogue.set("data/songs/roses/rosesDialogue.txt")
				dialogue.addSpeaker("dad", love.filesystem.load("sprites/week6/angrySenpaiBox.lua")(), 650, 375, 6, 6, true, false)
				dialogue.removeSpeakerBox("dad")

				dialogue.removeMusic()

				ANGRY_TEXT_BOX = love.audio.newSource("sounds/pixel/ANGRY_TEXT_BOX.ogg", "stream")
				ANGRY_TEXT_BOX:play()

				dialogue.setCallback(
					function()
						weeks:setupCountdown()
					end
				)
			else
				weeks:setupCountdown()
			end
		else
			weeks:generateNotes("data/songs/senpai/senpai-chart" .. (hasErect and "-erect" or "") .. ".json", "data/songs/senpai/senpai-metadata" .. (hasErect and "-erect" or "") .. ".json", difficulty)
			if storyMode and not died then
				dialogue.set("data/songs/senpai/senpaiDialogue.txt")

				dialogue.addSpeaker("dad", love.filesystem.load("sprites/week6/senpaiPortrait.lua")(), 650, 375, 6, 6, true)
				dialogue.setSpeakerBox("dad", love.filesystem.load("sprites/week6/dialogueBox.lua")(), 650, 375, 6, 6, true)

				dialogue.addSpeaker("bf", love.filesystem.load("sprites/week6/bfPortrait.lua")(), 650, 375, 6, 6, true)
				dialogue.setSpeakerBox("bf", love.filesystem.load("sprites/week6/dialogueBox.lua")(), 650, 375, 6, 6, true)

				dialogue.setMusic(love.audio.newSource("music/pixel/Lunchbox.ogg", "stream"))

				dialogue.setCallback(
					function()
						weeks:setupCountdown()
					end
				)
			else
				weeks:setupCountdown()
			end
		end
	end,

	update = function(self, dt)
		weeks:update(dt)
		if song ~= 3 then
			stages["school"]:update(dt)
		else
			stages["evilSchool"]:update(dt)
		end

		if not countingDown and not inCutscene then
		else
			previousFrameTime = love.timer.getTime() * 1000
		end

		weeks:checkSongOver()

		if inCutscene then
			dialogue.doDialogue(dt)

			if input:pressed("confirm") then
				dialogue.next()
			end
		end

		weeks:updateUI(dt)
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth()/2, graphics.getHeight()/2)
			love.graphics.scale(camera.zoom, camera.zoom)

			if song ~= 3 then
				stages["school"]:draw()
			else
				stages["evilSchool"]:draw()
			end
		love.graphics.pop()

		if inCutscene then 
			dialogue.draw()
		else
			weeks:drawUI()
		end
	end,

	leave = function(self)
		sky = nil
		school = nil
		street = nil

		graphics.clearCache()

		weeks:leave()
		stages["school"]:leave()
		stages["evilSchool"]:leave()

		love.graphics.setDefaultFilter("linear")
	end
}
