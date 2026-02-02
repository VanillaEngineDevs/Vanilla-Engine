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

local camTween, bumpTween

local ratingTimers = {}

local useAltAnims

healthLerp = 1

local dying = false

noteSprites = nil

local nps = {}
maxNPS = 0

local isResetting = false
local resettingTime = {0}

local allStates = {
	sickCounter = 0,
	goodCounter = 0,
	badCounter = 0,
	shitCounter = 0,
	missCounter = 0,
	maxCombo = 0,
	score = 0
}

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

local IS_CLASSIC_MOVEMENT = false
CAM_LERP_POINT = {x = 0, y = 0}
SMOOTH_RESET = true

modEvents = {}
local CURCHART = {
}

sickCounter, goodCounter, badCounter, shitCounter, missCounter, maxCombo, score = 0, 0, 0, 0, 0, 0, 0

NOTES_BATCH = nil

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

return {
	enter = function(self, option)
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

		if option ~= "pixel" then
			pixel = false
			sounds = {
				countdown = {
					three = love.audio.newSource("sounds/countdown-3.ogg", "static"),
					two = love.audio.newSource("sounds/countdown-2.ogg", "static"),
					one = love.audio.newSource("sounds/countdown-1.ogg", "static"),
					go = love.audio.newSource("sounds/countdown-go.ogg", "static")
				},
				miss = {
					love.audio.newSource("sounds/miss1.ogg", "static"),
					love.audio.newSource("sounds/miss2.ogg", "static"),
					love.audio.newSource("sounds/miss3.ogg", "static")
				},
				breakfast = love.audio.newSource("music/breakfast.ogg", "stream")
			}

			images = {
				notes = love.graphics.newImage(graphics.imagePath("NOTE_assets")),
				numbers = love.graphics.newImage(graphics.imagePath("numbers")),
			}

			sprites = {
				numbers = love.filesystem.load("sprites/numbers.lua"),
			}

			rating = love.filesystem.load("sprites/rating.lua")

			--[[ girlfriend = BaseCharacter("sprites/characters/girlfriend.lua")
			boyfriend = BaseCharacter("sprites/characters/boyfriend.lua") ]]

			countdown = love.filesystem.load("sprites/countdown.lua")()
		else
			pixel = true
			love.graphics.setDefaultFilter("nearest", "nearest")
			sounds = {
				countdown = {
					three = love.audio.newSource("sounds/pixel/countdown-3.ogg", "static"),
					two = love.audio.newSource("sounds/pixel/countdown-2.ogg", "static"),
					one = love.audio.newSource("sounds/pixel/countdown-1.ogg", "static"),
					go = love.audio.newSource("sounds/pixel/countdown-date.ogg", "static")
				},
				miss = {
					love.audio.newSource("sounds/pixel/miss1.ogg", "static"),
					love.audio.newSource("sounds/pixel/miss2.ogg", "static"),
					love.audio.newSource("sounds/pixel/miss3.ogg", "static")
				},
				death = love.audio.newSource("sounds/pixel/death.ogg", "static"),
				breakfast = love.audio.newSource("music/breakfast.ogg", "stream")
			}

			images = {
				notes = love.graphics.newImage(graphics.imagePath("pixel/notes")),
				numbers = love.graphics.newImage(graphics.imagePath("pixel/numbers")),
			}

			sprites = {
				numbers = love.filesystem.load("sprites/pixel/numbers.lua"),
			}

			rating = love.filesystem.load("sprites/pixel/rating.lua")

			--[[ girlfriend = BaseCharacter("sprites/characters/girlfriend-pixel.lua")
			boyfriend = BaseCharacter("sprites/characters/boyfriend-pixel.lua") ]]

			countdown = love.filesystem.load("sprites/pixel/countdown.lua")()
		end

		NOTES_BATCH = love.graphics.newSpriteBatch(images.notes, 1000)

		popupScore:init(sprites.numbers, rating)

		countdownFade = {}

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
	end,

	load = function(self, wasntRestart)
		if wasntRestart == nil then
			wasntRestart = true
		end
		SMOOTH_RESET = true
		quitPressed = false
		camera.camBopIntensity = 1
		camera.camBopInterval = 4
		camera.centered = true
		dying = false
		function self:onDeath()
			--Gamestate.push((boyfriend and boyfriend.gameOverState) or gameOvers.default)
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

		function calculateNoteYPos(strumtime)
			--[[ return CONSTANTS.WEEKS.PIXELS_PER_MS * (musicTime - strumtime) * speed * (settings.downscroll and -1 or 1) ]]
			if not isResetting then
				return CONSTANTS.WEEKS.PIXELS_PER_MS * (musicTime - strumtime) * speed * (settings.downscroll and -1 or 1)
			else
				return CONSTANTS.WEEKS.PIXELS_PER_MS * (resettingTime[1] - strumtime) * speed * (settings.downscroll and -1 or 1)
			end
		end

		self:preloadIcon((enemy and enemy.icon) and enemy.icon or "dad", "enemy")
		self:preloadIcon((boyfriend and boyfriend.icon) and boyfriend.icon or "boyfriend", "boyfriend")

		enemyIcon = healthIconPreloads.enemy
		boyfriendIcon = healthIconPreloads.boyfriend

		P1HealthColors = boyfriendIcon.mostCommonColour
		P2HealthColors = enemyIcon.mostCommonColour

		enemyIcon.sizeX = 1.5
		boyfriendIcon.sizeX = -1.5
		enemyIcon.sizeY = 1.5
		boyfriendIcon.sizeY = 1.5

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

		enemyIcon.y = healthBar.y
		boyfriendIcon.y = healthBar.y

		if wasntRestart then
			graphics:fadeInWipe(0.6)
		end

		isResetting = false
		if boyfriend then boyfriend.playerInputs = true end
	end,

	preloadIcon = function(self, path, name)
		name = name or path
		if not healthIconPreloads[name] then
			healthIconPreloads[name] = icon.newIcon(icon.imagePath(path), 1)
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
		if not CONSTANTS.OPTIONS.DO_SAVE_DATA then return end
		local diff = difficulty ~= "" and difficulty or "normal"
		if savedata[weekNum] then
			if savedata[weekNum][song] then
				if savedata[weekNum][song][diff] then
					local score2 = savedata[weekNum][song][diff].score or 0
					if score > score2 then
						savedata[weekNum][song][diff].score = score
						savedata[weekNum][song][diff].accuracy = ((math.floor(ratingPercent * 10000) / 100))
					end
				else
					savedata[weekNum][song][diff] = {
						score = score,
						accuracy = ((math.floor(ratingPercent * 10000) / 100))
					}
				end
			else
				savedata[weekNum][song] = {}
				savedata[weekNum][song][diff] = {
					score = score,
					accuracy = ((math.floor(ratingPercent * 10000) / 100))
				}
			end
		else
			savedata[weekNum] = {}
			savedata[weekNum][song] = {}
			savedata[weekNum][song][diff] = {
				score = score,
				accuracy = ((math.floor(ratingPercent * 10000) / 100))
			}
		end
	end,

	checkSongOver = function(self)
		--if not (countingDown or graphics.isFading()) and not (inst and inst:isPlaying()) and not paused and not inCutscene then
		-- use inst, if inst doesn't exist, use voices, else dont use anything
		if not (countingDown or graphics.isFading()) and not ((inst and inst:isPlaying()) or (voicesBF and voicesBF:isPlaying())) and not paused and not inCutscene and not isResetting then
			allStates.sickCounter = allStates.sickCounter + sickCounter
			allStates.goodCounter = allStates.goodCounter + goodCounter
			allStates.badCounter = allStates.badCounter + badCounter
			allStates.shitCounter = allStates.shitCounter + shitCounter
			allStates.missCounter = allStates.missCounter + misses
			if maxCombo > allStates.maxCombo then allStates.maxCombo = maxCombo end
			allStates.score = allStates.score + score

			if storyMode and song < #weekMeta[weekNum][2] then
				self:saveData()
				song = song + 1

				curWeekData:load()
			else
				self:saveData()

				status.setLoading(true)

				graphics:fadeOutWipe(
					0.7,
					function()
						if not quitPressed then
							Gamestate.switch(resultsScreen, {
								diff = string.lower(CURDIFF or "normal"),
								song = not storyMode and SONGNAME or weekDesc[weekNum],
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
		end
	end,

	initUI = function(self)
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
			else
				self:setNoteSprites( -- the pixel sprites
					love.filesystem.load("sprites/pixel/receptor.lua"),
					love.filesystem.load("sprites/pixel/left-arrow.lua"),
					love.filesystem.load("sprites/pixel/down-arrow.lua"),
					love.filesystem.load("sprites/pixel/up-arrow.lua"),
					love.filesystem.load("sprites/pixel/right-arrow.lua")
				)
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
		local chart = getFilePath(chartPath)
		local metadata = getFilePath(metadataPath)
		if importMods.inMod then
			importMods.setupScripts()
		end
		self.overrideHealthbarText = importMods.uiHealthbarTextMod or nil
		self.overrideDrawHealthbar = importMods.uiHealthbarMod or nil

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
		Conductor.mapBPMChanges(metadata)
		metadata.playData = metadata.playData or {}
		metadata.playData.characters = metadata.playData.characters or {}
		metadata.playData.characters.opponent = metadata.playData.characters.opponent or "dad"
		metadata.playData.characters.player = metadata.playData.characters.player or "bf"
		metadata.playData.characters.girlfriend = metadata.playData.characters.girlfriend or "gf"
		boyfriend = Character.getCharacter(metadata.playData.characters.player)
		enemy = Character.getCharacter(metadata.playData.characters.opponent)
		girlfriend = Character.getCharacter(metadata.playData.characters.girlfriend)

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

			["mom-car"] = "mom"
		}
		if voiceConversions[metadata.playData.characters.player] then
			if not love.filesystem.getInfo(voicesBFPath) then
				voicesBFPath = "songs/" .. name .. "/Voices-" .. voiceConversions[metadata.playData.characters.player] .. songExt .. ".ogg"
			end
			if not love.filesystem.getInfo(voicesEnemyPath) then
				voicesEnemyPath = "songs/" .. name .. "/Voices-" .. voiceConversions[metadata.playData.characters.opponent] .. songExt .. ".ogg"
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
		girlfriend.zIndex = 9

		boyfriend.characterType = CHARACTER_TYPE.BF
		enemy.characterType = CHARACTER_TYPE.DAD
		girlfriend.characterType = CHARACTER_TYPE.GF

		boyfriend.flipX = not boyfriend._data.flipX
		enemy.flipX = enemy._data.flipX
		print(enemy.flipX)
		girlfriend.flipX = girlfriend._data.flipX

		boyfriend:dance()
		enemy:dance()
		girlfriend:dance()

		self.stage = Stage.getStage(metadata.playData.stage or "stage")
		self.stage:build()
		self.stage:call("postCreate")
		if boyfriend.call then boyfriend:call("postCreate") end
		if enemy.call then enemy:call("postCreate") end
		if girlfriend.call then girlfriend:call("postCreate") end
		camera.zoom = self.stage.cameraZoom or 1.0
		camera.defaultZoom = camera.zoom

		self:add(boyfriend)
		self:add(enemy)
		self:add(girlfriend)
		self:sort()

		boyfriend:updateHitbox()
		boyfriend.x = boyfriend.x - boyfriend.width / 2
		boyfriend.y = boyfriend.y - boyfriend.height

		enemy:updateHitbox()
		enemy.x = enemy.x - enemy.width / 2
		enemy.y = enemy.y - enemy.height

		girlfriend:updateHitbox()
		girlfriend.x = girlfriend.x - girlfriend.width / 2 - 150
		girlfriend.y = girlfriend.y - girlfriend.height

		local bfpoint = boyfriend:getCameraPoint()

		camera.x = bfpoint.x
		camera.y = bfpoint.y
		camera.defaultX = bfpoint.x
		camera.defaultY = bfpoint.y
		camera.targetX = bfpoint.x
		camera.targetY = bfpoint.y
		CAM_LERP_POINT.x = bfpoint.x
		CAM_LERP_POINT.y = bfpoint.y

		SONGNAME = metadata.songName
		CURDIFF = difficulty
		ARTIST = metadata.artist

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
		if chartData.scrollSpeed[difficulty] then
			_speed = chartData.scrollSpeed[difficulty]
		elseif chartData.scrollSpeed["default"] then
			_speed = chartData.scrollSpeed["default"]
		end

		if settings.customScrollSpeed == 1 then
			speed = _speed
		else
			speed = settings.customScrollSpeed
		end

		if not speed then speed = _speed end

		speed = speed * 1.06

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
			if dataStuff.r then r = {decToRGB(dataStuff.r)} end
			if dataStuff.g then g = {decToRGB(dataStuff.g)} end
			if dataStuff.b then b = {decToRGB(dataStuff.b)} end
			noteObject.hitNote = not dataStuff.ignoreNote

			noteObject.healthGainMult = dataStuff.healthMult or 1
			noteObject.healthLossMult = dataStuff.healthLossMult or 1

			noteObject.causesMiss = dataStuff.causesMiss or false

			table.insert(notesTable[data], noteObject)
			if holdTime > 0 then
				for k = 71 / speed, holdTime, 71 / speed do
					local holdNote = noteSprites[data]()
					holdNote.col = data
					holdNote.y = CONSTANTS.WEEKS.STRUM_Y + (time + k) * 0.6 * speed
					holdNote.ver = noteData.k or "normal"
					holdNote.time = time + k
					holdNote:animate("hold")

					holdNote.x = arrowsTable[data].x
					holdNote.healthGainMult = noteObject.healthGainMult
					holdNote.healthLossMult = noteObject.healthLossMult
					holdNote.causesMiss = noteObject.causesMiss
					holdNote.hitNote = noteObject.hitNote
					holdNote.batchReference = NOTES_BATCH
					table.insert(notesTable[data], holdNote)
				end

				notesTable[data][#notesTable[data]]:animate("end")
				notesTable[data][#notesTable[data]].sizeY = settings.downscroll and -1 or 1
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

	setupCountdown = function(self, countNumVal, func)
		countNumVal = countNumVal or 4

		if not storyMode and countNumVal == 4 then
			for i = 1, 4 do
				boyfriendArrows[i].alpha = 0
				boyfriendArrows[i].y = boyfriendArrows[i].y - 50
				enemyArrows[i].alpha = 0
				enemyArrows[i].y = enemyArrows[i].y - 50

				Timer.after(0.5 + (0.2 * i), function()
					local targetY = CONSTANTS.WEEKS.STRUM_Y * (settings.downscroll and -1 or 1)

					Timer.tween(1, boyfriendArrows[i], {
						alpha = boyfriendArrows[i].finishedAlpha,
						y = targetY
					}, "out-circ", function()
						boyfriendArrows[i].alpha = boyfriendArrows[i].finishedAlpha
					end)

					Timer.tween(1, enemyArrows[i], {
						alpha = enemyArrows[i].finishedAlpha,
						y = targetY
					}, "out-circ", function()
						enemyArrows[i].alpha = enemyArrows[i].finishedAlpha
					end)
				end)
			end
		end

		lastReportedPlaytime = 0
		if countNumVal == 4 then
			musicTime = ((60 * 4) / bpm) * -1000 -- countdown is 4 beats long
		end
		musicThres = 0
		countingDown = true

		audio.playSound(sounds.countdown[CONSTANTS.WEEKS.COUNTDOWN_SOUNDS[countNumVal]])

		if countNumVal == 4 then
			countdownFade[1] = 0
			Timer.after((60 / bpm), function()
				self:setupCountdown(countNumVal - 1, func)
			end)
		else
			countdownFade[1] = 1
			countdown:animate(CONSTANTS.WEEKS.COUNTDOWN_ANIMS[countNumVal])

			Timer.tween((60 / bpm), countdownFade, {0}, "linear", function()
				if countNumVal ~= 1 then
					self:setupCountdown(countNumVal - 1, func)
				else
					countingDown = false
					previousFrameTime = love.timer.getTime() * 1000
					musicTime = 0
					beatHandler.reset(0)

					if inst then inst:play() end
					if voicesBF then voicesBF:play() end
					if voicesEnemy then voicesEnemy:play() end

					beatHandler.setBeat(0)
					if func then func() end
				end
			end)
		end
	end,

	update = function(self, dt)
		if input:pressed("pause") and not countingDown and not inCutscene and not paused then
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
					if inst then inst:play() end
					if voicesBF then voicesBF:play() end
					if voicesEnemy then voicesEnemy:play() end
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

								musicTime = 0
								beatHandler.reset(0)
								previousFrameTime = love.timer.getTime() * 1000
								beatHandler.setBeat(0)

								Gamestate.current():load(true)
							end
						)
					end

				elseif pauseMenuSelection == 3 then
					paused = false
					if inst then inst:stop() end
					if voicesBF then voicesBF:stop() end
					if voicesEnemy then voicesEnemy:stop() end
					quitPressed = true
				end
			end
			return
		end
		if inCutscene then return end
		beatHandler.update(dt)
		Conductor.update(dt)

		-- nps table
		for i, note in ipairs(nps) do
			if note - love.timer.getTime() <= -1 then
				table.remove(nps, i)
			end
		end

		oldMusicThres = musicThres
		if countingDown or love.system.getOS() == "Web" then -- Source:tell() can't be trusted on love.js!
			musicTime = musicTime + 1000 * dt
		else
			if not graphics.isFading() then
				local time = love.timer.getTime()
				local seconds = voicesBF and voicesBF:tell("seconds") or inst:tell("seconds")

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
							local time = (Conductor.getStepLengthMs() * duration) / 1000
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
					if type(event.value) == "number" then
						camera.zoom = event.value
						uiCam.zoom = event.value
					elseif type(event.value) == "table" then
						event.value.mode = event.value.mode or "stage"
						local taget = 1
						if event.value.mode == "stage" then
							target = tonumber(event.value.zoom) * self.stage.cameraZoom
						else
							target = tonumber(event.value.zoom) * camera.defaultZoom
						end
						print(target)

						if event.value.ease ~= "INSTANT" then
							local time = Conductor.getStepLengthMs() * (tonumber(event.value.duration) or 4) / 1000
							if bumpTween then 
								Timer.cancel(bumpTween)
							end
							bumpTween = Timer.tween(
								time,
								camera,
								{defaultZoom = target },
								CONSTANTS.WEEKS.EASING_TYPES[(event.value.ease or "CLASSIC") .. (event.value.easeDir or "")]
							)
						else
							if bumpTween then 
								Timer.cancel(bumpTween)
							end
							camera.defaultZoom = target
						end
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
						}
						boyfriendIcon = healthIconPreloads[event.value.id] or boyfriendIcon
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
						}
						enemyIcon = healthIconPreloads[event.value.id] or enemyIcon
						for k, v in pairs(prevData) do
							enemyIcon[k] = v
						end
					end
				elseif event.name == "SetCameraBop" then
					if type(event.value) == "number" then
						camera.camBopIntensity = event.value
					elseif type(event.value) == "table" then
						camera.camBopIntensity = event.value.intensity or 1
						camera.camBopInterval = event.value.rate or 4
					end
				else
					Gamestate.onEvent(event)
					self.stage:call("onEvent", event)
				end

				table.remove(songEvents, i)
				break
			end
		end

		for i, event in ipairs(modEvents) do
			if event.time <= absMusicTime then
				Gamestate.onEvent(event)
				self.stage:call("onEvent", event)

				table.remove(modEvents, i)
				break
			end
		end

		if (Conductor.onBeat and Conductor.curBeat % camera.camBopInterval == 0 and camera.zooming and camera.zoom < 1.35 and not camera.locked) then 
			camera.zoom = camera.zoom + 0.015 * camera.camBopIntensity
			uiCam.zoom = uiCam.zoom + 0.03 * camera.camBopIntensity
		end

		if camera.zooming and not camera.locked then
			camera.zoom = util.lerp(camera.defaultZoom, camera.zoom, util.clamp(1 - (dt * 3.125), 0, 1))
			uiCam.zoom = util.lerp(1, uiCam.zoom, util.clamp(1 - (dt * 3.125), 0, 1))
		end

		self.stage:call("onUpdate", dt)
		if Conductor.onStep then
			self.stage:call("onStepHit", Conductor.curStep)
		end
		if Conductor.onBeat then
			self.stage:call("onBeatHit", Conductor.curBeat)
		end
		for _, obj in ipairs(self.objects) do
			if obj.update then
				obj:update(dt)
				if obj.call then
					obj:call("onUpdate", dt)
				end
			end

			if Conductor.onStep and obj.onStepHit then
				obj:onStepHit(Conductor.curStep)
				if obj.call then
					obj:call("onStepHit", Conductor.curStep)
				end
			end

			if Conductor.onBeat and obj.onBeatHit then
				obj:onBeatHit(Conductor.curBeat)
				if obj.call then
					obj:call("onBeatHit", Conductor.curBeat)
				end
			end
		end

		for i = 1, #inHolds do
			if inHolds[i] then
				score = score + CONSTANTS.WEEKS.SCORE_HOLD_BONUS_PER_SECOND * dt
			end
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

	setAltAnims = function(self, useAlt)
		useAltAnims = useAlt
	end,

	updateUI = function(self, dt)
		if inCutscene then return end
		if paused then return end

		if IS_CLASSIC_MOVEMENT then
			local adjustedLerp  = 1 - math.pow(1.0 - 0.04, dt * 60)
			camera.x = camera.x + (CAM_LERP_POINT.x - camera.x) * adjustedLerp
			camera.y = camera.y + (CAM_LERP_POINT.y - camera.y) * adjustedLerp
		end

		NoteSplash:update(dt)
		HoldCover:update(dt)
		for i = 1, 4 do
			for _, note in ipairs(enemyNotes[i]) do
				note.y = enemyArrows[i].y - calculateNoteYPos(note.time)
			end

			for _, note in ipairs(boyfriendNotes[i]) do
				note.y = boyfriendArrows[i].y - calculateNoteYPos(note.time)
			end
		end

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

			if #enemyNote > 0 then
				for j = 1, #enemyNote do
					local ableTohit = true
					if enemyNote[j].hitNote ~= nil then
						ableTohit = enemyNote[j].hitNote
					end
					if isResetting then
						ableTohit = false
					end

					if (enemyNote[j].time - musicTime <= 0) and ableTohit and not enemyNote[j].causesMiss then
						enemyArrow:animate(CONSTANTS.WEEKS.NOTE_LIST[i] .. " confirm", false)
						useAltAnims = false
	
						local didEvent = false
						for _, obj in ipairs(self.objects) do
							if obj.characterType == CHARACTER_TYPE.DAD then
								local whohit = obj
								-- default to true if nothing is returned
								local continue
								
								if not didEvent then
									continue = (Gamestate.onNoteHit(enemy, enemyNote[j].ver, "EnemyHit", i) == nil or false) and true or false
									if enemy.call then
										enemy:call("onNoteHit", {noteType = enemyNote[j].ver, direction = i})
									end
									didEvent = true
								else
									continue = true
								end
			
								if continue then
									if enemyNote[j]:getAnimName() == "hold" or enemyNote[j]:getAnimName() == "end" then
										if enemyNote[j]:getAnimName() == "hold" then
											HoldCover:show(i, 2, enemyNote[j].x, enemyNote[j].y)
										else
											HoldCover:hide(i, 2)
										end
										if useAltAnims then
											if whohit then 
												whohit:play(curAnim .. "-alt", (_psychmod and true or false), false)
												if whohit.call then
													whohit:call("onNoteHit", {noteType = enemyNote[j].ver, direction = i, anim = curAnim .. "-alt"})
												end
											end
										else
											if whohit then 
												whohit:play(curAnim, (_psychmod and true or false), false)
												if whohit.call then
													whohit:call("onNoteHit", {noteType = enemyNote[j].ver, direction = i, anim = curAnim})
												end
											end
										end
										whohit.holdTimer = 0
									else
										NoteSplash:new(
											{
												anim = CONSTANTS.WEEKS.NOTE_LIST[i] .. tostring(love.math.random(1, 2)),
												posX = enemyArrow.x,
												posY = enemyArrow.y,
											},
											i
										)
										if useAltAnims then
											if whohit then 
												whohit:play(curAnim .. "-alt", true, false)
												if whohit.call then
													whohit:call("onNoteHit", {noteType = enemyNote[j].ver, direction = i, anim = curAnim .. "-alt"})
												end
											end
										else
											if whohit then 
												whohit:play(curAnim, true, false)
												if whohit.call then
													whohit:call("onNoteHit", {noteType = enemyNote[j].ver, direction = i, anim = curAnim})
												end
											end
										end

										whohit.holdTimer = 0
									end
								end
			
								if whohit then whohit.lastHit = musicTime end
							end
						end
	
						table.remove(enemyNote, 1)

						break
					elseif not ableTohit and enemyNote[j].time - musicTime <= 0 and not enemyNote[j].didHit then
						enemyNote[j].didHit = true
						Gamestate.onNoteHit(enemy, enemyNote[j].ver, "EnemyHit", i)
						if enemy.call then
							enemy:call("onNoteHit", {noteType = enemyNote[j].ver, direction = i})
						end

						break
					end
				end
			end

			if #gfNote > 0 then
				if gfNote[1].time - musicTime <= 0 then
					for _, obj in ipairs(self.objects) do
						if obj.characterType == CHARACTER_TYPE.GF then
							obj:play(curAnim, true, false)
							obj.holdTimer = 0
							if obj.call then
								obj:call("onNoteHit", {noteType = gfNote[1].ver, direction = i})
							end
						end
					end

					table.remove(gfNote, 1)
				end
			end

			if #boyfriendNote > 0 then
				if isResetting then
					goto continue
				end
				if (boyfriendNote[1].time - musicTime <= -200) and not boyfriendNote[1].causesMiss then
					if voicesBF then 
						voicesBF:setVolume(0)
					end
					local continue
					if boyfriendNote[1]:getAnimName() ~= "hold" and boyfriendNote[1]:getAnimName() ~= "end" then 
						health = health - CONSTANTS.WEEKS.HEALTH.MISS_PENALTY * healthLossMult * boyfriendNote[1].healthLossMult
						misses = misses + 1
					else
						health = health - (CONSTANTS.WEEKS.HEALTH.MISS_PENALTY * 0.1) * healthLossMult * boyfriendNote[1].healthLossMult
						continue = Gamestate.onNoteMiss(boyfriend, boyfriendNote[1].ver, "BoyfriendMiss", i)
					end

					table.remove(boyfriendNote, 1)

					if not continue then
						for _, obj in ipairs(self.objects) do
							if obj.characterType == CHARACTER_TYPE.BF then
								obj:play(curAnim .. " miss", true, false)
								if obj.call then
									obj:call("onNoteMiss", curAnim .. " miss")
								end
							end
						end
					end
					
					if combo >= 5 then
						for _, obj in ipairs(self.objects) do
							if obj.characterType == CHARACTER_TYPE.GF then
								obj:play("sad", true, false)
								obj.holdTimer = 0
							end
						end
					end

					combo = 0
				end

				::continue::
			end

			if input:pressed(curInput) and not isResetting then
				local success = false
				local didHitNote = false

				if settings.ghostTapping then
					success = true
					didHitNote = false
				end

				boyfriendArrow:animate(CONSTANTS.WEEKS.NOTE_LIST[i] .. " press", false)

				if #boyfriendNote > 0 then
					for j = 1, #boyfriendNote do
						if boyfriendNote[j] and boyfriendNote[j]:getAnimName() == "on" then
							if (boyfriendNote[j].time - musicTime <= CONSTANTS.WEEKS.JUDGE_THRES[settings.judgePreset].MISS_THRES and ((boyfriendNote[j].causesMiss and boyfriendNote[j].time - musicTime > 0) or true)) and not boyfriendNote[j].didHit then
								local notePos
								local ratingAnim

								notePos = math.abs(boyfriendNote[j].time - musicTime)

								if voicesBF then voicesBF:setVolume(1) end

								if boyfriend then boyfriend.lastHit = musicTime end

								ratingAnim = self:judgeNote(notePos)
								table.insert(nps, love.timer.getTime())
								maxNPS = math.max(maxNPS, #nps)
								score = score + self:scoreNote(notePos)
								if ratingAnim == "sick" then
									sickCounter = sickCounter + 1
								elseif ratingAnim == "good" then
									goodCounter = goodCounter + 1
								elseif ratingAnim == "bad" then
									badCounter = badCounter + 1
								elseif ratingAnim == "shit" then
									shitCounter = shitCounter + 1
								end

								if settings.scoringType == "Psych" then
									ratingTextScale = 1.075
								end

								if ratingAnim == "sick" then
									NoteSplash:new(
										{
											anim = CONSTANTS.WEEKS.NOTE_LIST[i] .. tostring(love.math.random(1, 2)),
											posX = boyfriendArrow.x,
											posY = boyfriendArrow.y,
										},
										i
									)
								end

								combo = combo + 1
								if combo > maxCombo then maxCombo = combo end
								noteCounter = noteCounter + 1

								popupScore:create(ratingAnim, combo)

								for i = 1, 5 do
									if ratingTimers[i] then Timer.cancel(ratingTimers[i]) end
								end

								if not settings.ghostTapping or success then
									boyfriendArrow:animate(CONSTANTS.WEEKS.NOTE_LIST[i] .. " confirm", false)

									if boyfriendNote[j]:getAnimName() ~= "hold" and boyfriendNote[j]:getAnimName() ~= "end" then
										health = health + (CONSTANTS.WEEKS.HEALTH.BONUS[string.upper(ratingAnim)] or 0) * healthGainMult * boyfriendNote[j].healthGainMult
									else
										health = health + 0.0125 * healthGainMult * boyfriendNote[j].healthGainMult
									end

									local continue = Gamestate.onNoteHit(boyfriend, boyfriendNote[j].ver, ratingAnim, i) == nil and true or false 

									if continue then
										if not boyfriendNote[j].causesMiss then
											for _, obj in ipairs(self.objects) do
												if obj.characterType == CHARACTER_TYPE.BF then
													obj:play(curAnim, true, false)
													if obj.call then
														obj:call("onNoteHit", {noteType = boyfriendNote[j].ver, direction = i, anim = curAnim})
													end
												end
											end
										else
											audio.playSound(sounds.miss[love.math.random(3)])
											for _, obj in ipairs(self.objects) do
												if obj.characterType == CHARACTER_TYPE.BF then
													obj:play(curAnim .. " miss", true, false)
													if obj.call then
														obj:call("onNoteMiss", curAnim .. " miss")
													end
												end
											end
										end
									end

									success = true
									didHitNote = true
								end

								table.remove(boyfriendNote, j)

								self:calculateRating()
							else
								break
							end
						end
					end

					if not success then
						audio.playSound(sounds.miss[love.math.random(3)])

						for _, obj in ipairs(self.objects) do
							if obj.characterType == CHARACTER_TYPE.BF then
								obj:play(curAnim .. " miss", true, false)
								if obj.call then
									obj:call("onNoteMiss", curAnim .. " miss")
								end
							end
						end

						if didHitNote then
							score = math.max(0, score - 100) -- if note was "missed" but hit, remove 100 points
						else
							score = math.max(0, score - 10)  -- If ghost tapped, remove 10 points
						end
						health = health - (CONSTANTS.WEEKS.HEALTH.MISS_PENALTY or 0.2) * (healthLossMult or 1) * (boyfriendNote[1].healthLossMult or 1)
						misses = misses + 1
					end
				end
			end

			if #boyfriendNote > 0 and input:down(curInput) and ((boyfriendNote[1].time - musicTime <= 0))
				and (boyfriendNote[1]:getAnimName() == "hold" or boyfriendNote[1]:getAnimName() == "end") then

				if boyfriendNote[1]:getAnimName() == "hold" then
					HoldCover:show(i, 1, boyfriendNote[1].x, boyfriendNote[1].y)
					inHolds[i] = true
				else
					HoldCover:hide(i, 1)
					inHolds[i] = false
				end
				if voicesBF then voicesBF:setVolume(1) end

				boyfriendArrow:animate(CONSTANTS.WEEKS.NOTE_LIST[i] .. " confirm", false)
				health = health + 0.0125 * healthGainMult * boyfriendNote[1].healthGainMult

				if boyfriend then boyfriend.lastHit = musicTime end

				table.remove(boyfriendNote, 1)
			end

			if not input:down(curInput) and not HoldCover:getVisibility(i, 1) then
				HoldCover:hide(i, 1)
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

		if Conductor.onBeat then
			enemyIcon.sizeX, enemyIcon.sizeY = 1.75, 1.75
			boyfriendIcon.sizeX, boyfriendIcon.sizeY = -1.75, 1.75
		end

		enemyIcon.sizeX, enemyIcon.sizeY = util.coolLerp(enemyIcon.sizeX, 1.5, 0.1), enemyIcon.sizeX
		boyfriendIcon.sizeX, boyfriendIcon.sizeY = util.coolLerp(boyfriendIcon.sizeX, -1.5, 0.1), -boyfriendIcon.sizeX
	end,

	add = function(self, object, sort)
		sort = sort == nil and false or sort
		table.insert(self.objects, object)
		if not object.characterType then
			self.stage:call("addProp", object, object.name)
		else
			self.stage:call("addCharacter", object, object.name)
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

	renderStage = function(self)
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
				love.graphics.setFont(font)
			love.graphics.pop()
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
							if enemyNotes[i][j].y+enemyNotes[i][j].offsetY2 <= 600 and enemyNotes[i][j].y+enemyNotes[i][j].offsetY2 >= -600 then
								local animName = enemyNotes[i][j]:getAnimName()
								if settings.middlescroll then
									graphics.setColor(1, 1, 1, 0.8 * enemyNotes[i][j].alpha)
								else
									graphics.setColor(1, 1, 1, 1 * enemyNotes[i][j].alpha)
								end

								if pixel and not settings.pixelPerfect then
									enemyNotes[i][j]:udraw(8, 8)
								else
									enemyNotes[i][j]:draw()
								end
								graphics.setColor(1, 1, 1)
							end
						end
					love.graphics.pop()
					love.graphics.push()
						for j = #boyfriendNotes[i], 1, -1 do
							if boyfriendNotes[i][j].y+boyfriendNotes[i][j].offsetY2 <= 600 and boyfriendNotes[i][j].y+boyfriendNotes[i][j].offsetY2 >= -600 then
								local animName = boyfriendNotes[i][j]:getAnimName()
								if not settings.downscroll then
									graphics.setColor(1, 1, 1, math.min(1, (500 + (boyfriendNotes[i][j].y+boyfriendNotes[i][j].offsetY2)) / 75) * boyfriendNotes[i][j].alpha)
								else
									graphics.setColor(1, 1, 1, math.min(1, (500 - (boyfriendNotes[i][j].y+boyfriendNotes[i][j].offsetY2)) / 75) * boyfriendNotes[i][j].alpha)
								end

								if pixel and not settings.pixelPerfect then
									boyfriendNotes[i][j]:udraw(8, 8)
								else
									boyfriendNotes[i][j]:draw()
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
			x = 250+offsetX
			y = 400+offsetY
			format = "left"
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
			returnStr = "Score: " .. commaFormat(score)
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
			graphics.setColor(P2HealthColors[1], P2HealthColors[2], P2HealthColors[3], hudFade[1])
			love.graphics.rectangle("fill", healthBar.x, healthBar.y, healthBar.width, healthBar.height)
			graphics.setColor(P1HealthColors[1], P1HealthColors[2], P1HealthColors[3], hudFade[1])
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

	leave = function(self)
		if inst then inst:stop(); inst = nil end
		if voicesBF then voicesBF:stop(); voicesBF = nil end
		if voicesEnemy then voicesEnemy:stop(); voicesEnemy = nil end

		playMenuMusic = true

		camera:removePoint("boyfriend")
		camera:removePoint("enemy")
		camera:removePoint("girlfriend")

		Timer.clear()

		fakeBoyfriend = nil
		importMods.removeScripts()
		importMods.inMod = false

		noteSprites = nil

		camera.defaultZoom = 1

		healthIconPreloads = {}
		inHolds = {false, false, false, false}
	end
}
