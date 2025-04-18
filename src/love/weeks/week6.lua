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
		love.graphics.setDefaultFilter("nearest")
		weeks:enter("pixel")

		stage = stages["school.base"]
		if _songExt == "-erect" or _songExt == "-pico" then
			stage = stages["school.erect"]
		end

		stage:enter(_songExt)

		camera.defaultZoom = 0.85
		camera.zoom = 0.85

		fakeBoyfriend = BaseCharacter("sprites/characters/boyfriend-pixel-dead.lua")

		fakeBoyfriend.x, fakeBoyfriend.y = 300, 190

		pixelFont = love.graphics.newFont("fonts/pixel.fnt")

		song = songNum
		difficulty = songAppend
		songExt = _songExt
		audioAppend = _audioAppend

		self:load()

		musicPos = 0
		if settings.pixelPerfect then
			status.setNoResize(true)
			canvas = love.graphics.newCanvas(256, 144)
		end
	end,

	load = function(self)
		if song == 3 then
			school = love.filesystem.load("sprites/week6/evil-school.lua")()
			enemy = BaseCharacter("sprites/characters/spirit.lua")
			stage:leave()
			stage = stages["evilSchool.base"]
			if songExt == "-erect" or songExt == "-pico" then
				stage = stages["evilSchool.erect"]
			end
			stage:enter()
			stage:load()
		elseif song == 2 then
			enemy = BaseCharacter("sprites/characters/senpai-angry.lua")

			stage:load()
		else
			enemy = BaseCharacter("sprites/characters/senpai.lua")
			stage:load()
		end
		
		weeks:load()

		if song == 3 then
			inst = love.audio.newSource("songs/thorns/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/thorns/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/thorns/Voices-spirit" .. songExt .. ".ogg", "stream")
			if girlfriend.name == "nene" then
				girlfriend.soundData = love.sound.newSoundData("songs/bopeebo/Inst" .. songExt .. ".ogg")
				girlfriend.multiplier = 3
			end
		elseif song == 2 then
			inst = love.audio.newSource("songs/roses/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/roses/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/roses/Voices-senpai" .. songExt .. ".ogg", "stream")
			if girlfriend.name == "nene" then
				girlfriend.soundData = love.sound.newSoundData("songs/bopeebo/Inst" .. songExt .. ".ogg")
				girlfriend.multiplier = 3
			end
		else
			inst = love.audio.newSource("songs/senpai/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/senpai/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/senpai/Voices-senpai" .. songExt .. ".ogg", "stream")
			if girlfriend.name == "nene" then
				girlfriend.soundData = love.sound.newSoundData("songs/bopeebo/Inst" .. songExt .. ".ogg")
				girlfriend.multiplier = 3
			end
		end
		enemy.x, enemy.y = -440, -20

		self:initUI()
	end,

	initUI = function(self)
		weeks:initUI("pixel")

		if song == 3 then
			weeks:generateNotes("data/songs/thorns/thorns-chart" .. songExt .. ".json", "data/songs/thorns/thorns-metadata" .. songExt .. ".json", difficulty)
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
			weeks:generateNotes("data/songs/roses/roses-chart" .. songExt .. ".json", "data/songs/roses/roses-metadata" .. songExt .. ".json", difficulty)
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
			weeks:generateNotes("data/songs/senpai/senpai-chart" .. songExt .. ".json", "data/songs/senpai/senpai-metadata" .. songExt .. ".json", difficulty)
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
		if settings.pixelPerfect then
			graphics.screenBase(256, 144)
		end
		weeks:update(dt)
		stage:update(dt)

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
		local canvasScale = 1
		if settings.pixelPerfect then
			graphics.screenBase(256, 144)
			love.graphics.setCanvas(canvas)
			love.graphics.clear()
		end
		love.graphics.push()
			love.graphics.translate(graphics.getWidth()/2, graphics.getHeight()/2)
			love.graphics.scale(camera.zoom, camera.zoom)

			stage:draw()
		love.graphics.pop()

		if inCutscene then 
			dialogue.draw()
		else
			weeks:drawUI()
		end
		if settings.pixelPerfect then
			love.graphics.setCanvas()
			graphics.screenBase(love.graphics.getWidth(), love.graphics.getHeight())

			canvasScale = math.min(math.floor(graphics.getWidth() / 256), math.floor(graphics.getHeight() / 144))
			if canvasScale < 1 then canvasScale = math.min(graphics.getWidth() / 256, graphics.getHeight() / 144) end
			love.graphics.draw(canvas, graphics.getWidth() / 2, graphics.getHeight() / 2, nil, canvasScale, canvasScale, 128, 72)
		end
	end,

	leave = function(self)
		sky = nil
		school = nil
		street = nil

		graphics.clearCache()

		weeks:leave()
		stage:leave()
		status.setNoResize(false)

		love.graphics.setDefaultFilter("linear")
	end
}
