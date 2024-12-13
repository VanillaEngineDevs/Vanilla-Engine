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
local DefaultTimeSignatureNum = 4
local timeSignatureNum = DefaultTimeSignatureNum

local camTween, bumpTween

local function getBeatLengthsMS(bpm)
	return 60 / bpm * 1000
end

local function getStepLengthsMS(bpm)
	return getBeatLengthsMS(bpm) * (timeSignatureNum/4)
end

local ratingTimers = {}

local useAltAnims

healthLerp = 1

local dying = false

noteSprites = nil

local allStates = {
	sickCounter = 0,
	goodCounter = 0,
	badCounter = 0,
	shitCounter = 0,
	missCounter = 0,
	maxCombo = 0,
	score = 0
}

modEvents = {}

local sickCounter, goodCounter, badCounter, shitCounter, missCounter, maxCombo, score = 0, 0, 0, 0, 0, 0, 0

return {
	enter = function(self, option)
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

		arrowAngles = {math.rad(180), math.rad(90), math.rad(270), math.rad(0)}
		if settings.downscroll then
			-- ezezezezezezezezezezezezez workaround lol
			arrowAngles = {math.rad(180), math.rad(270), math.rad(90), math.rad(0)}
		end

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
				death = love.audio.newSource("sounds/death.ogg", "static"),
				breakfast = love.audio.newSource("music/breakfast.ogg", "stream")
			}

			images = {
				notes = love.graphics.newImage(graphics.imagePath("NOTE_assets")),
				numbers = love.graphics.newImage(graphics.imagePath("numbers")),
			}

			sprites = {
				numbers = love.filesystem.load("sprites/numbers.lua"),
			}

			rating = love.filesystem.load("sprites/rating.lua")()

			rating.sizeX, rating.sizeY = 0.75, 0.75

			girlfriend = BaseCharacter("sprites/characters/girlfriend.lua")
			boyfriend = BaseCharacter("sprites/characters/boyfriend.lua")
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

			rating = love.filesystem.load("sprites/pixel/rating.lua")()

			girlfriend = BaseCharacter("sprites/characters/girlfriend-pixel.lua")
			boyfriend = BaseCharacter("sprites/characters/boyfriend-pixel.lua")
		end

		numbers = {}
		for i = 1, 3 do
			numbers[i] = sprites.numbers()

			if option ~= "pixel" then
				numbers[i].sizeX, numbers[i].sizeY = 0.5, 0.5
			end
		end

		if settings.downscroll then
			downscrollOffset = -750
		else
			downscrollOffset = 0
		end

		countdownFade = {}
		countdown = love.filesystem.load("sprites/countdown.lua")()
	end,

	load = function(self)
		camera.camBopIntensity = 1
		camera.camBopInterval = 4
		dying = false
		function self:onDeath()
			Gamestate.push(gameOver)
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

		if boyfriend then
			camera.x, camera.y = -boyfriend.x + 100, -boyfriend.y + 75
		else
			camera.x, camera.y = 0, 0
		end

		curWeekData = weekData[weekNum]

		rating.x = 20
		if not pixel then
			for i = 1, 3 do
				numbers[i].x = -100 + 50 * i
			end
		else
			for i = 1, 3 do
				numbers[i].x = -100 + 58 * i
			end
		end

		ratingVisibility = {0}
		combo = 0

		if enemy then enemy:animate("idle") end
		if boyfriend then boyfriend:animate("idle") end

		if not camera.points["boyfriend"] then
			if boyfriend then 
				camera:addPoint("boyfriend", -boyfriend.x + 100, -boyfriend.y + 75) 
			else
				camera:addPoint("boyfriend", 0, 0)
			end
		end
		if not camera.points["enemy"] then 
			if enemy then
				camera:addPoint("enemy", -enemy.x - 100, -enemy.y + 75) 
			else
				camera:addPoint("enemy", 0, 0)
			end
		end
		if not camera.points["girlfriend"] then
			if girlfriend then
				camera:addPoint("girlfriend", -girlfriend.x - 100, -girlfriend.y + 75)
			else
				camera:addPoint("girlfriend", 0, 0)
			end
		end

		-- Function so people can override it if they want
		-- Do some cool note effects or something!
		function updateNotePos()
		for i = 1, 4 do
			for j, note in ipairs(boyfriendNotes[i]) do
				if note.time - musicTime >= 15000 then break end
				local strumlineY = boyfriendArrows[i].y
				note.y = strumlineY - CONSTANTS.WEEKS.PIXELS_PER_MS * (musicTime - note.time) * speed--[[ (strumlineY - (musicTime - note.time) * (0.45 * math.roundDecimal(speed,2))) ]]
			end

			for _, note in ipairs(enemyNotes[i]) do
				if note.time - musicTime >= 15000 then break end
				local strumlineY = enemyArrows[i].y
				note.y = strumlineY - CONSTANTS.WEEKS.PIXELS_PER_MS * (musicTime - note.time) * speed--[[ (strumlineY - (musicTime - note.time) * (0.45 * math.roundDecimal(speed,2))) ]]
			end
		end
end

		enemyIcon = icon.newIcon(icon.imagePath((enemy and enemy.icon) and enemy.icon) or "dad", (enemy and enemy.optionsTable) and (enemy.optionsTable.scale or 1) or 1)
		boyfriendIcon = icon.newIcon(icon.imagePath((boyfriend and boyfriend.icon) and boyfriend.icon) or "bf", (boyfriend and boyfriend.optionsTable) and (boyfriend.optionsTable.scale or 1) or 1)

		enemyIcon.y = 350 + downscrollOffset
		boyfriendIcon.y = 350 + downscrollOffset
		enemyIcon.sizeX = 1.5
		boyfriendIcon.sizeX = -1.5
		enemyIcon.sizeY = 1.5
		boyfriendIcon.sizeY = 1.5

		graphics:fadeInWipe(0.6)
	end,

	calculateRating = function(self)
		ratingPercent = score / ((noteCounter + misses) * 500)
		if ratingPercent == nil or ratingPercent < 0 then 
			ratingPercent = 0
		elseif ratingPercent > 1 then
			ratingPercent = 1
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

		--print("Saved data for week " .. weekNum-1 .. ", song " .. song .. ", difficulty " .. diff)
	end,

	checkSongOver = function(self)
		--if not (countingDown or graphics.isFading()) and not (inst and inst:isPlaying()) and not paused and not inCutscene then
		-- use inst, if inst doesn't exist, use voices, else dont use anything
		if not (countingDown or graphics.isFading()) and not ((inst and inst:isPlaying()) or (voicesBF and voicesBF:isPlaying())) and not paused and not inCutscene then
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
			if not pixel then
				enemyArrows[i].shader = CONSTANTS.WEEKS.LANE_SHADERS[i]
				boyfriendArrows[i].shader = CONSTANTS.WEEKS.LANE_SHADERS[i]

				enemyArrows[i].shaderEnabled = false
				boyfriendArrows[i].shaderEnabled = false

				local r = CONSTANTS.ARROW_COLORS[i][1]
				local g = CONSTANTS.ARROW_COLORS[i][2]
				local b = CONSTANTS.ARROW_COLORS[i][3]

				enemyArrows[i].updateShaderAlpha = true
				boyfriendArrows[i].updateShaderAlpha = true

				enemyArrows[i].shader:send("r", r)
				enemyArrows[i].shader:send("g", g)
				enemyArrows[i].shader:send("b", b)
				boyfriendArrows[i].shader:send("r", r)
				boyfriendArrows[i].shader:send("g", g)
				boyfriendArrows[i].shader:send("b", b)
			end
			if settings.middleScroll then 
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

			enemyArrows[i].finishedAlpha = 1
			boyfriendArrows[i].finishedAlpha = 1

			boyfriendArrows[i]:animate(CONSTANTS.WEEKS.NOTE_LIST[i])
			enemyArrows[i]:animate(CONSTANTS.WEEKS.NOTE_LIST[i])

			if settings.downscroll then 
				enemyArrows[i].sizeY = -1
				boyfriendArrows[i].sizeY = -1
			end

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

	generateNotes = function(self, chart, metadata, difficulty)
		local eventBpm
		local chart = getFilePath(chart)
		local metadata = getFilePath(metadata)
		if importMods.inMod then
			importMods.setupScripts()
		end
		self.overrideHealthbarText = importMods.uiHealthbarTextMod or nil
		self.overrideDrawHealthbar = importMods.uiHealthbarMod or nil
		local chartData = json.decode(love.filesystem.read(chart))
		chart = chartData.notes[difficulty]

		local metadata = json.decode(love.filesystem.read(metadata))
		Conductor.mapBPMChanges(metadata)

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
			noteObject:animate("on")

			if settings.downscroll then noteObject.sizeY = -1 end

			local enemyNote = noteData.d > 3
			local notesTable = enemyNote and enemyNotes or boyfriendNotes
			local arrowsTable = enemyNote and enemyArrows or boyfriendArrows

			noteObject.x = arrowsTable[data].x
			noteObject.shader = CONSTANTS.WEEKS.LANE_SHADERS[data]
            local r, g, b = CONSTANTS.ARROW_COLORS[data][1], CONSTANTS.ARROW_COLORS[data][2], CONSTANTS.ARROW_COLORS[data][3]

            if dataStuff.r or dataStuff.g or dataStuff.b then
                noteObject.shader = love.graphics.newShader("shaders/RGBPallette.glsl")
            end

			if dataStuff.r then r = {decToRGB(dataStuff.r)} end
			if dataStuff.g then g = {decToRGB(dataStuff.g)} end
			if dataStuff.b then b = {decToRGB(dataStuff.b)} end
			noteObject.hitNote = not dataStuff.ignoreNote

			noteObject.healthGainMult = dataStuff.healthMult or 1
			noteObject.healthLossMult = dataStuff.healthLossMult or 1

			noteObject.causesMiss = dataStuff.causesMiss or false

			noteObject.shader:send("r", r)
			noteObject.shader:send("g", g)
			noteObject.shader:send("b", b)
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
					holdNote.shader = noteObject.shader
					holdNote.healthGainMult = noteObject.healthGainMult
					holdNote.healthLossMult = noteObject.healthLossMult
					holdNote.causesMiss = noteObject.causesMiss
					holdNote.hitNote = noteObject.hitNote
					table.insert(notesTable[data], holdNote)
				end

				notesTable[data][#notesTable[data]]:animate("end")
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
	end,

	generateGFNotes = function(self, chartG, diff)
		-- very bare-bones chart generation
		-- Does not handle sprites and all that, just note timings and type
		local chartG = json.decode(love.filesystem.read(chartG)).notes[diff]

		for _, noteData in ipairs(chartG) do
			local noteType = noteData.d % 4 + 1
			local noteTime = noteData.t

			table.insert(gfNotes[noteType], {time = noteTime})
		end
	end,

	-- Gross countdown script
	setupCountdown = function(self, countNumVal, func)
		local countNumVal = countNumVal or 4
		if not storyMode and countNumVal == 4 then
			-- strum spawning
			for i = 1, 4 do
				boyfriendArrows[i].alpha = 0
				boyfriendArrows[i].y = boyfriendArrows[i].y - 50
				enemyArrows[i].alpha = 0
				enemyArrows[i].y = enemyArrows[i].y - 50
				Timer.after(
					0.5 + (0.2 * i),
					function()
						Timer.tween(
							1,
							boyfriendArrows[i],
							{
								alpha = boyfriendArrows[i].finishedAlpha,
								y = CONSTANTS.WEEKS.STRUM_Y
							},
							"out-circ",
							function()
								-- Stop updating the shader because that can cause some performance issues
								boyfriendArrows[i].alpha = boyfriendArrows[i].finishedAlpha
								boyfriendArrows[i].updateShaderAlpha = false
							end
						)

						Timer.tween(
							1,
							enemyArrows[i],
							{
								alpha = enemyArrows[i].finishedAlpha,
								y = CONSTANTS.WEEKS.STRUM_Y
							},
							"out-circ",
							function()
								enemyArrows[i].alpha = enemyArrows[i].finishedAlpha
								enemyArrows[i].updateShaderAlpha = false
							end
						)
					end
				)
			end
		end
		lastReportedPlaytime = 0
		if countNumVal == 4 then
			musicTime = ((60*4) / bpm) * -1000 -- countdown is 4 beats long
		end
		musicThres = 0

		countingDown = true
		if countNumVal % 2 == 1 then
			if girlfriend then girlfriend:beat(countNumVal) end
			if boyfriend then boyfriend:beat(countNumVal) end
			if enemy then enemy:beat(countNumVal) end
		end
		if CONSTANTS.WEEKS.COUNTDOWN_SOUNDS[countNumVal] then audio.playSound(sounds.countdown[CONSTANTS.WEEKS.COUNTDOWN_SOUNDS[countNumVal]]) end
		if countNumVal == 4 then 
			countdownFade[1] = 0
			Timer.after(
				(60/bpm), -- one beat
				function()
					self:setupCountdown(countNumVal - 1, func)
				end
			)
		else
			countdownFade[1] = 1
			countdown:animate(CONSTANTS.WEEKS.COUNTDOWN_ANIMS[countNumVal])
			Timer.tween(
				(60/bpm), 
				countdownFade,
				{0},
				"linear",
				function()
					if countNumVal ~= 1 then self:setupCountdown(countNumVal - 1, func)
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
				end
			)
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
				love.audio.stop(sounds.breakfast) -- since theres only 3 options, we can make the sound stop without an else statement
				if pauseMenuSelection == 1 then
					if inst then inst:play() end
					if voicesBF then voicesBF:play() end
					if voicesEnemy then voicesEnemy:play() end
					paused = false 
				elseif pauseMenuSelection == 2 then
					pauseRestart = true
					dying = true
					self:onDeath()
				elseif pauseMenuSelection == 3 then
					paused = false
					if inst then inst:stop() end
					if voicesBF then voicesBF:stop() end
					if voicesEnemy then voicesEnemy:stop() end
					storyMode = false
					quitPressed = true
				end
			end
			return
		end
		if inCutscene then return end
		beatHandler.update(dt)
		Conductor.update(dt)

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
			if events[i].eventTime <= absMusicTime then
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
			if event.time <= absMusicTime then
				if event.name == "FocusCamera" and not camera.lockedMoving then
					if type(event.value) == "number" then
						if event.value == 0 then -- Boyfriend
							camera:moveToPoint(1.25, "boyfriend")
						elseif event.value == 1 then -- Enemy
							camera:moveToPoint(1.25, "enemy")
						end
					elseif type(event.value) == "table" then
						event.value.char = tonumber(event.value.char)
						local point = 0
						if event.value.char == 0 then
							point = camera:getPoint("boyfriend")
						elseif event.value.char == 1 then
							point = camera:getPoint("enemy")
						elseif event.value.char == 2 then
							point = camera:getPoint("girlfriend")
						end
						event.value.ease = event.value.ease or "CLASSIC"
						if event.value.ease ~= "INSTANT" then
							local time = (getStepLengthsMS(bpm) * (tonumber(event.value.duration) or 4)) / 1000
							if camTween then 
								Timer.cancel(camTween)
							end

							camTween = Timer.tween(
								time,
								camera,
								{
									x = point.x + (tonumber(event.value.x) or 0),
									y = point.y + (tonumber(event.value.y) or 0)
								},
								CONSTANTS.WEEKS.EASING_TYPES[event.value.ease or "CLASSIC"]
							)
						else
							camera.x = point.x + tonumber(event.value.x or 0)
							camera.y = point.y + tonumber(event.value.y or 0)
						end
					end
				elseif event.name == "PlayAnimation" then
					if event.value.target == "bf" then
						boyfriend:animate(event.value.anim, false)
					end
				elseif event.name == "ZoomCamera" then
					if type(event.value) == "number" then
						camera.zoom = event.value
						uiCam.zoom = event.value
					elseif type(event.value) == "table" then
						event.value.mode = event.value.mode or "stage"
						if event.value.mode == "stage" then
							if event.value.ease ~= "INSTANT" then
								local time = getStepLengthsMS(bpm) * (tonumber(event.value.duration) or 4) / 1000
								if bumpTween then 
									Timer.cancel(bumpTween)
								end
								bumpTween = Timer.tween(
									time,
									camera,
									{defaultZoom = tonumber(event.value.zoom) or 1},
									CONSTANTS.WEEKS.EASING_TYPES[event.value.ease or "CLASSIC"]
								)
							else
								camera.defaultZoom = tonumber(event.value.zoom) or 1
							end
						end
					end
				elseif event.name == "SetCameraBop" then
					if type(event.value) == "number" then
						camera.camBopIntensity = event.value
					elseif type(event.value) == "table" then
						camera.camBopIntensity = event.value.intensity or 1
						camera.camBopInterval = event.value.rate or 4
					end
				end

				table.remove(songEvents, i)
				break
			end
		end

		for i, event in ipairs(modEvents) do
			if event.time <= absMusicTime then
				Gamestate.onEvent(event)

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

		if girlfriend then girlfriend:update(dt) end
		if enemy then enemy:update(dt) end
		if boyfriend then boyfriend:update(dt) end

		if Conductor.onBeat then
			if boyfriend then boyfriend:beat(Conductor.curBeat) end
			if enemy then enemy:beat(Conductor.curBeat) end
			if girlfriend then girlfriend:beat(Conductor.curBeat) end
		end
	end,

	judgeNote = function(self, msTiming)
		if msTiming <= CONSTANTS.WEEKS.JUDGE_THRES.SICK_THRES then
			return "sick"
		elseif msTiming < CONSTANTS.WEEKS.JUDGE_THRES.GOOD_THRES then
			return "good"
		elseif msTiming < CONSTANTS.WEEKS.JUDGE_THRES.BAD_THRES then
			return "bad"
		elseif msTiming < CONSTANTS.WEEKS.JUDGE_THRES.SHIT_THRES then
			return "shit"
		else
			return "miss"
		end
	end,

	scoreNote = function(self, msTiming)
		if msTiming > CONSTANTS.WEEKS.JUDGE_THRES.MISS_THRES then
			return CONSTANTS.WEEKS.MISS_SCORE
		else
			if msTiming < CONSTANTS.WEEKS.JUDGE_THRES.PERFECT_THRES then
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

		NoteSplash:update(dt)
		HoldCover:update(dt)
		updateNotePos()

		healthLerp = util.coolLerp(healthLerp, health, 0.15)

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

					if (enemyNote[j].time - musicTime <= 0) and ableTohit and not enemyNote[j].causesMiss then
						enemyArrow:animate(CONSTANTS.WEEKS.NOTE_LIST[i] .. " confirm", false)
						useAltAnims = false
	
						local whohit = enemy
						-- default to true if nothing is returned
						local continue = (Gamestate.onNoteHit(enemy, enemyNote[j].ver, "EnemyHit", i) == nil or false) and true or false
	
						if continue then
							if enemyNote[j]:getAnimName() == "hold" or enemyNote[j]:getAnimName() == "end" then
								if enemyNote[j]:getAnimName() == "hold" then
									HoldCover:show(i, 2, enemyNote[j].x, enemyNote[j].y)
								else
									HoldCover:hide(i, 2)
								end
								if useAltAnims then
									if whohit and whohit.holdTimer > whohit.maxHoldTimer then whohit:animate(curAnim .. " alt", _psychmod and true or false) end
								else
									if whohit and whohit.holdTimer > whohit.maxHoldTimer then whohit:animate(curAnim, (_psychmod and true or false)) end
								end
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
									if whohit then whohit:animate(curAnim .. " alt", false) end
								else
									if whohit then whohit:animate(curAnim, false) end
								end
							end
						end
	
						if whohit then whohit.lastHit = musicTime end
	
						table.remove(enemyNote, 1)

						break
					elseif not ableTohit and enemyNote[j].time - musicTime <= 0 and not enemyNote[j].didHit then
						enemyNote[j].didHit = true
						Gamestate.onNoteHit(enemy, enemyNote[j].ver, "EnemyHit", i)

						break
					end
				end
			end

			if #gfNote > 0 then
				if gfNote[1].time - musicTime <= 0 then
					if girlfriend then girlfriend:animate(curAnim, false) end

					table.remove(gfNote, 1)
				end
			end

			if #boyfriendNote > 0 then
				if (boyfriendNote[1].time - musicTime <= -200) and not boyfriendNote[1].causesMiss then
					if voicesBF then voicesBF:setVolume(0) end

					if boyfriendNote[1]:getAnimName() ~= "hold" and boyfriendNote[1]:getAnimName() ~= "end" then 
						health = health - CONSTANTS.WEEKS.HEALTH.MISS_PENALTY * healthLossMult * boyfriendNote[1].healthLossMult
						misses = misses + 1
					else
						health = health - (CONSTANTS.WEEKS.HEALTH.MISS_PENALTY * 0.1) * healthLossMult * boyfriendNote[1].healthLossMult
						Gamestate.onNoteMiss(boyfriend, boyfriendNote[1].ver, "BoyfriendMiss", i)
					end

					table.remove(boyfriendNote, 1)

					if boyfriend then boyfriend:animate(curAnim .. " miss", false) end

					if combo >= 5 and girlfriend then girlfriend:animate("sad", false) end

					combo = 0
				end
			end

			if input:pressed(curInput) then
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
							if (boyfriendNote[j].time - musicTime <= CONSTANTS.WEEKS.JUDGE_THRES.MISS_THRES and ((boyfriendNote[j].causesMiss and boyfriendNote[j].time - musicTime > 0) or true)) and not boyfriendNote[j].didHit then
								local notePos
								local ratingAnim

								notePos = math.abs(boyfriendNote[j].time - musicTime)

								if voicesBF then voicesBF:setVolume(1) end

								if boyfriend then boyfriend.lastHit = musicTime end

								ratingAnim = self:judgeNote(notePos)
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

								numbers[1]:animate(tostring(math.floor(combo / 100 % 10)), false)
								numbers[2]:animate(tostring(math.floor(combo / 10 % 10)), false)
								numbers[3]:animate(tostring(math.floor(combo % 10)), false)

								rating:animate(ratingAnim)

								for i = 1, 5 do
									if ratingTimers[i] then Timer.cancel(ratingTimers[i]) end
								end

								rating.y = 300 - 50 + (settings.downscroll and 0 or -490)
								for i = 1, 3 do
									numbers[i].y = 300 + 50 + (settings.downscroll and 0 or -490)
								end

								ratingVisibility[1] = 1
								ratingTimers[1] = Timer.tween(2, ratingVisibility, {0}, "linear")
								ratingTimers[2] = Timer.tween(2, rating, {y = 300 + (settings.downscroll and 0 or -490) - 100}, "out-elastic")

								ratingTimers[3] = Timer.tween(2, numbers[1], {y = 300 + (settings.downscroll and 0 or -490) + love.math.random(-10, 10)}, "out-elastic")
								ratingTimers[4] = Timer.tween(2, numbers[2], {y = 300 + (settings.downscroll and 0 or -490) + love.math.random(-10, 10)}, "out-elastic")
								ratingTimers[5] = Timer.tween(2, numbers[3], {y = 300 + (settings.downscroll and 0 or -490) + love.math.random(-10, 10)}, "out-elastic")

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
											if boyfriend then boyfriend:animate(curAnim, false) end
										else
											audio.playSound(sounds.miss[love.math.random(3)])
											if boyfriend then boyfriend:animate(curAnim .. " miss", false) end
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
	
						if boyfriend then boyfriend:animate(curAnim .. " miss", false) end
	
						if didHitNote then
							score = math.max(0, score - 10)
						end
						health = health - (CONSTANTS.WEEKS.HEALTH.MISS_PENALTY or 0.2) * (healthLossMult or 1) * (boyfriendNote[1].healthLossMult or 1)
						misses = misses + 1
					end
				end
			end

			if #boyfriendNote > 0 and input:down(curInput) and ((boyfriendNote[1].y <= boyfriendArrow.y)) and (boyfriendNote[1]:getAnimName() == "hold" or boyfriendNote[1]:getAnimName() == "end") then
				if boyfriendNote[1]:getAnimName() == "hold" then
					HoldCover:show(i, 1, boyfriendNote[1].x, boyfriendNote[1].y)
				else
					HoldCover:hide(i, 1)
				end
				if voicesBF then voicesBF:setVolume(1) end

				boyfriendArrow:animate(CONSTANTS.WEEKS.NOTE_LIST[i] .. " confirm", false)
				health = health + 0.0125 * healthGainMult * boyfriendNote[1].healthGainMult

				if boyfriend and boyfriend.holdTimer > boyfriend.maxHoldTimer then
					if boyfriend then boyfriend:animate(curAnim, false) end
				end

				table.remove(boyfriendNote, 1)
			end

			if not input:down(curInput) and not HoldCover:getVisibility(i, 1) then
				HoldCover:hide(i, 1)
			end

			if input:released(curInput) then
				boyfriendArrow:animate(CONSTANTS.WEEKS.NOTE_LIST[i], false)
			end

			if not pixel then
				if enemyArrow:getAnimName() ~= CONSTANTS.WEEKS.NOTE_LIST[i] then
					enemyArrow.shaderEnabled = true
				else
					enemyArrow.shaderEnabled = false
				end

				if boyfriendArrow:getAnimName() ~= CONSTANTS.WEEKS.NOTE_LIST[i] then
					boyfriendArrow.shaderEnabled = true
				else
					boyfriendArrow.shaderEnabled = false
				end
			end
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

		enemyIcon.x = 425 - healthLerp * 500
		boyfriendIcon.x = 585 - healthLerp * 500

		if Conductor.onBeat then
			enemyIcon.sizeX, enemyIcon.sizeY = 1.75, 1.75
			boyfriendIcon.sizeX, boyfriendIcon.sizeY = -1.75, 1.75
		end

		enemyIcon.sizeX, enemyIcon.sizeY = util.coolLerp(enemyIcon.sizeX, 1.5, 0.1), enemyIcon.sizeX
		boyfriendIcon.sizeX, boyfriendIcon.sizeY = util.coolLerp(boyfriendIcon.sizeX, -1.5, 0.1), -boyfriendIcon.sizeX
	end,

	drawRating = function(self)
		love.graphics.push()
			--love.graphics.origin()
			love.graphics.translate(0, -35)
			graphics.setColor(1, 1, 1, ratingVisibility[1])
			if pixel and not settings.pixelPerfect then
				love.graphics.translate(-16, 0)
				rating:udraw(5.25, 5.25)
				for i = 1, 3 do
					numbers[i]:udraw(5, 5)
				end
			else
				rating:draw()
				for i = 1, 3 do
					numbers[i]:draw()
				end
			end
			graphics.setColor(1, 1, 1)
		love.graphics.pop()
	end,

	drawUI = function(self)
		if paused then 
			love.graphics.push()
				love.graphics.setFont(pauseFont)
				love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
				if paused then
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
						--  -600, 400+downscrollOffset, 1200, "center"
					else
						uitextflarge("Restart", -305, -75, 600, "center", true)
					end
					if pauseMenuSelection ~= 3 then
						uitextflarge("Quit", -305, 125, 600, "center", false)
					else
						uitextflarge("Quit", -305, 125, 600, "center", true)
					end
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
			if not settings.downscroll then
				love.graphics.scale(0.7, 0.7)
			else
				love.graphics.scale(0.7, -0.7)
			end
			love.graphics.scale(uiCam.zoom, uiCam.zoom)
			love.graphics.translate(uiCam.x, uiCam.y)
			graphics.setColor(1, 1, 1)

			for i = 1, 4 do
				if enemyArrows[i]:getAnimName() == "off" then
					if not settings.middleScroll then
						graphics.setColor(0.6, 0.6, 0.6, enemyArrows[i].alpha)
					else
						graphics.setColor(0.6, 0.6, 0.6, enemyArrows[i].alpha)
					end
				else
					graphics.setColor(1, 1, 1, enemyArrows[i].alpha)
				end
				if pixel and not settings.pixelPerfect then
					if not settings.downscroll then
						enemyArrows[i]:udraw(8, 8)
					else
						enemyArrows[i]:udraw(8, -8)
					end
				else
					enemyArrows[i]:draw()
				end
				graphics.setColor(1, 1, 1)
				if pixel and not settings.pixelPerfect then
					if not settings.downscroll then
						boyfriendArrows[i]:udraw(8, 8)
					else
						boyfriendArrows[i]:udraw(8, -8)
					end
				else
					boyfriendArrows[i]:draw()
				end
				graphics.setColor(1, 1, 1)

				love.graphics.push()
					love.graphics.push()
						for j = #enemyNotes[i], 1, -1 do
							if enemyNotes[i][j].y+enemyNotes[i][j].offsetY2 <= 600 and enemyNotes[i][j].y+enemyNotes[i][j].offsetY2 >= -600 then
								local animName = enemyNotes[i][j]:getAnimName()
								if settings.middleScroll then
									graphics.setColor(1, 1, 1, 0.8 * enemyNotes[i][j].alpha)
								else
									graphics.setColor(1, 1, 1, 1 * enemyNotes[i][j].alpha)
								end

								if pixel and not settings.pixelPerfect then
									if not settings.downscroll then
										enemyNotes[i][j]:udraw(8, 8)
									else
										enemyNotes[i][j]:udraw(8, -8)
									end
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
								graphics.setColor(1, 1, 1, math.min(1, (500 + (boyfriendNotes[i][j].y+boyfriendNotes[i][j].offsetY2)) / 75) * boyfriendNotes[i][j].alpha)

								if pixel and not settings.pixelPerfect then
									if not settings.downscroll then
										boyfriendNotes[i][j]:udraw(8, 8)
									else
										boyfriendNotes[i][j]:udraw(8, -8)
									end
								else
									boyfriendNotes[i][j]:draw()
								end
							end
						end
					love.graphics.pop()
					graphics.setColor(1, 1, 1)
				love.graphics.pop()
			end

			HoldCover:draw()
			if pixel and not settings.pixelPerfect then
				NoteSplash:udraw(8, 8)
			else
				NoteSplash:draw()
			end

			graphics.setColor(1, 1, 1, countdownFade[1])
			if not settings.downscroll then
				if pixel and not settings.pixelPerfect then
					countdown:udraw(6.75, 6.75)
				else
					countdown:draw()
				end
			else
				if pixel and not settings.pixelPerfect then
					countdown:udraw(6.75, -6.75)
				else
					countdown:udraw(1, -1)
				end
			end
			graphics.setColor(1, 1, 1)
		love.graphics.pop()
	end,

	healthbarText = function(self, text, offsetX, offsetY)
		local text = text or "???"
		local colourInline ={1, 1, 1, 1}
		local colourOutline = {0, 0, 0, 1}
		local offsetX = offsetX or 0
		local offsetY = offsetY or 0

		uitextfColored(text, -600+offsetX, 400+downscrollOffset+offsetY, 1200, "center", colourOutline, colourInline)

		self:drawRating()
	end,

	drawHealthbar = function(self, visibility)
		local visibility = visibility or 1
		love.graphics.push()
			love.graphics.translate(push:getWidth() / 2, push:getHeight() / 2)
			love.graphics.scale(0.7, 0.7)
			love.graphics.scale(uiCam.zoom, uiCam.zoom)
			love.graphics.translate(uiCam.x, uiCam.y)
			love.graphics.push()
				graphics.setColor(0,0,0,settings.scrollUnderlayTrans)
				local baseX = boyfriendArrows[1].x - (boyfriendArrows[1]:getFrameWidth(CONSTANTS.WEEKS.NOTE_LIST[1])/2) * (pixel and 8 or 0) + (pixel and -15 or 0)
				local scrollWidth = 0
				-- determine the scrollWidth with the first 4 arrows
				for i = 1, 4 do
					scrollWidth = scrollWidth + boyfriendArrows[i]:getFrameWidth(CONSTANTS.WEEKS.NOTE_LIST[i]) * (pixel and 8 or 0)
				end
				scrollWidth = scrollWidth + 30 + (pixel and 95 or 0)

				if settings.middleScroll and not settings.multiplayer then
					love.graphics.rectangle("fill", baseX, -550, scrollWidth, 1280)
				else
					love.graphics.rectangle("fill", baseX, -550, scrollWidth, 1280)
				end
				graphics.setColor(1,1,1,1)
			love.graphics.pop()
			graphics.setColor(1, 1, 1, visibility)
			graphics.setColor(P2HealthColors[1], P2HealthColors[2], P2HealthColors[3])
			love.graphics.rectangle("fill", -500, 350+downscrollOffset, 1000, 25)
			graphics.setColor(P1HealthColors[1], P1HealthColors[2], P1HealthColors[3])
			love.graphics.rectangle("fill", 500, 350+downscrollOffset, -healthLerp * 500, 25)
			graphics.setColor(0, 0, 0)
			love.graphics.setLineWidth(8)
			love.graphics.rectangle("line", -500, 350+downscrollOffset, 1000, 25)
			love.graphics.setLineWidth(1)
			graphics.setColor(1, 1, 1)

			boyfriendIcon:draw()
			enemyIcon:draw()

			if self.overrideHealthbarText then
				self:overrideHealthbarText(score, misses, ((math.floor(ratingPercent * 10000) / 100)) .. "%")
			else
				self:healthbarText("Score: " .. score .. " | Misses: " .. misses .. " | Accuracy: " .. ((math.floor(ratingPercent * 10000) / 100)) .. "%")
			end
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
	end
}
