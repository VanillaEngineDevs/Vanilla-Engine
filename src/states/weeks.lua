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

-- Nabbed from the JS source of FNF v0.3.0 (PBOT1 Scoring)
DefaultTimeSignatureNum = 4
timeSignatureNum = DefaultTimeSignatureNum

camTween, bumpTween = nil, nil

local ratingTimers = {}

local useAltAnims

healthLerp = 1

local dying = false

noteSprites = nil

local nps = {}
maxNPS = 0

local isResetting = false
local resettingTime = {0}

UI_VISIBLE = true

local allStates = {
	sickCounter = 0,
	goodCounter = 0,
	badCounter = 0,
	shitCounter = 0,
	missCounter = 0,
	maxCombo = 0,
	score = 0
}

local function calculateScale(ws, scale)
	return (ws.x - 1) * scale.x + (ws.y - 1) * scale.y
end

local ratingTextScale = 1
local hudFade = {1}

local FLASH = {0}

local function commaFormat(n)
	local str = tostring(n)
	local x = str:find("%.")
	if x then
		str = str:sub(1, x - 1) .. str:sub(x)
	end
	return str:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

IS_CLASSIC_MOVEMENT = false
CAM_LERP_POINT = {x = 0, y = 0}
SMOOTH_RESET = true

modEvents = {}
local CURCHART = {
}

sickCounter, goodCounter, badCounter, shitCounter, missCounter, maxCombo, score = 0, 0, 0, 0, 0, 0, 0

NOTES_BATCH = nil

song = 1
difficulty = "normal"
songExt = ""
audioAppend = ""
CURRENTMODE = "normal"

local camZoomTween

local function getWife3Condition(acc)
	if acc >= 99.9935 then return 1 end -- AAAAA
	if acc >= 99.980 then return 2 end -- AAAA:
	if acc >= 99.970 then return 3 end -- AAAA.
	if acc >= 99.955 then return 4 end -- AAAA
	if acc >= 99.90 then return 5 end -- AAA:
	if acc >= 99.80 then return 6 end -- AAA.
	if acc >= 99.70 then return 7 end -- AAA
	if acc >= 99 then return 8 end -- AA:
	if acc >= 96.50 then return 9 end -- AA.
	if acc >= 93 then return 10 end -- AA
	if acc >= 90 then return 11 end -- A:
	if acc >= 85 then return 12 end -- A.
	if acc >= 80 then return 13 end -- A
	if acc >= 70 then return 14 end -- B
	if acc >= 60 then return 15 end -- C

	return 16 -- D rank or worse
end

local function getRatingName(acc)
	if acc <= 0.2 then
		return "You Suck!"
	elseif acc <= 0.4 then
		return "Shit"
	elseif acc <= 0.5 then
		return "Bad"
	elseif acc <= 0.6 then
		return "Bruh"
	elseif acc <= 0.69 then
		return "Meh"
	elseif acc <= 0.7 then
		return "Nice"
	elseif acc <= 0.8 then
		return "Good"
	elseif acc <= 0.9 then
		return "Great"
	elseif acc <= 1 then
		return "Sick!"
	else
		return "Perfect!!"
	end
end

healthBar = {
	x = -500,
	y = not settings.downscroll and 350 or -400,
	width = 1000,
	height = 25
}

downscrollOffset = 0 -- for compatibility

local healthIconPreloads = {}
local inHolds = {false, false, false, false}

local enemyNoteGameplay = {}

local scrollSpeedTweens = {}
local prevTargets = {}

speeds = {
	enemy = 1,
	boyfriend = 1
}

return {
	songs = {},

	initPositions = function(self)
		for i = 1, 4 do
			for _, note in ipairs(boyfriendNotes[i]) do
				note.initialTrackPosition = self:getPositionFromTime(note.time)
				note.latestTrackPosition = note.initialTrackPosition
				if note.children then
					note.endTrackPosition = self:getPositionFromTime(note.endTime)
				end
			end
			for _, note in ipairs(enemyNotes[i]) do
				note.initialTrackPosition = self:getPositionFromTime(note.time)
				note.latestTrackPosition = note.initialTrackPosition
				if note.children then
					note.endTrackPosition = self:getPositionFromTime(note.endTime)
				end
			end
		end
	end,
	getPositionFromTime = function(self, time)
		return time * 100
	end,
	updateCurrentTrackPosition = function(self)
		self.currentTrackPosition = self:getPositionFromTime(musicTime)
	end,
	getNotePosition = function(self, offset, initialPos, strumLineY, speed)
		if not settings.downscroll then
			return strumLineY + (((initialPos or 0) - (offset or 0)) * (speed*0.5) / 100)
		else
			return strumLineY - (((initialPos or 0) - (offset or 0)) * (speed*0.5) / 100)
		end
	end,
	updateNotePosition = function(self, offset, curTime)
		local spritePosition = 0

		for i = 1, 4 do
			local strumLineY = boyfriendArrows[i].y
			for _, note in ipairs(boyfriendNotes[i]) do
				spritePosition = self:getNotePosition(offset, note.initialTrackPosition, strumLineY, speeds.boyfriend)
				note.y = spritePosition
				if not note.moveWithScroll then
					note.y = strumLineY
				end
				if note.children and #note.children > 0 then
					note.endY = self:getNotePosition(offset, note.endTrackPosition, strumLineY, speeds.boyfriend)
					local tailH = note.children[2]:getFrameHeight()
					local bodyH = note.children[1]:getFrameHeight()
					local distance = note.endY - note.y
					local pixelDistance = math.abs(distance) - tailH
					if pixelDistance < 0 then pixelDistance = 0 end
					note.children[1].sizeY = pixelDistance / bodyH
					local dir = distance >= 0 and 1 or -1
					note.children[1].y = (note.y + note.endY) / 2 - (tailH / 2) * dir
					local tailOffset = 35
					note.children[2].y = note.endY + tailOffset
				end

				note.canBeHit = note.time - musicTime < 160 and note.time - musicTime > -160
				if note.time < musicTime - 160 then
					note.tooLate = false
				end
			end
			strumLineY = enemyArrows[i].y
			for _, note in ipairs(enemyNotes[i]) do
				spritePosition = self:getNotePosition(offset, note.initialTrackPosition, strumLineY, speeds.enemy)
				note.y = spritePosition
				if not note.moveWithScroll then
					note.y = strumLineY
				end
				if note.children and #note.children > 0 then
					note.endY = self:getNotePosition(offset, note.endTrackPosition, strumLineY, speeds.enemy)
					local tailH = note.children[2]:getFrameHeight()
					local bodyH = note.children[1]:getFrameHeight()
					local distance = note.endY - note.y
					local pixelDistance = math.abs(distance) - tailH
					if pixelDistance < 0 then pixelDistance = 0 end
					note.children[1].sizeY = pixelDistance / bodyH
					local dir = distance >= 0 and 1 or -1
					note.children[1].y = (note.y + note.endY) / 2 - (tailH / 2) * dir
					local tailOffset = 35
					note.children[2].y = note.endY + tailOffset
				end

				note.canBeHit = true
			end
		end
	end,

	enter = function(self, _, songNum, songAppend, _songExt, _audioAppend, _, weekID)
		camera.currentZoom = 1
		self:showUI()
		self.mayPauseGame = false
		self.isInCutscene = false
		self.gameoverType = "character" -- uses boyfriend.gameOverState
		IS_CLASSIC_MOVEMENT = false
		allStates = {
			sickCounter = 0,
			goodCounter = 0,
			badCounter = 0,
			shitCounter = 0,
			missCounter = 0,
			maxCombo = 0,
			score = 0
		}

		sickCounter, goodCounter, badCounter, shitCounter, missCounter, maxCombo, score = 0, 0, 0, 0, 0, 0, 0
		playMenuMusic = false
		beatHandler.reset()
		option = option or "normal"

		song = songNum or 1
		difficulty = songAppend or "normal"
		songExt = _songExt or ""
		audioAppend = _audioAppend or ""

		if option ~= "pixel" then
			pixel = false
			sounds = {
				miss = {
					love.audio.newSource("sounds/miss1.ogg", "static"),
					love.audio.newSource("sounds/miss2.ogg", "static"),
					love.audio.newSource("sounds/miss3.ogg", "static")
				},
				breakfast = love.audio.newSource("music/breakfast.ogg", "stream")
			}
		else
			pixel = true
			love.graphics.setDefaultFilter("nearest", "nearest")
			sounds = {
				miss = {
					love.audio.newSource("sounds/pixel/miss1.ogg", "static"),
					love.audio.newSource("sounds/pixel/miss2.ogg", "static"),
					love.audio.newSource("sounds/pixel/miss3.ogg", "static")
				},
				breakfast = love.audio.newSource("music/breakfast.ogg", "stream")
			}

			love.graphics.setDefaultFilter("linear", "nearest")
		end

		countdownFade = {0}

		self.conductor = Conductor.new()

		WEEKID = weekID or "tutorial"

		self:load()
	end,

	load = function(self, wasntRestart)
		speeds = {
			enemy = 1,
			boyfriend = 1
		}
		enemyNoteGameplay = {}
		self.pressedNotes = {}
		camera.bopIntensity = CONSTANTS.DEFAULT_BOP_INTENSITY
		camera.zoomRate = CONSTANTS.DEFAULT_ZOOM_RATE
		camera.zoomRateOffset = CONSTANTS.DEFAULT_ZOOM_OFFSET
		camera.bopMultiplier = 1
		uiCam.bopIntensity = 0.015 * 2
		self.mayPauseGame = false
		self.inSong = true
		if wasntRestart == nil then
			wasntRestart = true
		end
		print("WAS RESTART?", not wasntRestart)
		SMOOTH_RESET = true
		quitPressed = false
		camera.camBopIntensity = 1
		camera.camBopInterval = 4
		camera.centered = true
		dying = false
		function self:onDeath()
			if quitPressed then return end
			if camTween then
				Timer.cancel(camTween)
			end
			if inst then
				inst:stop()
			end
			if voicesBF then
				voicesBF:stop()
			end
			if voicesEnemy then
				voicesEnemy:stop()
			end
			Gamestate.push(gameoverSubstate)
		end
		self.useBuiltinGameover = true
		P1HealthColors = {0, 1, 0}
		P2HealthColors = {1, 0, 0}
		paused = false
		pauseMenuSelection = 1
		healthGainMult = 1
		healthLossMult = 1
		self.ignoreHealthClamping = false
		pauseBG = graphics.newImage(graphics.imagePath("pause/pause_box"))
		pauseShadow = graphics.newImage(graphics.imagePath("pause/pause_shadow"))
		useAltAnims = false
		health = CONSTANTS.WEEKS.HEALTH.STARTING
		misses = 0
		ratingPercent = 0.0
		noteCounter = 0
		healthLerp = health
		hudFade = {1}

		sickCounter, goodCounter, badCounter, shitCounter, missCounter, maxCombo, score = 0, 0, 0, 0, 0, 0, 0

		if wasntRestart then
			if boyfriend then
				camera.x, camera.y = -boyfriend.x + 100, -boyfriend.y + 75
			else
				camera.x, camera.y = 0, 0
			end
		end

		curWeekData = weekData[weekNum]

		ratingVisibility = {0}
		combo = 0

		if enemy then enemy:play("idle") end
		if boyfriend then boyfriend:play("idle") end

		healthBar = {
			x = -500,
			y = not settings.downscroll and 350 or -400,
			width = 1000,
			height = 25
		}

		if settings.downscroll then
			downscrollOffset = -750
		else
			downscrollOffset = 0
		end -- For compatibility

		isResetting = false
		if boyfriend then boyfriend.playerInputs = true end

		-- reload all the notes
		if not wasntRestart then
			-- call onSongRetry for all scripts

			local bfpoint = boyfriend:getCameraPoint()
			camera:forcePos(bfpoint.x, bfpoint.y)

			print("Reloading notes from preloaded chart...")
			for i = 1, 4 do
				boyfriendArrows[i]:animate(CONSTANTS.WEEKS.NOTE_LIST[i])
				enemyArrows[i]:animate(CONSTANTS.WEEKS.NOTE_LIST[i])
				boyfriendNotes[i] = {}
				enemyNotes[i] = {}

				for _, note in ipairs(CURCHART.BOYFRIEND[i]) do
					table.insert(boyfriendNotes[i], note)
				end
				for _, note in ipairs(CURCHART.ENEMY[i]) do
					table.insert(enemyNotes[i], note)
				end

				print("Loaded "..#boyfriendNotes[i].." boyfriend notes and "..#enemyNotes[i].." enemy notes for lane "..i)
			end
			songEvents = {}
			for _, event in ipairs(CURCHART.EVENTS) do
				table.insert(songEvents, event)
			end

			print("Calling onSongRetry for all scripts...")
			self.stage:call("onSongRetry")
			self.song:call("onSongRetry")
			for _, obj in ipairs(self.objects) do
				if obj.call then
					obj:call("onSongRetry")
				end
			end
		end

		previousFrameTime = love.timer.getTime() * 1000

		if wasntRestart and not graphics.isFading() then
			print("Generating notes for song:", Gamestate.current().songs[song], "with difficulty:", difficulty)
			self:generateNotes(Gamestate.current().songs[song], difficulty)
			graphics:fadeInWipe(0.6)

			if boyfriend then
				local bfpoint = boyfriend:getCameraPoint()
				print("THE FUCKING POINT", bfpoint.x, bfpoint.y)
				camera.x = bfpoint.x
				camera.y = bfpoint.y
				camera.defaultX = bfpoint.x
				camera.defaultY = bfpoint.y
				camera.targetX = bfpoint.x
				camera.targetY = bfpoint.y
				CAM_LERP_POINT.x = bfpoint.x
				CAM_LERP_POINT.y = bfpoint.y
			end
		end

		self:preloadIcon((enemy and enemy.healthIcon) and enemy.healthIcon or "dad", "enemy", (enemy and enemy.healthIconScale) or 1)
		self:preloadIcon((boyfriend and boyfriend.healthIcon) and boyfriend.healthIcon or "boyfriend", "boyfriend", (boyfriend and boyfriend.healthIconScale) or 1)

		enemyIcon = healthIconPreloads.enemy
		boyfriendIcon = healthIconPreloads.boyfriend

		P1HealthColors = boyfriendIcon.mostCommonColour
		P2HealthColors = enemyIcon.mostCommonColour

		enemyIcon.sizeX = 1.5
		boyfriendIcon.sizeX = -1.5
		enemyIcon.sizeY = 1.5
		boyfriendIcon.sizeY = 1.5

		enemyIcon.y = healthBar.y
		boyfriendIcon.y = healthBar.y

		local vwoosh = 0.5
		musicTime = (-vwoosh * 1000) + (self.conductor:getBeatLengthsMS() * -5)
		for i = 1, 4 do
			boyfriendArrows[i].alpha = 0
			enemyArrows[i].alpha = 0
		end
		Timer.after(vwoosh, function()
			self:vwooshArrows(boyfriendArrows)
			self:vwooshArrows(enemyArrows)
			self:performCountdown(vwoosh)
		end)

		self.songEnded = false

		status.setLoading(false)
	end,

	preloadIcon = function(self, path, name, scale)
		name = name or path
		if not healthIconPreloads[name] then
			healthIconPreloads[name] = icon.newIcon(icon.imagePath(path), scale or 1)
		end
	end,

	calculateRating = function(self)
		local mode = settings.accuracyMode
		if mode == "Complex" then
			ratingPercent = score / ((noteCounter + misses) * 500)
			if ratingPercent == nil or ratingPercent < 0 then
				ratingPercent = 0
			elseif ratingPercent > 1 then
				ratingPercent = 1
			end
		elseif mode == "Simple" then
			local sickRating = 1
			local goodRating = 0.85
			local badRating = 0.67
			local shitRating = 0.5

			local totalHit = sickCounter + goodCounter + badCounter + shitCounter + misses

			ratingPercent = (sickCounter * sickRating +
				goodCounter * goodRating +
				badCounter * badRating +
				shitCounter * shitRating) /
				totalHit
		end
	end,

	saveData = function(self)
		if storyMode then
			settings.getSavedata().setBeatenLevel(WEEKID, true)
		end
	end,


	songEnded = false,

	checkSongOver = function(self)
		if musicTime >= math.floor(inst:getDuration("seconds") * 1000)-10 and not self.songEnded then
			self.songEnded = true
			self:endSong()
		end
	end,

	endSong = function(self)
		local event = eventCreator:endSong()
		self.stage:call("onSongEnd", event)
		self.song:call("onSongEnd", event)
		for _, obj in ipairs(self.objects) do
			if obj.call then
				obj:call("onSongEnd", event)
			end
		end
		if event.cancelled then return end
		allStates.sickCounter = allStates.sickCounter + sickCounter
		allStates.goodCounter = allStates.goodCounter + goodCounter
		allStates.badCounter = allStates.badCounter + badCounter
		allStates.shitCounter = allStates.shitCounter + shitCounter
		allStates.missCounter = allStates.missCounter + misses
		if maxCombo > allStates.maxCombo then allStates.maxCombo = maxCombo end
		allStates.score = allStates.score + score

		if storyMode and song < #Gamestate.current().songs and not status.getLoading() then
			print("Loading next song...")
			song = song + 1

			status.setLoading(true)
			self:load()
			status.setLoading(false)
		elseif not status.getLoading() then

			status.setLoading(true)
			graphics:fadeOutWipe(
				0.7,
				function()
					graphics.setFade(1)
					if not quitPressed then
						self:saveData()
						Gamestate.switch(resultsScreen, {
							diff = string.lower(CURDIFF or "normal"),
							song = not storyMode and SONGNAME or Gamestate.current().songs[song],
							artist = not storyMode and ARTIST or nil,
							scores = {
								sickCount = allStates.sickCounter,
								goodCount = allStates.goodCounter,
								badCount = allStates.badCounter,
								shitCount = allStates.shitCounter,
								missedCount = allStates.missCounter,
								maxCombo = allStates.maxCombo,
								score = allStates.score
							}
						})
					else
						if storyMode then
							Gamestate.switch(menuWeek)
						else
							Gamestate.switch(menuFreeplay)
						end
					end

					status.setLoading(false)
				end
			)
		end
	end,

	initUI = function(self, mode)
		CURRENTMODE = mode
		if CURRENTMODE == "pixel" then
			pixel = true
			print("Using pixel note style for this song because of pixel mode")
		end
		events = {}
		modEvents = {}
		songEvents = {}
		enemyNotes = {}
		boyfriendNotes = {}
		gfNotes = {}
		self.objects = {}
		health = CONSTANTS.WEEKS.HEALTH.STARTING
		healthLerp = health
		score = 0
		misses = 0
		ratingPercent = 0.0
		noteCounter = 0

		if not noteSprites then
			if not pixel then
				self:setNoteSprites( -- the default sprites
					love.filesystem.load("sprites/receptor.lua"),
					love.filesystem.load("sprites/left-arrow.lua"),
					love.filesystem.load("sprites/down-arrow.lua"),
					love.filesystem.load("sprites/up-arrow.lua"),
					love.filesystem.load("sprites/right-arrow.lua")
				)

				sounds.countdown = {
					three = love.audio.newSource("sounds/countdown-3.ogg", "static"),
					two = love.audio.newSource("sounds/countdown-2.ogg", "static"),
					one = love.audio.newSource("sounds/countdown-1.ogg", "static"),
					go = love.audio.newSource("sounds/countdown-go.ogg", "static")
				}
				rating = love.filesystem.load("sprites/rating.lua")
				countdown = love.filesystem.load("sprites/countdown.lua")()
				popupScore:init(rating)
			else
				self:setNoteSprites( -- the pixel sprites
					love.filesystem.load("sprites/pixel/receptor.lua"),
					love.filesystem.load("sprites/pixel/left-arrow.lua"),
					love.filesystem.load("sprites/pixel/down-arrow.lua"),
					love.filesystem.load("sprites/pixel/up-arrow.lua"),
					love.filesystem.load("sprites/pixel/right-arrow.lua")
				)
				
				sounds.countdown = {
					three = love.audio.newSource("sounds/pixel/countdown-3.ogg", "static"),
					two = love.audio.newSource("sounds/pixel/countdown-2.ogg", "static"),
					one = love.audio.newSource("sounds/pixel/countdown-1.ogg", "static"),
					go = love.audio.newSource("sounds/pixel/countdown-date.ogg", "static")
				}
				rating = love.filesystem.load("sprites/pixel/rating.lua")
				countdown = love.filesystem.load("sprites/pixel/countdown.lua")()
				popupScore:init(rating, true)
			end
		end

		if settings.middlescroll then
			if not settings.downscroll then
				popupScore:setPlacement(-300, -400)
			else
				popupScore:setPlacement(-300, 400)
			end
		else
			if not settings.downscroll then
				popupScore:setPlacement(0, -400)
			end
		end

		enemyArrows = {
			noteSprites[5](),
			noteSprites[5](),
			noteSprites[5](),
			noteSprites[5]()
		}
		boyfriendArrows= {
			noteSprites[5](),
			noteSprites[5](),
			noteSprites[5](),
			noteSprites[5]()
		}

		NOTES_BATCH = love.graphics.newSpriteBatch(boyfriendArrows[1]:getSheet(), 1000)
		if pixel then
			boyfriendArrows[1]:getSheet():setFilter("nearest", "nearest")
		end

		for i = 1, 4 do
			if settings.middlescroll then 
				boyfriendArrows[i].x = -410 + 165 * i + CONSTANTS.WEEKS.STRUM_X_OFFSET
				-- ew stuff
				enemyArrows[1].x = -925 + 165 * 1 + CONSTANTS.WEEKS.STRUM_X_OFFSET
				enemyArrows[2].x = -925 + 165 * 2 + CONSTANTS.WEEKS.STRUM_X_OFFSET
				enemyArrows[3].x = 100 + 165 * 3 + CONSTANTS.WEEKS.STRUM_X_OFFSET
				enemyArrows[4].x = 100 + 165 * 4 + CONSTANTS.WEEKS.STRUM_X_OFFSET
			else
				enemyArrows[i].x = -925 + 165 * i + CONSTANTS.WEEKS.STRUM_X_OFFSET
				boyfriendArrows[i].x = 100 + 165 * i + CONSTANTS.WEEKS.STRUM_X_OFFSET
			end

			enemyArrows[i].y = CONSTANTS.WEEKS.STRUM_Y
			boyfriendArrows[i].y = CONSTANTS.WEEKS.STRUM_Y
			if settings.downscroll then
				enemyArrows[i].y = -CONSTANTS.WEEKS.STRUM_Y
				boyfriendArrows[i].y = -CONSTANTS.WEEKS.STRUM_Y
			end

			enemyArrows[i].finishedAlpha = 1
			boyfriendArrows[i].finishedAlpha = 1

			boyfriendArrows[i]:animate(CONSTANTS.WEEKS.NOTE_LIST[i])
			enemyArrows[i]:animate(CONSTANTS.WEEKS.NOTE_LIST[i])

			enemyNotes[i] = {}
			boyfriendNotes[i] = {}
			gfNotes[i] = {}
		end

		NoteSplash:setup()
		HoldCover:setup()
	end,

	setNoteSprites = function(self, receptors, left, down, up, right)
		if pixel then
		end
		noteSprites = {
			left,
			down,
			up,
			right,
			receptors
		}
	end,

	generateNotes = function(self, name, diff)
		local eventBpm
		local chartPath = "data/songs/" .. name .. "/" .. name .. "-chart" .. songExt .. ".lua"
		local metadataPath = "data/songs/" .. name .. "/" .. name .. "-metadata" .. songExt .. ".lua"
		if not love.filesystem.getInfo(chartPath) then
			chartPath = "data/songs/" .. name .. "/" .. name .. "-chart" .. songExt .. ".json"
		end
		if not love.filesystem.getInfo(metadataPath) then
			metadataPath = "data/songs/" .. name .. "/" .. name .. "-metadata" .. songExt .. ".json"
		end
		print("Loading chart:", chartPath)
		print("Loading metadata:", metadataPath)
		-- song id for script is name .. songExt
		self.song = Song.getSong(name .. songExt)
		local chart = chartPath
		local metadata = metadataPath
		local chartData
		if string.endsWith(chart, ".json") then
			chartData = json.decode(love.filesystem.read(chart))
		else
			chartData = love.filesystem.load(chart)()
		end

		chart = chartData.notes[diff] or chartData.notes["normal"]

		if string.endsWith(metadata, ".json") then
			metadata = json.decode(love.filesystem.read(metadata))
		else
			metadata = love.filesystem.load(metadata)()
		end

		if metadata.playData and metadata.playData.noteStyle then
			if metadata.playData.noteStyle == "pixel" then
				self:initUI("pixel")
			else
				self:initUI("normal")
			end
		else
			self:initUI("normal")
		end

		self.chart = chartData
		self.metadata = metadata
		self.conductor:mapBPMChanges(metadata)
		metadata.playData = metadata.playData or {}
		metadata.playData.characters = metadata.playData.characters or {}
		metadata.playData.characters.opponent = metadata.playData.characters.opponent or "dad"
		metadata.playData.characters.player = metadata.playData.characters.player or "bf"
		metadata.playData.characters.girlfriend = metadata.playData.characters.girlfriend
		boyfriend = Character.getCharacter(metadata.playData.characters.player)
		enemy = Character.getCharacter(metadata.playData.characters.opponent)
		girlfriend = Character.getCharacter(metadata.playData.characters.girlfriend)

		SONGNAME = metadata.songName
		SONGID = name
		CURDIFF = difficulty
		ARTIST = metadata.artist

		inst = love.audio.newSource("songs/" .. name .. "/Inst" .. songExt .. ".ogg", "stream")
		local voicesBFPath = "songs/" .. name .. "/Voices-" .. metadata.playData.characters.player .. songExt .. ".ogg"
		local voicesEnemyPath = "songs/" .. name .. "/Voices-" .. metadata.playData.characters.opponent .. songExt .. ".ogg"
		local voiceConversions = {
			["pico-playable"] = "pico",
			["pico-pixel"] = "pico",
			["pico-blazin"] = "pico",
			["pico-dark"] = "pico",
			["pico-christmas"] = "pico",
			["pico-holding-nene"] = "pico",

			["bf-car"] = "bf",
			["bf-pixel"] = "bf",
			["bf-christmas"] = "bf",
			["bf-holding-gf"] = "bf",
			["bf-dark"] = "bf",

			["tankman-bloody"] = "tankman",

			["mom-car"] = "mom",

			["spooky-dark"] = "spooky",
		}
		local vocals = metadata.playData.characters.playerVocals and metadata.playData.characters.playerVocals[1] or metadata.playData.characters.player
		local vocalsEnemy = metadata.playData.characters.opponentVocals and metadata.playData.characters.opponentVocals[1] or metadata.playData.characters.opponent
		if not love.filesystem.getInfo(voicesBFPath) then
			voicesBFPath = "songs/" .. name .. "/Voices-" .. vocals .. songExt .. ".ogg"
			if not love.filesystem.getInfo(voicesBFPath) and voiceConversions[vocals] then
				voicesBFPath = "songs/" .. name .. "/Voices-" .. voiceConversions[vocals] .. songExt .. ".ogg"
			end
		end
	
		if not love.filesystem.getInfo(voicesEnemyPath) then
			voicesEnemyPath = "songs/" .. name .. "/Voices-" .. vocalsEnemy .. songExt .. ".ogg"
			if not love.filesystem.getInfo(voicesEnemyPath) and voiceConversions[vocalsEnemy] then
				voicesEnemyPath = "songs/" .. name .. "/Voices-" .. voiceConversions[vocalsEnemy] .. songExt .. ".ogg"
			end
		end
		if love.filesystem.getInfo(voicesBFPath) then
			voicesBF = love.audio.newSource(voicesBFPath, "stream")
		else
			voicesBF = nil
		end
		if love.filesystem.getInfo(voicesEnemyPath) then
			voicesEnemy = love.audio.newSource(voicesEnemyPath, "stream")
		else
			voicesEnemy = nil
		end

		boyfriend.zIndex = 10
		enemy.zIndex = 8
		if girlfriend then girlfriend.zIndex = 9 end

		boyfriend.characterType = CHARACTER_TYPE.BF
		enemy.characterType = CHARACTER_TYPE.DAD
		if girlfriend then girlfriend.characterType = CHARACTER_TYPE.GF end

		boyfriend.flipX = not boyfriend._data.flipX
		enemy.flipX = enemy._data.flipX
		print(enemy.flipX)
		if girlfriend then girlfriend.flipX = girlfriend._data.flipX end

		boyfriend:dance()
		enemy:dance()
		if girlfriend then girlfriend:dance() end

		self.stage = Stage.getStage(metadata.playData.stage or "stage")
		self.stage:build()
		--[[ self.stage:call("onCreate") ]]
		self.stage:call("postCreate")
		self.song:call("postCreate")
		if boyfriend.call then boyfriend:call("postCreate") end
		if enemy.call then enemy:call("postCreate") end
		if girlfriend and girlfriend.call then girlfriend:call("postCreate") end
		camera.zoom = self.stage.cameraZoom or 1.0
		camera.defaultZoom = 1

		boyfriend.name = "bf"
		self:add(boyfriend)
		enemy.name = "enemy"
		self:add(enemy)
		if girlfriend then girlfriend.name = "gf" end
		if girlfriend then self:add(girlfriend) end
		self:sort()

		boyfriend:updateHitbox()
		boyfriend.x = boyfriend.x - boyfriend.width / 2
		boyfriend.y = boyfriend.y - boyfriend.height

		enemy:updateHitbox()
		enemy.x = enemy.x - enemy.width / 2
		enemy.y = enemy.y - enemy.height

		if girlfriend then
			girlfriend:updateHitbox()
			girlfriend.x = girlfriend.x - girlfriend.width / 2 - 150
			girlfriend.y = girlfriend.y - girlfriend.height
		end

		local bfpoint = boyfriend:getCameraPoint()

		camera.x = bfpoint.x
		camera.y = bfpoint.y
		camera.defaultX = bfpoint.x
		camera.defaultY = bfpoint.y
		camera.targetX = bfpoint.x
		camera.targetY = bfpoint.y
		CAM_LERP_POINT.x = bfpoint.x
		CAM_LERP_POINT.y = bfpoint.y

		local events = {}

		for _, timeChange in ipairs(metadata.timeChanges) do
			local time = timeChange.t
			local bpm_ = timeChange.bpm

			table.insert(events, {time = time, bpm = bpm_, type="bpm"})

			if not bpm then bpm = bpm_ end
			if not crochet then crochet = ((60/bpm) * 1000) end
			if not stepCrochet then stepCrochet = crochet / 4 end
		end

		if not bpm then bpm = 120 end

		local _speed = 1
		print(difficulty)
		if chartData.scrollSpeed[difficulty] then
			_speed = chartData.scrollSpeed[difficulty]
		elseif chartData.scrollSpeed["default"] then
			_speed = chartData.scrollSpeed["default"]
		end

		speed = _speed

		if not speed then speed = _speed end

		speed = speed * 1.06

		speeds.enemy = speed
		speeds.boyfriend = speed
		print(speeds.enemy, speeds.boyfriend)

		for _, noteData in ipairs(chart) do
			local data = noteData.d % 4 + 1
			local time = noteData.t
			local holdTime = noteData.l or 0
			noteData.k = noteData.k or "normal"

			local noteObject = noteSprites[data]()

			local dataStuff = {}

			if noteTypes[noteData.k] then
				dataStuff = noteTypes[noteData.k]
			else
				dataStuff = noteTypes["normal"]
			end

			noteObject.col = data
			noteObject.y = CONSTANTS.WEEKS.STRUM_Y + time * 0.6 * speed
			noteObject.ver = noteData.k
			noteObject.time = time
			noteObject.batchReference = NOTES_BATCH
			noteObject:animate("on")

			local enemyNote = noteData.d > 3
			local notesTable = enemyNote and enemyNotes or boyfriendNotes
			local arrowsTable = enemyNote and enemyArrows or boyfriendArrows

			noteObject.x = arrowsTable[data].x
			noteObject.moveWithScroll = true
			if dataStuff.r then r = {decToRGB(dataStuff.r)} end
			if dataStuff.g then g = {decToRGB(dataStuff.g)} end
			if dataStuff.b then b = {decToRGB(dataStuff.b)} end
			noteObject.hitNote = not dataStuff.ignoreNote

			noteObject.healthGainMult = dataStuff.healthMult or 1
			noteObject.healthLossMult = dataStuff.healthLossMult or 1

			noteObject.causesMiss = dataStuff.causesMiss or false

			local enemyTiming = {}

			if enemyNote then
				enemyTiming.time = time
				enemyTiming.releasedTime = time + holdTime
				enemyTiming.key = data
				enemyTiming.hit = false

				table.insert(enemyNoteGameplay, enemyTiming)
			end

			table.insert(notesTable[data], noteObject)
			if holdTime > 0 then
				noteObject.children = {}

				noteObject.children[1] = noteSprites[data]()
				noteObject.children[1].col = data
				noteObject.children[1].y = -400 + time * 0.6 * speed
				noteObject.children[1].ver = noteData.k or "normal"
				noteObject.children[1]:animate("hold")
				noteObject.children[1].x = arrowsTable[data].x

				noteObject.children[2] = noteSprites[data]()
				noteObject.children[2].col = data
				noteObject.children[2].y = -400 + (time + holdTime) * 0.6 * speed
				noteObject.children[2].ver = noteData.k or "normal"
				noteObject.children[2]:animate("end")
				noteObject.children[2].x = arrowsTable[data].x

				noteObject.endTime = time + holdTime
			end
		end

		-- Events !!!
		for _, event in ipairs(chartData.events) do
			local time = event.t
			local eventName = event.e
			local value = event.v

			table.insert(songEvents, {
				time = time,
				name = eventName,
				value = value
			})
		end

		for i = 1, 4 do
			table.sort(enemyNotes[i], function(a, b) return a.y < b.y end)
			table.sort(boyfriendNotes[i], function(a, b) return a.y < b.y end)
		end

		CURCHART = {}
		CURCHART.BOYFRIEND = {}
		CURCHART.ENEMY = {}
		CURCHART.EVENTS = {}
		for i = 1, 4 do
			CURCHART.BOYFRIEND[i] = {}
			CURCHART.ENEMY[i] = {}

			for _, note in ipairs(boyfriendNotes[i]) do
				table.insert(CURCHART.BOYFRIEND[i], note)
			end
			for _, note in ipairs(enemyNotes[i]) do
				table.insert(CURCHART.ENEMY[i], note)
			end
		end
		for _, event in ipairs(songEvents) do
			table.insert(CURCHART.EVENTS, event)
		end

		self:initPositions()
	end,

	generateGFNotes = function(self, chartG, diff)
		-- very bare-bones chart generation
		-- Does not handle sprites and all that, just note timings and type
		--[[ local chartG = json.decode(love.filesystem.read(chartG)).notes[diff] ]]
		if string.endsWith(chartG, ".json") then
			chartG = json.decode(love.filesystem.read(chartG)).notes[diff]
		else
			chartG = love.filesystem.load(chartG)().notes[diff]
		end

		for _, noteData in ipairs(chartG) do
			local noteType = noteData.d % 4 + 1
			local noteTime = noteData.t

			table.insert(gfNotes[noteType], {time = noteTime})
		end
	end,

	COUNTDOWN_STEPS = {
		BEFORE = 1,
		THREE = 2,
		TWO = 3,
		ONE = 4,
		GO = 5,
		AFTER = 6
	},
	countdownStep = 1,

	pauseCountdown = function(self)
		if self.countdownTimer then
			self.countdownTimer.active = false
		end
		countingDown = false
	end,

	resumeCountdown = function(self)
		if self.countdownTimer then
			self.countdownTimer.active = true
		end
		countingDown = true
	end,

	stopCountdown = function(self)
		if self.countdownTimer then
			Timer.cancel(self.countdownTimer)
			self.countdownTimer = nil
		end
		countingDown = false
	end,

	vwooshArrows = function(self, arrows)
		local vwooshTime = 0.5
		for i = 1, #arrows do
			arrows[i].alpha = 0
			arrows[i].y = arrows[i].y - 50
			local vwooshSteps = vwooshTime / #arrows
			Timer.after(vwooshSteps * (i - 1), function()
				local target = CONSTANTS.WEEKS.STRUM_Y * (settings.downscroll and -1 or 1)

				Timer.tween(vwooshSteps, arrows[i], {
					alpha = arrows[i].finishedAlpha,
					y = target
				}, "out-circ", function()
					arrows[i].alpha = arrows[i].finishedAlpha
					arrows[i].y = target
				end)
			end)
		end
	end,

	performCountdown = function(self, vwoosh)
		self.mayPauseGame = false
		countingDown = true

		self.countdownStep = self.COUNTDOWN_STEPS.BEFORE
		local event = eventCreator:countdownStart()
		self.stage:call("onCountdownStart", event)
		self.song:call("onCountdownStart", event)
		if event.cancelled then
			self:stopCountdown()
			return
		end

		self:stopCountdown()

		musicTime = self.conductor:getBeatLengthsMS() * -4

		self.countdownTimer = Timer.after(self.conductor:getBeatLengthsMS()/1000, function()
			countingDown = true
			if self.countdownStep == self.COUNTDOWN_STEPS.BEFORE then
				self.countdownStep = self.COUNTDOWN_STEPS.THREE
				audio.playSound(sounds.countdown[CONSTANTS.WEEKS.COUNTDOWN_SOUNDS[4]])
			elseif self.countdownStep == self.COUNTDOWN_STEPS.THREE then
				self.countdownStep = self.COUNTDOWN_STEPS.TWO
				countdown:animate(CONSTANTS.WEEKS.COUNTDOWN_ANIMS[3])
				audio.playSound(sounds.countdown[CONSTANTS.WEEKS.COUNTDOWN_SOUNDS[3]])
			elseif self.countdownStep == self.COUNTDOWN_STEPS.TWO then
				self.countdownStep = self.COUNTDOWN_STEPS.ONE
				countdown:animate(CONSTANTS.WEEKS.COUNTDOWN_ANIMS[2])
				audio.playSound(sounds.countdown[CONSTANTS.WEEKS.COUNTDOWN_SOUNDS[2]])
			elseif self.countdownStep == self.COUNTDOWN_STEPS.ONE then
				self.countdownStep = self.COUNTDOWN_STEPS.GO
				countdown:animate(CONSTANTS.WEEKS.COUNTDOWN_ANIMS[1])
				audio.playSound(sounds.countdown[CONSTANTS.WEEKS.COUNTDOWN_SOUNDS[1]])
			else
				self.countdownStep = self.COUNTDOWN_STEPS.AFTER
			end

			-- if we are not two, one, or go, do not set countdownFade[1] to 1
			if self.countdownStep == self.COUNTDOWN_STEPS.TWO or
				self.countdownStep == self.COUNTDOWN_STEPS.ONE or
			self.countdownStep == self.COUNTDOWN_STEPS.GO then
				countdownFade[1] = 1
				Timer.tween(self.conductor:getBeatLengthsMS()/1000, countdownFade, {0}, "in-out-cubic")
			else
				countdownFade[1] = 0
			end

			local event = eventCreator:countdownTick(self.countdownStep)
			self.stage:call("onCountdownTick", event)
			self.song:call("onCountdownTick", event)
			if event.cancelled then
				self:pauseCountdown()
				return
			end

			if self.countdownStep == self.COUNTDOWN_STEPS.AFTER then
				print("Countdown finished, starting song!")
				self:stopCountdown()
				self.mayPauseGame = true

				print(musicTime)
				--[[ musicTime = inst:getDuration("seconds") * 1000 - 5000 ]]
				inst:play()
				if voicesBF then voicesBF:play() end
				if voicesEnemy then voicesEnemy:play() end

				--[[ inst:seek(musicTime / 1000)
				voicesBF:seek(musicTime / 1000)
				voicesEnemy:seek(musicTime / 1000) ]]
			end
		end, 5)
	end,

	update = function(self, dt)
		if input:pressed("pause") and self.mayPauseGame and not paused then
			if not graphics.isFading() then
				paused = true
				pauseTime = musicTime
				if paused then
					if inst then inst:pause() end
					if voicesBF then voicesBF:pause() end
					if voicesEnemy then voicesEnemy:pause() end
					love.audio.play(sounds.breakfast)
					sounds.breakfast:setLooping(true)
				end
			end
			return
		end
		if paused then
			previousFrameTime = love.timer.getTime() * 1000
			musicTime = pauseTime
			if input:pressed("gameDown") then
				if pauseMenuSelection == 3 then
					pauseMenuSelection = 1
				else
					pauseMenuSelection = pauseMenuSelection + 1
				end
			end

			if input:pressed("gameUp") and paused then
				if pauseMenuSelection == 1 then
					pauseMenuSelection = 3
				else
					pauseMenuSelection = pauseMenuSelection - 1
				end
			end
			if input:pressed("confirm") then
				love.audio.stop(sounds.breakfast)
				if pauseMenuSelection == 1 then
					if not countingDown then
						if inst then inst:play() end
						if voicesBF then voicesBF:play() end
						if voicesEnemy then voicesEnemy:play() end
					end
					paused = false
				elseif pauseMenuSelection == 2 then
					if not SMOOTH_RESET then
						pauseRestart = true
						dying = true
						self:onDeath({SKIP_DEATH = true})
					else
						countingDown = false
						paused = false
						isResetting = true
						resettingTime[1] = musicTime
						Timer.tween(
							1,
							_G,
							{
								score = 0,
								ratingPercent = 0,
								misses = 0,
								health = CONSTANTS.WEEKS.HEALTH.STARTING,
								maxNPS = 0
							},
							"out-quad"
						)
						for i = 1, 4 do
							Timer.tween(
								1,
								boyfriendArrows[i],
								{
									alpha = 0,
									y = boyfriendArrows[i].y - 50
								},
								"out-circ",
								function()
									boyfriendArrows[i].alpha = 0
								end
							)

							Timer.tween(
								1,
								enemyArrows[i],
								{
									alpha = 0,
									y = enemyArrows[i].y - 50
								},
								"out-circ",
								function()
									enemyArrows[i].alpha = 0
								end
							)
						end
						Timer.tween(
							1 * speed,
							resettingTime,
							{
								[1] = resettingTime[1] - 1000 * speed
							},
							"out-quad",
							function()
								for i = 1, 4 do
									boyfriendArrows[i]:animate(CONSTANTS.WEEKS.NOTE_LIST[i])
									enemyArrows[i]:animate(CONSTANTS.WEEKS.NOTE_LIST[i])
									boyfriendNotes[i] = {}
									enemyNotes[i] = {}

									for _, note in ipairs(CURCHART.BOYFRIEND[i]) do
										table.insert(boyfriendNotes[i], note)
									end
									for _, note in ipairs(CURCHART.ENEMY[i]) do
										table.insert(enemyNotes[i], note)
									end
								end
								songEvents = {}
								for _, event in ipairs(CURCHART.EVENTS) do
									table.insert(songEvents, event)
								end

								lastReportedPlaytime = 0
								musicThres = 0
								beatHandler.reset(0)
								previousFrameTime = love.timer.getTime() * 1000
								beatHandler.setBeat(0)
								if inst then inst:seek(0) end
								if voicesBF then voicesBF:seek(0) end
								if voicesEnemy then voicesEnemy:seek(0) end

								self:load(false)
							end
						)
					end

				elseif pauseMenuSelection == 3 then
					status.setLoading(true)
					graphics:fadeOutWipe(
						0.7,
						function()
							graphics.setFade(1)
							if storyMode then
								Gamestate.switch(menuWeek)
							else
								Gamestate.switch(menuFreeplay)
							end

							status.setLoading(false)
						end
					)
					if voicesBF then voicesBF:stop() end
					if voicesEnemy then voicesEnemy:stop() end
					quitPressed = true
				end
			end
			return
		end
		if inCutscene then return end
		beatHandler.update(dt)
		self.conductor.musicTime = musicTime
		self.conductor:update(dt)

		-- nps table
		for i, note in ipairs(nps) do
			if note - love.timer.getTime() <= -1 then
				table.remove(nps, i)
			end
		end

		oldMusicThres = musicThres
		if countingDown or love.system.getOS() == "Web" then -- Source:tell() can't be trusted on love.js!\
			previousFrameTime = love.timer.getTime() * 1000
			musicTime = musicTime + 1000 * dt
		else
			if not graphics.isFading() and inst:isPlaying() then
				local time = love.timer.getTime()
				local seconds = inst:isPlaying() and inst:tell("seconds") or musicTime / 1000

				musicTime = musicTime + (time * 1000) - previousFrameTime
				previousFrameTime = time * 1000

				if lastReportedPlaytime ~= seconds * 1000 then
					lastReportedPlaytime = seconds * 1000
					musicTime = (musicTime + lastReportedPlaytime) / 2
				end
			else
				previousFrameTime = love.timer.getTime() * 1000
			end
		end
		absMusicTime = math.abs(musicTime)
		musicThres = math.floor(absMusicTime / 100) -- Since "musicTime" isn't precise, this is needed
		self:updateCurrentTrackPosition()
		self:updateNotePosition(self.currentTrackPosition, musicTime)

		for i = 1, #events do
			if events[i].eventTime <= musicTime then
				local oldBpm = bpm

				if events[i].bpm then
					bpm = events[i].bpm
					if not bpm then bpm = oldBpm end
					beatHandler.setBPM(bpm)
				end

				table.remove(events, i)

				break
			end
		end

		for i, event in ipairs(songEvents) do
			if event.time <= musicTime then
				if event.name == "FocusCamera" and not camera.lockedMoving then
					IS_CLASSIC_MOVEMENT = false
					if type(event.value) == "number" then
						local targetX, targetY = 0, 0
						if event.value == 0 then -- Boyfriend
							if not boyfriend then return end
							local bfpoint = boyfriend:getCameraPoint()
							targetX = bfpoint.x
							targetY = bfpoint.y
						elseif event.value == 1 then -- Enemy
							if not enemy then return end
							local dadpoint = enemy:getCameraPoint()
							targetX = dadpoint.x
							targetY = dadpoint.y
						elseif event.value == 2 then -- Girlfriend
							if not girlfriend then return end
							local gfpoint = girlfriend:getCameraPoint()
							targetX = gfpoint.x
							targetY = gfpoint.y
						end

						if camTween then 
							Timer.cancel(camTween)
						end

						IS_CLASSIC_MOVEMENT = true
						CAM_LERP_POINT.x = targetX
						CAM_LERP_POINT.y = targetY
					elseif type(event.value) == "table" then
						local char = tonumber(event.value.char) or tonumber(event.value.value) or 0
						local x = tonumber(event.value.x) or 0
						local y = tonumber(event.value.y) or 0

						local duration = tonumber(event.value.duration) or 4
						local ease = event.value.ease or "CLASSIC"

						local targetX, targetY = x, y
						if self:getSongID() == "2hot" then
							targetX, targetY = -targetX, -targetY
						end
						print("CHARACTER", char)

						if char == -1 then
						elseif char == 0 then
							if not boyfriend then return end
							local bfpoint = boyfriend:getCameraPoint()
							print("BF POINT", bfpoint.x, bfpoint.y)
							targetX = targetX + bfpoint.x
							targetY = targetY + bfpoint.y
						elseif char == 1 then
							if not enemy then return end
							local dadpoint = enemy:getCameraPoint()
							targetX = targetX + dadpoint.x
							targetY = targetY + dadpoint.y
						elseif char == 2 then
							if not girlfriend then return end
							local gfpoint = girlfriend:getCameraPoint()
							targetX = targetX + gfpoint.x
							targetY = targetY + gfpoint.y
						else
							print("Unknown char for FocusCamera event: " .. tostring(char))
						end

						if ease == "CLASSIC" then
							if camTween then 
								Timer.cancel(camTween)
							end
							IS_CLASSIC_MOVEMENT = true
							CAM_LERP_POINT.x = targetX
							CAM_LERP_POINT.y = targetY
						elseif ease == "INSTANT" then
							camera.x = targetX
							camera.y = targetY
						else
							local time = (self.conductor:getStepLengthMs() * duration) / 1000
							if camTween then 
								Timer.cancel(camTween)
							end

							camTween = Timer.tween(
								time,
								camera,
								{
									x = targetX,
									y = targetY
								},
								CONSTANTS.WEEKS.EASING_TYPES[ease or "CLASSIC"]
							)
						end;
					end
				elseif event.name == "PlayAnimation" then
					if event.value.target == "bf" or event.value.target == "boyfriend" then
						for _, obj in ipairs(self.objects) do
							if obj.characterType == CHARACTER_TYPE.BF then
								obj:play(event.value.anim, event.value.force or false, false)
							end
						end
					elseif event.value.target == "gf" or event.value.target == "girlfriend" then
						for _, obj in ipairs(self.objects) do
							if obj.characterType == CHARACTER_TYPE.GF then
								obj:play(event.value.anim, event.value.force or false, false)
								obj.holdTimer = 0
							end
						end
					elseif event.value.target == "dad" then
						for _, obj in ipairs(self.objects) do
							if obj.characterType == CHARACTER_TYPE.DAD then
								obj:play(event.value.anim, event.value.force or false, false)
								obj.holdTimer = 0
							end
						end
					end
				elseif event.name == "ZoomCamera" then
					local zoom = tonumber(event.value.zoom) or 1
					--local widescreenScaleX = tonumber(event.value.widescreenScaleX) or 0
					--local widescreenScaleY = tonumber(event.value.widescreenScaleY) or 0

					local duration = tonumber(event.value.duration) or 4
					local mode = event.value.mode or "direct"
					local isDirectMode = mode == "direct"

					local ease = event.value.ease or "linear"
					local easeDir = event.value.easeDir or "In"

					if ease == "INSTANT" then
						self:tweenCameraZoom(zoom, 0, isDirectMode)
					else
						local durSeconds = (self.conductor:getStepLengthMs() * duration) / 1000
						local easeFunction = CONSTANTS.WEEKS.EASING_TYPES[ease .. easeDir] or CONSTANTS.WEEKS.EASING_TYPES.linear
						self:tweenCameraZoom(zoom, durSeconds, isDirectMode, easeFunction)
					end
				elseif event.name == "SetHealthIcon" then
					local who = "boyfriend"
					if type(event.value.char) == "number" then
						if event.value.char == 0 then
							who = "boyfriend"
						elseif event.value.char == 1 then
							who = "dad"
						elseif event.value.char == 2 then
							who = "girlfriend"
						end
					elseif type(event.value.char) == "string" then
						who = event.value.char
					end

					if who == "boyfriend" then
						local prevData = {
							x = boyfriendIcon.x,
							y = boyfriendIcon.y,
							scaleX = boyfriendIcon.scaleX,
							scaleY = boyfriendIcon.scaleY,
							orientation = boyfriendIcon.angle,
							offsetX = boyfriendIcon.offsetX,
							offsetY = boyfriendIcon.offsetY,
							shearX = boyfriendIcon.shearX,
							shearY = boyfriendIcon.shearY,
							scale = boyfriendIcon.scale,
							scrollFactor = {boyfriendIcon.scrollFactor[1], boyfriendIcon.scrollFactor[2]},
							flipX = boyfriendIcon.flipX,
							visible = boyfriendIcon.visible,
							mostCommonColour = boyfriendIcon.mostCommonColour
						}
						boyfriendIcon = healthIconPreloads[event.value.id] or icon.newIcon(icon.imagePath(event.value.id), nil, true) or boyfriendIcon
						for k, v in pairs(prevData) do
							boyfriendIcon[k] = v
						end
					elseif who == "dad" then
						local prevData = {
							x = enemyIcon.x,
							y = enemyIcon.y,
							scaleX = enemyIcon.scaleX,
							scaleY = enemyIcon.scaleY,
							orientation = enemyIcon.angle,
							offsetX = enemyIcon.offsetX,
							offsetY = enemyIcon.offsetY,
							shearX = enemyIcon.shearX,
							shearY = enemyIcon.shearY,
							scale = enemyIcon.scale,
							scrollFactor = {enemyIcon.scrollFactor[1], enemyIcon.scrollFactor[2]},
							flipX = enemyIcon.flipX,
							visible = enemyIcon.visible,
							mostCommonColour = enemyIcon.mostCommonColour
						}
						enemyIcon = healthIconPreloads[event.value.id] or icon.newIcon(icon.imagePath(event.value.id, nil, true)) or enemyIcon
						for k, v in pairs(prevData) do
							enemyIcon[k] = v
						end
					end
				elseif event.name == "SetCameraBop" then
					local rate = tonumber(event.value.rate) or CONSTANTS.DEFAULT_ZOOM_RATE
					local offset = tonumber(event.value.offset) or CONSTANTS.DEFAULT_ZOOM_OFFSET
					local intensity = tonumber(event.value.intensity) or 1

					camera.bopIntensity = (CONSTANTS.DEFAULT_BOP_INTENSITY - 1) * intensity + 1
					uiCam.bopIntensity = (CONSTANTS.DEFAULT_BOP_INTENSITY - 1) * intensity * 2
					camera.zoomRate = rate
					camera.zoomRateOffset = offset or CONSTANTS.DEFAULT_ZOOM_OFFSET
				elseif event.name == "ScrollSpeed" then
					local defaultScroll = 1
					local defaultDuration = 4
					local defaultAbsolute = false
					local defaultStrumline = "both"

					local scroll = tonumber(event.value.scroll) or defaultScroll
					local duration = tonumber(event.value.duration) or defaultDuration
					local ease = event.value.ease or "linear"
					local easeDir = event.value.easeDir or "In"

					local strumline = event.value.strumline or defaultStrumline
					local absolute = event.value.absolute or defaultAbsolute

					if not absolute then
						scroll = scroll * speed
					end

					local speeds = {}
					if strumline:lower() == "both" then
						table.insert(speeds, "player")
						table.insert(speeds, "opponent")
					elseif strumline:lower() == "player" then
						table.insert(speeds, "player")
					elseif strumline:lower() == "opponent" then
						table.insert(speeds, "opponent")
					end

					if ease == "INSTANT" then
						for _, s in ipairs(speeds) do
							self:tweenScrollSpeed(scroll, 0, nil, speeds)
						end
					else
						local durSeconds = (self.conductor:getStepLengthMs() * duration) / 1000
						local easeFunction = CONSTANTS.WEEKS.EASING_TYPES[ease .. easeDir] or CONSTANTS.WEEKS.EASING_TYPES.linear
						self:tweenScrollSpeed(scroll, durSeconds, easeFunction, speeds)
					end
				end

				Gamestate.onEvent(event)
				self.stage:call("onSongEvent", event)
				self.song:call("onSongEvent", event)
				for _, obj in ipairs(self.objects) do
					if obj.call then
						obj:call("onSongEvent", event)
					end
				end

				table.remove(songEvents, i)
				break
			end
		end

		for i, event in ipairs(modEvents) do
			if event.time <= absMusicTime then
				Gamestate.onEvent(event)
				self.stage:call("onSongEvent", event)
				self.song:call("onSongEvent", event)
				for _, obj in ipairs(self.objects) do
					if obj.call then
						obj:call("onSongEvent", event)
					end
				end
				table.remove(modEvents, i)
				break
			end
		end

		local decayRate = 0.95
		local elapsed = dt * 60

		if camera.zoomRate > 0 then
			camera.bopMultiplier = util.lerp(1.0, camera.bopMultiplier, math.pow(decayRate, elapsed))
			local zoomPlusBop = camera.currentZoom * camera.bopMultiplier
			camera.zoom = zoomPlusBop

			uiCam.zoom = util.lerp(1, uiCam.zoom, math.pow(decayRate, elapsed))
		end

		self.stage:call("onUpdate", dt)
		self.song:call("onUpdate", dt)
		if self.conductor.onStep then
			self.stage:call("onStepHit", self.conductor.curStep)
			self.song:call("onStepHit", self.conductor.curStep)

			local MAX_RELATIVE_CAM_ZOOM = 1.35

			if camera.zooming and
				uiCam.zoom < (MAX_RELATIVE_CAM_ZOOM * 1) and
				camera.zoomRate > 0 and
				(self.conductor.curStep + (camera.zoomRateOffset or CONSTANTS.DEFAULT_ZOOM_OFFSET) * CONSTANTS.STEPS_PER_BEAT) % (camera.zoomRate * CONSTANTS.STEPS_PER_BEAT) == 0 
			then
				camera.bopMultiplier = camera.bopIntensity
				uiCam.zoom = uiCam.zoom + uiCam.bopIntensity * 1
			end
		end
		if self.conductor.onBeat then
			self.stage:call("onBeatHit", self.conductor.curBeat)
			self.song:call("onBeatHit", self.conductor.curBeat)
		end
		for _, obj in ipairs(self.objects) do
			if obj.update then
				obj:update(dt)
				if obj.call then
					obj:call("onUpdate", dt)
				end
			end

			if self.conductor.onStep and obj.onStepHit then
				obj:onStepHit(self.conductor.curStep)
				if obj.call then
					obj:call("onStepHit", self.conductor.curStep)
				end
			end

			if self.conductor.onBeat and obj.onBeatHit then
				obj:onBeatHit(self.conductor.curBeat)
				if obj.call then
					obj:call("onBeatHit", self.conductor.curBeat)
				end
				if obj.bopper then
					obj:play(obj.thefuckinganim .. obj.suffix)
				end
			end
		end

		for i = 1, #inHolds do
			if inHolds[i] then
				score = score + CONSTANTS.WEEKS.SCORE_HOLD_BONUS_PER_SECOND * dt
			end
		end

		self:checkSongOver()

		self:updateUI(dt)
	end,

	cancelCameraZoomTween = function(self)
		if camZoomTween then
			Timer.cancel(camZoomTween)
			camZoomTween = nil
		end
	end,

	tweenCameraZoom = function(self, zoom, duration, direct, ease)
		zoom = zoom or 1
		duration = duration or 1
		direct = direct or false
		self:cancelCameraZoomTween()

		local target = zoom * (direct and camera.defaultZoom or self.stage.cameraZoom)

		if duration == 0 then
			camera.currentZoom = target
		else
			camZoomTween = Timer.tween(
				duration,
				camera,
				{
					currentZoom = target
				},
				ease or "linear"
			)
		end
	end,

	cancelScrollSpeedTween = function(self)
		for _, tween in ipairs(scrollSpeedTweens) do
			Timer.cancel(tween)
		end

		scrollSpeedTweens = {}
	end,

	tweenScrollSpeed = function(self, speed, duration, ease, alslsl)
		self:cancelScrollSpeedTween()

		speeds.boyfriend = prevTargets.boyfriend or speeds.boyfriend
		speeds.enemy = prevTargets.enemy or speeds.enemy

		prevTargets = {
			boyfriend = boyfriendScrollSpeed,
			enemy = enemyScrollSpeed
		}

		for _, s in ipairs(alslsl) do
			local tgt
			if s == "player" then
				tgt = "boyfriend"
			else
				tgt = "enemy"
			end

			print(duration, speed, ease, tgt, speeds[tgt])
			Timer.tween(duration, speeds, {[tgt] = speed}, ease or "linear")
		end
	end,

	judgeNote = function(self, msTiming)
		if msTiming <= CONSTANTS.WEEKS.JUDGE_THRES[settings.judgePreset].SICK_THRES then
			return "sick"
		elseif msTiming < CONSTANTS.WEEKS.JUDGE_THRES[settings.judgePreset].GOOD_THRES then
			return "good"
		elseif msTiming < CONSTANTS.WEEKS.JUDGE_THRES[settings.judgePreset].BAD_THRES then
			return "bad"
		elseif msTiming < CONSTANTS.WEEKS.JUDGE_THRES[settings.judgePreset].SHIT_THRES then
			return "shit"
		else
			return "miss"
		end
	end,

	scoreNote = function(self, msTiming)
		if msTiming > CONSTANTS.WEEKS.JUDGE_THRES[settings.judgePreset].MISS_THRES then
			return CONSTANTS.WEEKS.MISS_SCORE
		else
			if msTiming < CONSTANTS.WEEKS.JUDGE_THRES[settings.judgePreset].PERFECT_THRES then
				return CONSTANTS.WEEKS.MAX_SCORE
			else
				local factor = 1 - 1 / (1 + math.exp(-CONSTANTS.WEEKS.SCORING_SLOPE * (msTiming - CONSTANTS.WEEKS.SCORING_OFFSET)))
				local score = math.floor(CONSTANTS.WEEKS.MAX_SCORE * factor + CONSTANTS.WEEKS.MIN_SCORE)
				return score
			end
		end
	end,

	removeAudio = function(self, name)
		if name == "inst" then
			if inst then inst:stop() end
			inst = nil
		elseif name == "enemy" then
			if voicesEnemy then voicesEnemy:stop() end
			voicesEnemy = nil
		elseif name == "bf" then
			if voicesBF then voicesBF:stop() end
			voicesBF = nil
		end
	end,

	getAudio = function(self, name)
		if name == "inst" then
			return inst
		elseif name == "enemy" then
			return voicesEnemy
		elseif name == "bf" then
			return voicesBF
		end
	end,

	getHealth = function(self)
		return health
	end,

	setAltAnims = function(self, useAlt)
		useAltAnims = useAlt
	end,

	updateUI = function(self, dt)
		if paused then return end

		if IS_CLASSIC_MOVEMENT then
			local adjustedLerp = 1 - math.pow(1.0 - 0.04, dt * 60)
			camera.x = camera.x + (CAM_LERP_POINT.x - camera.x) * adjustedLerp
			camera.y = camera.y + (CAM_LERP_POINT.y - camera.y) * adjustedLerp
		end

		NoteSplash:update(dt)
		HoldCover:update(dt)

		healthLerp = util.coolLerp(healthLerp, health, 0.15)

		popupScore:update(dt)

		if ratingTextScale > 1 then
			ratingTextScale = ratingTextScale - 0.1 * dt
			if ratingTextScale < 1 then
				ratingTextScale = 1
			end
		end

		for i = 1, 4 do
			local enemyArrow = enemyArrows[i]
			local boyfriendArrow = boyfriendArrows[i]
			local enemyNote = enemyNotes[i]
			local boyfriendNote = boyfriendNotes[i]
			local curAnim = CONSTANTS.WEEKS.ANIM_LIST[i]
			local curInput = CONSTANTS.WEEKS.INPUT_LIST[i]
			local gfNote = gfNotes[i]

			enemyArrow:update(dt)
			boyfriendArrow:update(dt)

			if not enemyArrow:isAnimated() then
				enemyArrow:animate(CONSTANTS.WEEKS.NOTE_LIST[i], false)
			end

			if input:pressed(curInput) then
				self:keyPressed(i)
			end
			if input:released(curInput) then
				self:keyReleased(i)
			end
			if input:down(curInput) then
				self:keyDown(i)
			end

			if #enemyNote > 0 then
				if (enemyNote[1].time <= -100) then
					table.remove(enemyNote, 1)
				end
			end

			for _, hit in ipairs(enemyNoteGameplay) do
				if hit.time - musicTime <= 0 and not hit.press then
					self:enemyKeyPressed(hit.key)
					hit.press = true
				end

				if hit.press and not hit.release then
					self:enemyKeyDown(hit.key, enemy)
				end

				if hit.releasedTime - musicTime <= 0 and not hit.release then
					self:enemyKeyReleased(hit.key)
					hit.release = true
				end
			end

			if #gfNote > 0 then
				if gfNote[1].time - musicTime <= 0 then
					for _, obj in ipairs(self.objects) do
						if obj.characterType == CHARACTER_TYPE.GF then
							obj:play(curAnim, true, false)
							obj.holdTimer = 0
						end
					end

					table.remove(gfNote, 1)
				end
			end

			if #boyfriendNote > 0 then
				if isResetting then
					goto continue
				end
				if (boyfriendNote[1].time - musicTime <= -200) and not boyfriendNote[1].causesMiss and not boyfriendNote[1].wasGoodHit then
					if voicesBF then 
						voicesBF:setVolume(0)
					end
					local continue
					local healthChange = -CONSTANTS.WEEKS.HEALTH.MISS_PENALTY * healthLossMult * boyfriendNote[1].healthLossMult
					local event = eventCreator:noteMiss(boyfriendNote[1].ver, i, nil, healthChange)

					for _, obj in ipairs(self.objects) do
						if obj.characterType == CHARACTER_TYPE.BF then
							obj:play(curAnim .. "miss", true, false)
						end
						if obj.call then
							obj:call("onNoteMiss", event)
						end
					end
					self.stage:call("onNoteMiss", event)
					self.song:call("onNoteMiss", event)
	
					if boyfriendNote[1]:getAnimName() ~= "hold" and boyfriendNote[1]:getAnimName() ~= "end" then 
						health = health - event.healthChange
						misses = misses + 1
					else
						health = health - event.healthChange
						continue = Gamestate.onNoteMiss(boyfriend, boyfriendNote[1].ver, "BoyfriendMiss", i)
					end

					table.remove(boyfriendNote, 1)
					
					if combo >= 5 then
						
					end

					if combo >= 70 then
						for _, obj in ipairs(self.objects) do
							if obj.characterType == CHARACTER_TYPE.GF then
								obj:play("drop70", true, false)
								obj.holdTimer = 0
							end
						end
					end
					combo = 0
				end

				::continue::
			end

			if not input:down(curInput) and not HoldCover:getVisibility(i, 1) then
				HoldCover:hide(i, 1)
				inHolds[i] = false
			end

			if input:released(curInput) then
				boyfriendArrow:animate(CONSTANTS.WEEKS.NOTE_LIST[i], false)
			end
		    ::continue::
		end

		-- Enemy
		if health >= CONSTANTS.WEEKS.HEALTH.WINNING_THRESHOLD then
			enemyIcon:setFrame(2)
		elseif health < CONSTANTS.WEEKS.HEALTH.WINNING_THRESHOLD then
			enemyIcon:setFrame(1)
		end

		-- Boyfriend
		if not self.ignoreHealthClamping then
			health = util.clamp(health, CONSTANTS.WEEKS.HEALTH.MIN, CONSTANTS.WEEKS.HEALTH.MAX)
		end
		if health > CONSTANTS.WEEKS.HEALTH.LOSING_THRESHOLD and boyfriendIcon:getCurFrame() == 2 then
			boyfriendIcon:setFrame(1)
		elseif health <= 0 and self.useBuiltinGameover then -- Game over
			if not settings.practiceMode and not dying then
				dying = true
				self:onDeath()
			end
		elseif health <= CONSTANTS.WEEKS.HEALTH.LOSING_THRESHOLD and boyfriendIcon:getCurFrame() == 1 then
			boyfriendIcon:setFrame(2)
		end

		enemyIcon.x = healthBar.x + healthBar.width - 75 - healthLerp * 500
		boyfriendIcon.x = healthBar.x + healthBar.width + 75 - healthLerp * 500

		if self.conductor.onBeat then
			enemyIcon.sizeX, enemyIcon.sizeY = 1.75, 1.75
			boyfriendIcon.sizeX, boyfriendIcon.sizeY = -1.75, 1.75
		end

		enemyIcon.sizeX, enemyIcon.sizeY = util.coolLerp(enemyIcon.sizeX, 1.5, 0.1), enemyIcon.sizeX
		boyfriendIcon.sizeX, boyfriendIcon.sizeY = util.coolLerp(boyfriendIcon.sizeX, -1.5, 0.1), -boyfriendIcon.sizeX
	end,

	add = function(self, object, sort)
		sort = sort == nil and false or sort
		table.insert(self.objects, object)
		if object.characterType then
			self.stage:call("addCharacter", object, object.name or "")
			self.song:call("addCharacter", object, object.name or "")
		end
		if sort then
			self:sort()
		end
	end,

	get = function(self, name)
		for _, obj in ipairs(self.objects) do
			if obj.name == name then
				return obj
			end
		end
		return nil
	end,

	getProps = function(self)
		return self.objects
	end,

	getCharacter = function(self, name)
		name = name or "boyfriend"
		for _, obj in ipairs(self.objects) do
			if obj.characterType then
				if obj.name == name then
					return obj
				end
			end
		end
	end,

	getSongName = function(self)
		return self.metadata.songName
	end,

	getSongID = function(self)
		return SONGID:lower():strip()
	end,

	getMetadata = function(self)
		return self.metadata
	end,

	getChart = function(self)
		return self.chart
	end,

	getCamera = function(self)
		return camera
	end,

	getCameraLerpPoint = function(self)
		return CAM_LERP_POINT
	end,

	remove = function(self, object, sort)
		for i, obj in ipairs(self.objects) do
			if obj == object then
				table.remove(self.objects, i)
				return
			end
		end

		if sort then
			self:sort()
		end
	end,

	sort = function(self)
		table.sort(self.objects, function(a, b)
			return (a.zIndex or 0) < (b.zIndex or 0)
		end)
	end,

	setStageShader = function(self, shader)
		self.stageShader = shader
	end,
	setUIShader = function(self, shader)
		self.uiShader = shader
	end,

	setClassicMovement = function(self, isClassic)
		IS_CLASSIC_MOVEMENT = isClassic
	end,

	getScreen = function(self)
		if not self.stageCanvas then self.stageCanvas = love.graphics.newCanvas(1280, 720) end
		return self.stageCanvas
	end,

	getUI = function(self)
		if not self.uiCanvas then self.uiCanvas = love.graphics.newCanvas(1280, 720) end
		return self.uiCanvas
	end,

	renderStage = function(self)
		if not self.stageCanvas then self.stageCanvas = love.graphics.newCanvas(1280, 720) end
		local lastCanvas = love.graphics.getCanvas()

		love.graphics.setCanvas({self.stageCanvas, stencil = true})
			love.graphics.clear()
			love.graphics.push()
				love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
				love.graphics.scale(camera.zoom, camera.zoom)
				love.graphics.translate(-graphics.getWidth() / 2, -graphics.getHeight() / 2)

				for _, object in ipairs(self.objects) do
					if object.draw then
						object:draw(camera)
						if object.call then
							object:call("onDraw", camera)
						end
					end
				end
			love.graphics.pop()
		love.graphics.setCanvas({lastCanvas, stencil = true})

		local lastShader = love.graphics.getShader()
		love.graphics.setShader(self.stageShader)
		love.graphics.draw(self.stageCanvas)
		love.graphics.setShader(lastShader)
	end,

	drawRating = function(self)
		love.graphics.push()
			--love.graphics.origin()
			love.graphics.translate(0, -35)
			graphics.setColor(1, 1, 1)
			if pixel and not settings.pixelPerfect then
				love.graphics.translate(-16, 0)
				popupScore:udraw(5.25, 5.25)
			else
				popupScore:draw()
			end
			graphics.setColor(1, 1, 1)
		love.graphics.pop()
	end,

	flash = function(self, duration)
		FLASH[1] = 1
		Timer.tween(duration or 0.25, FLASH, {0}, "linear")
	end,

	drawUI = function(self)
		if not UI_VISIBLE then return end
		if not self.uiCanvas then self.uiCanvas = love.graphics.newCanvas(1280, 720) end

		local lastCanvas = love.graphics.getCanvas()
		love.graphics.setCanvas({self.uiCanvas, stencil = true})
			love.graphics.clear()
			NOTES_BATCH:clear()
			if paused then
				love.graphics.push()
					love.graphics.setFont(pauseFont)
					love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
					graphics.setColor(0, 0, 0, 0.8)
					love.graphics.rectangle("fill", -10000, -2000, 25000, 10000)
					graphics.setColor(1, 1, 1)
					pauseShadow:draw()
					pauseBG:draw()
					if pauseMenuSelection ~= 1 then
						uitextflarge("Resume", -305, -275, 600, "center", false)
					else
						uitextflarge("Resume", -305, -275, 600, "center", true)
					end
					if pauseMenuSelection ~= 2 then
						uitextflarge("Restart", -305, -75, 600, "center", false)
					else
						uitextflarge("Restart", -305, -75, 600, "center", true)
					end
					if pauseMenuSelection ~= 3 then
						uitextflarge("Quit", -305, 125, 600, "center", false)
					else
						uitextflarge("Quit", -305, 125, 600, "center", true)
					end
					graphics.setColor(1,1,1)
					love.graphics.setFont(font)
				love.graphics.pop()

				love.graphics.setCanvas(lastCanvas)
				local lastShader = love.graphics.getShader()
				love.graphics.draw(self.uiCanvas)
				love.graphics.setShader(lastShader)
				return
			end
			if self.overrideDrawHealthbar then
				self:overrideDrawHealthbar(score, health, misses, ratingPercent, healthLerp)
			else
				self:drawHealthbar()
			end
			love.graphics.push()
				love.graphics.translate(push:getWidth() / 2, push:getHeight() / 2)
				love.graphics.scale(0.7, 0.7)
				love.graphics.scale(uiCam.zoom, uiCam.zoom)
				love.graphics.translate(uiCam.x, uiCam.y)
				graphics.setColor(1, 1, 1)

				for i = 1, 4 do
					if enemyArrows[i]:getAnimName() == "off" then
						if not settings.middlescroll then
							graphics.setColor(0.6, 0.6, 0.6, enemyArrows[i].alpha)
						else
							graphics.setColor(0.6, 0.6, 0.6, enemyArrows[i].alpha)
						end
					else
						graphics.setColor(1, 1, 1, enemyArrows[i].alpha)
					end
					if pixel and not settings.pixelPerfect then
						enemyArrows[i]:udraw(8, 8)
					else
						enemyArrows[i]:draw()
					end
					graphics.setColor(1, 1, 1)
					if pixel and not settings.pixelPerfect then
						boyfriendArrows[i]:udraw(8, 8)
					else
						boyfriendArrows[i]:draw()
					end
					graphics.setColor(1, 1, 1)

					love.graphics.push()
						love.graphics.push()
							for j = #enemyNotes[i], 1, -1 do
							if enemyNotes[i][j].y <= 800 then
								local animName = enemyNotes[i][j]:getAnimName()
								if animName ~= "hold" and animName ~= "end" then
									if settings.middleScroll then
										graphics.setColor(1, 1, 1, 0.8 * enemyNotes[i][j].alpha)
									else
										graphics.setColor(1, 1, 1, 1 * enemyNotes[i][j].alpha)
									end

									if not pixel then
										if enemyNotes[i][j].children then
											enemyNotes[i][j].children[1]:draw()
											if settings.downscroll then
												enemyNotes[i][j].children[2].sizeY = -1
											end
											enemyNotes[i][j].children[2]:draw()
										end
										enemyNotes[i][j]:draw()
									else
										if not settings.downscroll then
											if enemyNotes[i][j].children then
												enemyNotes[i][j].children[1]:udraw(8, -1, true)
												enemyNotes[i][j].children[2]:udraw(8, 8, true)
											end
											enemyNotes[i][j]:udraw(8, 8)
										else
											if enemyNotes[i][j].children then
												enemyNotes[i][j].children[1]:udraw(8, -1, true)
												enemyNotes[i][j].children[2]:udraw(8, 8 * -1, true)
											end
											enemyNotes[i][j]:udraw(8, 8)
										end
									end
									graphics.setColor(1, 1, 1)
								end
							end
						end
						love.graphics.pop()
						love.graphics.push()
							for j = #boyfriendNotes[i], 1, -1 do
							if boyfriendNotes[i][j].y <= 800 then
								local animName = boyfriendNotes[i][j]:getAnimName()
								if animName ~= "hold" and animName ~= "end" then
									if not pixel then 
										if boyfriendNotes[i][j].children then
											boyfriendNotes[i][j].children[1]:draw()
											if settings.downscroll then
												boyfriendNotes[i][j].children[2].sizeY = -1
											end
											boyfriendNotes[i][j].children[2]:draw()
										end
										boyfriendNotes[i][j]:draw()
									else
										if not settings.downscroll then
											if boyfriendNotes[i][j].children then
												boyfriendNotes[i][j].children[1]:udraw(8, -1, true)
												boyfriendNotes[i][j].children[2]:udraw(8, 8, true)
											end
											boyfriendNotes[i][j]:udraw(8, 8)
										else
											if boyfriendNotes[i][j].children then
												boyfriendNotes[i][j].children[1]:udraw(8, -1, true)
												boyfriendNotes[i][j].children[2]:udraw(8, 8 * -1, true)
											end
											boyfriendNotes[i][j]:udraw(8, 8)
										end
									end
								end
							end
						end
						love.graphics.pop()
						graphics.setColor(1, 1, 1)
					love.graphics.pop()
				end

				love.graphics.draw(NOTES_BATCH)

				HoldCover:draw()
				if pixel and not settings.pixelPerfect then
					NoteSplash:udraw(8, 8)
				else
					NoteSplash:draw()
				end

				graphics.setColor(1, 1, 1, countdownFade[1])
				if pixel and not settings.pixelPerfect then
					countdown:udraw(6.75, 6.75)
				else
					countdown:draw()
				end
				graphics.setColor(1, 1, 1)
			love.graphics.pop()

			love.graphics.push()
				graphics.setColor(1, 1, 1, FLASH[1])
				love.graphics.rectangle("fill", -1000, -1000, 25000, 10000)
				graphics.setColor(1, 1, 1)
			love.graphics.pop()
		love.graphics.setCanvas({lastCanvas, stencil = true})

		local lastShader = love.graphics.getShader()
		love.graphics.setShader(self.uiShader)
		love.graphics.draw(self.uiCanvas)
		love.graphics.setShader(lastShader)
	end,

	healthbarText = function(self, text, offsetX, offsetY)
		local text = text or "???"
		local colourInline ={1, 1, 1, 1}
		local colourOutline = {0, 0, 0, 1}
		local offsetX = offsetX or -100
		local offsetY = offsetY or 50

		colourOutline[4] = colourOutline[4] * hudFade[1]
		colourInline[4] = colourInline[4] * hudFade[1]

		local x = healthBar.x+offsetX
		local y = healthBar.y+offsetY
		local format = "center"

		local mode = settings.scoringType

		if mode == "VSlice" then
			x = 300+offsetX
			y = 400+offsetY
			if downscrollOffset == -750 then
				y = y + downscrollOffset - 50
			else
				y = y - 60
			end
			format = "left"
		elseif mode == "Minimal" then
			x = x - 35
		end

		local lastFont = love.graphics.getFont()
		love.graphics.push()
		if mode == "Psych" then
			love.graphics.setFont(psychScoringFont)
			love.graphics.translate(-(psychScoringFont:getWidth(text) * (ratingTextScale - 1))/2, -(psychScoringFont:getHeight(text) * (ratingTextScale - 1)))
		else
			love.graphics.setFont(scoringFont)
		end
		uitextfColored(text, x, y, 1300, format, colourOutline, colourInline, 0, ratingTextScale, ratingTextScale)
		love.graphics.pop()
		love.graphics.setFont(lastFont)
		self:drawRating()
	end,

	hideUI = function(self)
		UI_VISIBLE = false
	end,

	showUI = function(self)
		UI_VISIBLE = true
	end,

	keyPressed = function(self, key)
		boyfriendArrows[key]:animate(CONSTANTS.WEEKS.NOTE_LIST[key] .. " press")
		if #boyfriendNotes[key] > 0 then
			local note
			for i = 1, #boyfriendNotes[key] do
				if boyfriendNotes[key][i].visible then
					note = boyfriendNotes[key][i]
					break
				end
			end

			if not note then return end
			
			if note.canBeHit and not note.tooLate and not note.wasGoodHit then
				boyfriendArrows[key]:animate(CONSTANTS.WEEKS.NOTE_LIST[key] .. " confirm")
				self.pressedNotes[key] = note
				self:goodNoteHit(note, note.time - musicTime)
			end 
		end
	end,

	keyReleased = function(self, key)
		boyfriendArrows[key]:animate(CONSTANTS.WEEKS.NOTE_LIST[key])

		for i = 1, #boyfriendNotes[key] do
			if boyfriendNotes[key][i] == self.pressedNotes[key] then
				table.remove(boyfriendNotes[key], i)
			end
		end
	end,

	keyDown = function(self, key)
		for _, note in ipairs(boyfriendNotes[key]) do
			if note.wasGoodHit and note.children then
				boyfriendArrows[key]:animate(CONSTANTS.WEEKS.NOTE_LIST[key] .. " confirm")
				for _, obj in ipairs(self.objects) do
					if obj.characterType == CHARACTER_TYPE.BF then
						obj:play(CONSTANTS.WEEKS.ANIM_LIST[note.col], true, false)
					end
				end
				if (note.children and note.endTime - musicTime <= 30) or (note.children and note.children[1].sizeY < 0) then
					table.remove(boyfriendNotes[key], 1)
				end
			end
		end
	end,

	goodNoteHit = function(self, note, time)
		if not note.wasGoodHit then
			if voicesBF then voicesBF:setVolume(1) end
			note.wasGoodHit = true
			health = health + 0.095

			combo = combo + 1
			noteCounter = noteCounter + 1

			local judge = self:judgeNote(time)
			score = score + self:scoreNote(time)

			local continue = (Gamestate.onNoteHit(boyfriend, note.ver, judge, note.col) == nil or false) and true or false

			local healthChange = (CONSTANTS.WEEKS.HEALTH.BONUS[string.upper(judge)] or 0) * healthGainMult * note.healthGainMult
			if note:getAnimName() == "hold" or note:getAnimName() == "end" then
				healthChange = 0.0125 * healthGainMult * note.healthGainMult
			end

			if continue then
				local event = eventCreator:noteHit(note.ver, note.col, judge, healthChange)
				for _, obj in ipairs(self.objects) do
					if obj.characterType == CHARACTER_TYPE.BF then
						obj:play(CONSTANTS.WEEKS.ANIM_LIST[note.col], true, false)
					end
					if obj.call then
						obj:call("onNoteHit", event)
					end
				end
			end

			if boyfriend then boyfriend.lastHit = musicTime end

			self:calculateRating()

			note.visible = false
			if note.children and #note.children > 0 then
				note.moveWithScroll = false
			end
		end
	end,

	enemyKeyPressed = function(self, key)
		enemyArrows[key]:animate(CONSTANTS.WEEKS.NOTE_LIST[key] .. " press")
		if #enemyNotes[key] > 0 then
			local note
			for i = 1, #enemyNotes[key] do
				if enemyNotes[key][i].visible then
					note = enemyNotes[key][i]
					break
				end
			end

			if not note then return end

			if note.canBeHit and not note.tooLate and not note.wasGoodHit then
				enemyArrows[key]:animate(CONSTANTS.WEEKS.NOTE_LIST[key] .. " confirm")
				self.pressedNotes[key+4] = note
				self:enemyGoodNoteHit(note, note.time - musicTime)
			end
		end
	end,

	enemyGoodNoteHit = function(self, note, time)
		if not note.wasGoodHit then
			note.wasGoodHit = true

			note.visible = false
			if note.children and #note.children > 0 then
				note.moveWithScroll = false
			end

			useAltAnims = false
			local whohit = enemy

			for _, obj in ipairs(self.objects) do
				if obj.characterType == CHARACTER_TYPE.DAD then
					local whohit = obj
					local continue = true
					local enemyArrow = enemyArrows[note.col]
					local curAnim = CONSTANTS.WEEKS.ANIM_LIST[note.col]
					
					if not didEvent then
						continue = (Gamestate.onNoteHit(enemy, note.ver, "EnemyHit", note.col) == nil or false) and true or false
						local event = eventCreator:noteHit(note.ver, note.col, "EnemyHit", 0)
						event.mustHit = false
						self.stage:call("onNoteHit", event)
						self.song:call("onNoteHit", event)
						for _, obj in ipairs(self.objects) do
							if obj.call then
								obj:call("onNoteHit", event)
							end
						end
						didEvent = true
					else
						continue = true
					end

					if continue then
						if note:getAnimName() == "hold" or note:getAnimName() == "end" then
							if note:getAnimName() == "hold" then
								HoldCover:show(i, 2, note.x, note.y)
							else
								HoldCover:hide(i, 2)
							end
							if useAltAnims then
								if whohit then
									whohit:play(curAnim .. "-alt", false, false)
								end
							else
								if whohit then 
									whohit:play(curAnim, false, false)
								end
							end
							whohit.holdTimer = 0
						else
							NoteSplash:new(
								{
									anim = CONSTANTS.WEEKS.NOTE_LIST[note.col] .. tostring(love.math.random(1, 2)),
									posX = enemyArrow.x,
									posY = enemyArrow.y,
									alpha = enemyArrow.alpha,
									visible = enemyArrow.visible,
								},
								i
							)
							if useAltAnims then
								if whohit then 
									whohit:play(curAnim .. "-alt", true, false)
									if whohit.call then
										whohit:call("onNoteHit", {noteType = note.ver, direction = note.col, anim = curAnim .. "-alt"})
									end
									self.stage:call("onNoteHit", whohit, note.ver, "EnemyHit", note.col, curAnim .. "-alt")
									self.song:call("onNoteHit", whohit, note.ver, "EnemyHit", note.col, curAnim .. "-alt")
								end
							else
								if whohit then 
									whohit:play(curAnim, true, false)
									if whohit.call then
										whohit:call("onNoteHit", {noteType = note.ver, direction = note.col, anim = curAnim})
									end
									self.stage:call("onNoteHit", whohit, note.ver, "EnemyHit", note.col, curAnim)
									self.song:call("onNoteHit", whohit, note.ver, "EnemyHit", note.col, curAnim)
								end
							end

							whohit.holdTimer = 0
						end
					end

					if whohit then whohit.lastHit = musicTime end
				end
			end
		end

		return nil
	end,

	enemyKeyReleased = function(self, key)
		for i = 1, #enemyNotes[key] do
			if enemyNotes[key][i] == self.pressedNotes[key+4] then
				table.remove(enemyNotes[key], i)
			end
		end
	end,

	enemyKeyDown = function(self, key, whohit)
		for _, note in ipairs(enemyNotes[key]) do
			enemyArrows[key]:animate(CONSTANTS.WEEKS.NOTE_LIST[key] .. " confirm")
			if useAltAnims then
				for _, obj in ipairs(self.objects) do
					if obj.characterType == CHARACTER_TYPE.DAD then
						obj:play(curAnim .. "-alt", true, false)
						break
					end
				end
			else
				for _, obj in ipairs(self.objects) do
					if obj.characterType == CHARACTER_TYPE.DAD then
						obj:play(curAnim, true, false)
						break
					end
				end
			end
			if note.children and note.endTime - musicTime <= 30 then
				table.remove(enemyNotes[key], 1)
			end
		end
	end,

	debugKeyPressed = function(self, k)
		-- are we actually in a song?
		if not self.inSong then return end
		if k == "p" then
			if camTween then
				Timer.cancel(camTween)
			end
			if inst then
				inst:stop()
			end
			if voicesBF then
				voicesBF:stop()
			end
			if voicesEnemy then
				voicesEnemy:stop()
			end
			--Gamestate.push(gameoverSubstate)
			Timer.after(boyfriend:getDeathPreTransitionDelay() or 0, function()
				Gamestate.push(gameoverSubstate)
			end)
		elseif k == "]" then
			musicTime = (inst:getDuration() - 1) * 1000
			inst:seek(musicTime / 1000)
			if voicesBF then
				voicesBF:seek(musicTime / 1000)
			end
			if voicesEnemy then
				voicesEnemy:seek(musicTime / 1000)
			end
		end
	end,

	generateScoringText = function(self, visibility)
		-- KE
		local mode = settings.scoringType

		local returnStr = ""
		if mode == "KE" then
			local ranking = "N/A"
			if misses == 0 and badCounter == 0 and shitCounter == 0 and goodCounter == 0 then
				ranking = "(MFC)"
			elseif misses == 0 and badCounter == 0 and shitCounter == 0 and goodCounter >= 1 then
				ranking = "(GFC)"
			elseif misses == 0 then
				ranking = "(FC)"
			elseif misses < 10 then
				ranking = "(SDCB)"
			else
				ranking = "(Clear)"
			end

			-- Wife3 rating
			local condition = getWife3Condition(ratingPercent*100)
			if condition == 1 then
				ranking = ranking .. " AAAAA"
			elseif condition == 2 then
				ranking = ranking .. " AAAA:"
			elseif condition == 3 then
				ranking = ranking .. " AAAA."
			elseif condition == 4 then
				ranking = ranking .. " AAAA"
			elseif condition == 5 then
				ranking = ranking .. " AAA:"
			elseif condition == 6 then
				ranking = ranking .. " AAA."
			elseif condition == 7 then
				ranking = ranking .. " AAA"
			elseif condition == 8 then
				ranking = ranking .. " AA:"
			elseif condition == 9 then
				ranking = ranking .. " AA."
			elseif condition == 10 then
				ranking = ranking .. " AA"
			elseif condition == 11 then
				ranking = ranking .. " A:"
			elseif condition == 12 then
				ranking = ranking .. " A."
			elseif condition == 13 then
				ranking = ranking .. " A"
			elseif condition == 14 then
				ranking = ranking .. " B"
			elseif condition == 15 then
				ranking = ranking .. " C"
			else
				ranking = ranking .. " D"
			end

			if ratingPercent == 0 then
				ranking = "N/A"
			end

			returnStr = "NPS: " .. #nps .. " (Max " .. (maxNPS < 0 and 0 or math.floor(maxNPS)) .. ") | Score: " .. (score < 0 and 0 or math.floor(score)) .. " | Combo Breaks: " .. math.floor(misses) .. " | Accuracy: " .. ((math.floor(ratingPercent * 10000) / 100)) .. "% | " .. ranking
		elseif mode == "Psych" then
			local phrase = "?"
			if misses == 0 then
				if badCounter > 0 or shitCounter > 0 then phrase = "FC"
				elseif goodCounter > 0 then phrase = "GFC"
				elseif sickCounter > 0 then phrase = "SFC"
				end
			else
				if misses < 10 then 
					phrase = "SDCB"
				else
					phrase = "Clear"
				end
			end

			local ratingStr = getRatingName(ratingPercent) .. " (" .. ((math.floor(ratingPercent * 10000) / 100)) .. "%)" .. " - " .. phrase
			if phrase == "?" then
				ratingStr = "?"
			end

			returnStr = "Score: " .. math.floor(score) .. " | Misses: " .. math.floor(misses) .. " | Rating: " .. ratingStr
		elseif mode == "VSlice" then
			returnStr = "Score: " .. commaFormat(math.floor(score))
		elseif mode == "Minimal" then
			local ratingStr = math.floor(ratingPercent * 10000) / 100 .. "%"
			if ratingPercent == 0 then
				ratingStr = "N/A"
			end
			returnStr = math.floor(score) .. " | " .. math.floor(misses) .. " | " .. ratingStr
		end

		return returnStr
	end,

	drawHealthbar = function(self, visibility)
		local visibility = visibility or 1
		love.graphics.push()
			love.graphics.translate(push:getWidth() / 2, push:getHeight() / 2)
			love.graphics.scale(0.7, 0.7)
			love.graphics.scale(uiCam.zoom, uiCam.zoom)
			love.graphics.translate(uiCam.x, uiCam.y)
			graphics.setColor(1, 1, 1, visibility * hudFade[1])
			if settings.colouredHealthbar then
				graphics.setColor(P2HealthColors[1], P2HealthColors[2], P2HealthColors[3], hudFade[1])
			else
				graphics.setColor(1, 0, 0, hudFade[1])
			end
			love.graphics.rectangle("fill", healthBar.x, healthBar.y, healthBar.width, healthBar.height)
			if settings.colouredHealthbar then
				graphics.setColor(P1HealthColors[1], P1HealthColors[2], P1HealthColors[3], hudFade[1])
			else
				graphics.setColor(0, 1, 0, hudFade[1])
			end
			love.graphics.rectangle("fill", -healthBar.x, healthBar.y, -healthLerp * (healthBar.width/2), healthBar.height)
			graphics.setColor(0, 0, 0, hudFade[1])
			love.graphics.setLineWidth(8)
			love.graphics.rectangle("line", healthBar.x, healthBar.y, healthBar.width, healthBar.height)
			love.graphics.setLineWidth(1)
			graphics.setColor(1, 1, 1, hudFade[1])

			boyfriendIcon:draw()
			enemyIcon:draw()

			if self.overrideHealthbarText then
				self:overrideHealthbarText(score, misses, ((math.floor(ratingPercent * 10000) / 100)) .. "%")
			else
				local text = self:generateScoringText()
				self:healthbarText(text)
			end

			graphics.setColor(1, 1, 1)
		love.graphics.pop()
	end,

	draw = function(self)
		self:renderStage()
		self:drawUI()
	end,

	leave = function(self)
		if inst then inst:stop(); inst = nil end
		if voicesBF then voicesBF:stop(); voicesBF = nil end
		if voicesEnemy then voicesEnemy:stop(); voicesEnemy = nil end

		playMenuMusic = true

		camera:removePoint("boyfriend")
		camera:removePoint("enemy")
		camera:removePoint("girlfriend")

		Timer.clear()

		noteSprites = nil

		camera.defaultZoom = 1

		healthIconPreloads = {}
		inHolds = {false, false, false, false}

		self.inSong = false

		self.songEnded = false

		self:setStageShader(nil)
		self:setUIShader(nil)

		NoteSplash:clear()

		graphics.clearCache()
	end
}
