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

local animList = {
	"singLEFT",
	"singDOWN",
	"singUP",
	"singRIGHT"
}
local inputList = {
	"gameLeft",
	"gameDown",
	"gameUp",
	"gameRight"
}
local noteList = {
	"left",
	"down",
	"up",
	"right"
}

local easingTypes = {
	["CLASSIC"] = "out-quad",
	["expoOut"] = "out-expo",
	["sineOut"] = "out-sine",
	["elasticInOut"] = "in-out-elastic",
	["bounceOut"] = "out-bounce",
	["backOut"] = "out-back",
	["quartOut"] = "out-quart",
	["quintOut"] = "out-quint",
	["circOut"] = "out-circ",
	["quadOut"] = "out-quad",
	["cubicOut"] = "out-cubic",
	["linear"] = "linear",
}

-- Nabbed from the JS source of FNF v0.3.0 (PBOT Scoring)
local MaxScore, ScoringOffset, ScoringSlope = 500, 54.00, 0.080
local MinScore, MissScore = 9, 0
local PerfectThres, MissThres, KillerThres, SickThres, GoodThres, BadThres, ShitThres = 5, 160, 12.5, 45, 90, 135, 160

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
local option = "normal"

return {
	enter = function(self, option)
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
				icons = love.graphics.newImage(graphics.imagePath("icons")),
				notes = love.graphics.newImage(graphics.imagePath("notes")),
				numbers = love.graphics.newImage(graphics.imagePath("numbers")),
			}

			sprites = {
				icons = love.filesystem.load("sprites/icons.lua"),
				numbers = love.filesystem.load("sprites/numbers.lua"),
			}

			rating = love.filesystem.load("sprites/rating.lua")()

			rating.sizeX, rating.sizeY = 0.75, 0.75

			girlfriend = love.filesystem.load("sprites/girlfriend.lua")()
			boyfriend = love.filesystem.load("sprites/boyfriend.lua")()
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
				icons = love.graphics.newImage(graphics.imagePath("icons")),
				notes = love.graphics.newImage(graphics.imagePath("pixel/notes")),
				numbers = love.graphics.newImage(graphics.imagePath("pixel/numbers")),
			}

			sprites = {
				icons = love.filesystem.load("sprites/icons.lua"),
				numbers = love.filesystem.load("sprites/pixel/numbers.lua"),
			}

			rating = love.filesystem.load("sprites/pixel/rating.lua")()

			girlfriend = love.filesystem.load("sprites/pixel/girlfriend.lua")()
			boyfriend = love.filesystem.load("sprites/pixel/boyfriend.lua")()
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

		enemyIcon = sprites.icons()
		boyfriendIcon = sprites.icons()

		enemyIcon.y = 350 + downscrollOffset
		boyfriendIcon.y = 350 + downscrollOffset
		enemyIcon.sizeX = 1.5
		boyfriendIcon.sizeX = -1.5
		enemyIcon.sizeY = 1.5
		boyfriendIcon.sizeY = 1.5

		countdownFade = {}
		countdown = love.filesystem.load("sprites/countdown.lua")()
	end,

	load = function(self)
		botplayY = 0
		botplayAlpha = {1}
		paused = false
		pauseMenuSelection = 1
		function boyPlayAlphaChange()
			Timer.tween(1.25, botplayAlpha, {0}, "in-out-cubic", function()
				Timer.tween(1.25, botplayAlpha, {1}, "in-out-cubic", boyPlayAlphaChange)
			end)
		end
		boyPlayAlphaChange()
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
				camera:addPoint("girlfriend", -girlfriend.x + 100, -girlfriend.y + 75)
			else
				camera:addPoint("girlfriend", 0, 0)
			end
		end

		-- Function so people can override it if they want
		-- Do some cool note effects or something!
		function updateNotePos()
			for i = 1, 4 do
				for j, note in ipairs(boyfriendNotes[i]) do
					local strumlineY = boyfriendArrows[i].y
					note.y = (strumlineY - (musicTime - note.time) * (0.45 * math.roundDecimal(speed,2)))
				end

				for _, note in ipairs(enemyNotes[i]) do
					local strumlineY = enemyArrows[i].y
					note.y = (strumlineY - (musicTime - note.time) * (0.45 * math.roundDecimal(speed,2)))
				end
			end
		end

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
						Gamestate.switch(menu)

						status.setLoading(false)
					end
				)
			end
		end
	end,

	initUI = function(self, option)
		events = {}
		songEvents = {}
		enemyNotes = {}
		boyfriendNotes = {}
		gfNotes = {}
		health = 1
		score = 0
		misses = 0
		ratingPercent = 0.0
		noteCounter = 0

		if not pixel then
			sprites.leftArrow = love.filesystem.load("sprites/left-arrow.lua")
			sprites.downArrow = love.filesystem.load("sprites/down-arrow.lua")
			sprites.upArrow = love.filesystem.load("sprites/up-arrow.lua")
			sprites.rightArrow = love.filesystem.load("sprites/right-arrow.lua")

			sprites.receptors = love.filesystem.load("sprites/receptor.lua")
		else
			sprites.leftArrow = love.filesystem.load("sprites/pixel/left-arrow.lua")
			sprites.downArrow = love.filesystem.load("sprites/pixel/down-arrow.lua")
			sprites.upArrow = love.filesystem.load("sprites/pixel/up-arrow.lua")
			sprites.rightArrow = love.filesystem.load("sprites/pixel/right-arrow.lua")

			sprites.receptors = love.filesystem.load("sprites/pixel/receptor.lua")
		end

		enemyArrows = {
			sprites.receptors(),
			sprites.receptors(),
			sprites.receptors(),
			sprites.receptors()
		}
		boyfriendArrows= {
			sprites.receptors(),
			sprites.receptors(),
			sprites.receptors(),
			sprites.receptors()
		}

		for i = 1, 4 do
			if settings.middleScroll then 
				boyfriendArrows[i].x = -410 + 165 * i
				-- ew stuff
				enemyArrows[1].x = -925 + 165 * 1 
				enemyArrows[2].x = -925 + 165 * 2
				enemyArrows[3].x = 100 + 165 * 3
				enemyArrows[4].x = 100 + 165 * 4
			else
				enemyArrows[i].x = -925 + 165 * i
				boyfriendArrows[i].x = 100 + 165 * i
			end

			enemyArrows[i].y = -400
			boyfriendArrows[i].y = -400

			boyfriendArrows[i]:animate(noteList[i])
			enemyArrows[i]:animate(noteList[i])

			if settings.downscroll then 
				enemyArrows[i].sizeY = -1
				boyfriendArrows[i].sizeY = -1
			end

			enemyNotes[i] = {}
			boyfriendNotes[i] = {}
			gfNotes[i] = {}
		end
	end,

	generateNotes = function(self, chart, metadata, difficulty)
		local eventBpm
		local chartData = json.decode(love.filesystem.read(chart))
		local chart = chartData.notes[difficulty]

		local metadata = json.decode(love.filesystem.read(metadata))

		local events = {}
		
		for _, timeChange in ipairs(metadata.timeChanges) do
			local time = timeChange.t
			local bpm_ = timeChange.bpm

			table.insert(events, {time = time, bpm = bpm_, type="bpm"})

			if not bpm then bpm = bpm_ end
			if not crochet then crochet = ((60/bpm) * 1000) end
			if not stepCrochet then stepCrochet = crochet / 4 end
		end

		local sprites = {
			sprites.leftArrow,
			sprites.downArrow,
			sprites.upArrow,
			sprites.rightArrow
		}

		local _speed = 1
		if chartData.scrollSpeed[difficulty] then
			_speed = chartData.scrollSpeed[difficulty]
		elseif chartData.scrollSpeed["default"] then
			_speed = chartData.scrollSpeed["default"]
		end

		speed = _speed

		for _, noteData in ipairs(chart) do
			local data = noteData.d % 4 + 1
			local enemyNote = noteData.d > 3
			local time = noteData.t
			local holdTime = noteData.l or 0

			local noteObject = sprites[data]()
			
			noteObject.col = data
			noteObject.y = -400 + time * 0.6 * speed
			noteObject.ver = noteData.k or "normal"
			noteObject.time = time
			noteObject:animate("on")

			if settings.downscroll then noteObject.sizeY = -1 end

			if enemyNote then
				noteObject.x = enemyArrows[data].x
				table.insert(enemyNotes[data], noteObject)

				if holdTime > 0 then
					for k = 71 / speed, holdTime, 71 / speed do
						local holdNote = sprites[data]()
						holdNote.col = data
						holdNote.y = -400 + (time + k) * 0.6 * speed
						holdNote.ver = noteData.k or "normal"
						holdNote.time = time + k
						holdNote:animate("hold")

						if settings.downscroll then holdNote.sizeY = -1 end

						holdNote.x = enemyArrows[data].x
						table.insert(enemyNotes[data], holdNote)
					end

					enemyNotes[data][#enemyNotes[data]]:animate("end")
				end
			else
				noteObject.x = boyfriendArrows[data].x
				table.insert(boyfriendNotes[data], noteObject)

				if holdTime > 0 then
					for k = 71 / speed, holdTime, 71 / speed do
						local holdNote = sprites[data]()
						holdNote.col = data
						holdNote.y = -400 + (time + k) * 0.6 * speed
						holdNote.ver = noteData.k or "normal"
						holdNote.time = time + k
						holdNote:animate("hold")

						if settings.downscroll then holdNote.sizeY = -1 end

						holdNote.x = boyfriendArrows[data].x
						table.insert(boyfriendNotes[data], holdNote)
					end

					boyfriendNotes[data][#boyfriendNotes[data]]:animate("end")
				end
			end
		end

		-- Events !!!
		for _, event in ipairs(chartData.events) do
			local time = event.t
			local eventName = event.e
			local value = event.v

			print(eventName, value)

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
	setupCountdown = function(self)
		lastReportedPlaytime = 0
		musicTime = (240 / bpm) * -1000

		musicThres = 0

		countingDown = true
		countdownFade[1] = 0
		audio.playSound(sounds.countdown.three)
		Timer.after(
			(60 / bpm),
			function()
				countdown:animate("ready")
				countdownFade[1] = 1
				audio.playSound(sounds.countdown.two)
				Timer.tween(
					(60 / bpm),
					countdownFade,
					{0},
					"linear",
					function()
						countdown:animate("set")
						countdownFade[1] = 1
						audio.playSound(sounds.countdown.one)
						Timer.tween(
							(60 / bpm),
							countdownFade,
							{0},
							"linear",
							function()
								countdown:animate("go")
								countdownFade[1] = 1
								audio.playSound(sounds.countdown.go)
								Timer.tween(
									(60 / bpm),
									countdownFade,
									{0},
									"linear",
									function()
										countingDown = false

										previousFrameTime = love.timer.getTime() * 1000
										musicTime = 0
										beatHandler.reset(0)

										if inst then inst:play() end
										if voicesBF then voicesBF:play() end
										if voicesEnemy then voicesEnemy:play() end
									end
								)
							end
						)
					end
				)
			end
		)
	end,

	update = function(self, dt)
		if input:pressed("pause") and not countingDown and not inCutscene and not doingDialogue and not paused then
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
					Gamestate.push(gameOver)
				elseif pauseMenuSelection == 3 then
					paused = false
					if inst then inst:stop() end
					if voicesBF then voicesBF:play() end
					if voicesEnemy then voicesEnemy:play() end
					storyMode = false
					quitPressed = true
				end
			end
			return
		end
		if inCutscene then return end
		beatHandler.update(dt)

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

				if events[i].altAnim then
					useAltAnims = true
				else
					useAltAnims = false
				end

				table.remove(events, i)

				break
			end
		end

		for i, event in ipairs(songEvents) do
			if event.time <= absMusicTime then
				if event.name == "FocusCamera" then
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
								easingTypes[event.value.ease or "CLASSIC"]
							)
						else
							camera.x = point.x + tonumber(event.value.x)
							camera.y = point.y + tonumber(event.value.y)
						end
					end
				elseif event.name == "PlayAnimation" then
					if event.value.target == "bf" then
						boyfriend:animate(event.value.anim, false)
					end
				elseif event.name == "ZoomCamera" then
					if type(event.value) == "number" then
						camera.zoom = event.value
						uiScale.zoom = event.value
					elseif type(event.value) == "table" then
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
									easingTypes[event.value.ease or "CLASSIC"]
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

		if (beatHandler.onBeat() and beatHandler.getBeat() % camera.camBopInterval == 0 and camera.zooming and camera.zoom < 1.35 and not camera.locked) then 
			camera.zoom = camera.zoom + 0.015 * camera.camBopIntensity
			uiScale.zoom = uiScale.zoom + 0.03 * camera.camBopIntensity
		end

		if camera.zooming and not camera.locked then 
			camera.zoom = util.lerp(camera.defaultZoom, camera.zoom, util.clamp(1 - (dt * 3.125), 0, 1))
			uiScale.zoom = util.lerp(1, uiScale.zoom, util.clamp(1 - (dt * 3.125), 0, 1))
		end

		if girlfriend then girlfriend:update(dt) end
		if enemy then enemy:update(dt) end
		if boyfriend then boyfriend:update(dt) end

		if boyfriend then boyfriend:beat(beatHandler.getBeat()) end
		if enemy then enemy:beat(beatHandler.getBeat()) end
		if girlfriend then girlfriend:beat(beatHandler.getBeat()) end
	end,

	judgeNote = function(self, msTiming)
		if msTiming <= SickThres then
			return "sick"
		elseif msTiming < GoodThres then
			return "good"
		elseif msTiming < BadThres then
			return "bad"
		elseif msTiming < ShitThres then
			return "shit"
		else
			return miss
		end
	end,

	scoreNote = function(self, msTiming)
		if msTiming > MissThres then
			return MissScore
		else
			if msTiming < PerfectThres then
				return MaxScore
			else
				local factor = 1 - 1 / (1 + math.exp(-ScoringSlope * (msTiming - ScoringOffset)))
				--var score = funkin_play_scoring_Scoring.PBOT1_MAX_SCORE * factor + funkin_play_scoring_Scoring.PBOT1_MIN_SCORE | 0;
				local score = bit.bxor(MaxScore * factor + MinScore, 0)
				return score
			end
		end
	end,

	updateUI = function(self, dt)
		if inCutscene then return end
		if paused then return end

		updateNotePos()

		for i = 1, 4 do
			local enemyArrow = enemyArrows[i]
			local boyfriendArrow = boyfriendArrows[i]
			local enemyNote = enemyNotes[i]
			local boyfriendNote = boyfriendNotes[i]
			local curAnim = animList[i]
			local curInput = inputList[i]
			local gfNote = gfNotes[i]

			local noteNum = i

			enemyArrow:update(dt)
			boyfriendArrow:update(dt)

			if not enemyArrow:isAnimated() then
				enemyArrow:animate(noteList[i], false)
			end
			if settings.botPlay then
				if not boyfriendArrow:isAnimated() then
					boyfriendArrow:animate(noteList[i], false)
				end
			end

			if #enemyNote > 0 then
				if (enemyNote[1].time - musicTime <= 0) then
					enemyArrow:animate(noteList[i] .. " confirm", false)
					useAltAnims = false
					local finishFunc = true

					local whohit = enemy
					if enemyNote[1].ver == "GF Sing" then
						whohit = girlfriend
					elseif enemyNote[1].ver == "mom" then
						useAltAnims = true
					elseif enemyNote[1].ver == "weekend-1-lightcan" then
						if whohit then whohit:animate("light-can", false) end
						finishFunc = false
					elseif enemyNote[1].ver == "weekend-1-kickcan" then
						if whohit then whohit:animate("kick-can", false) end
						finishFunc = false
					elseif enemyNote[1].ver == "weekend-1-kneecan" then
						if whohit then whohit:animate("knee-forward", false) end
						finishFunc = false
					end

					if finishFunc then
						if enemyNote[1]:getAnimName() == "hold" or enemyNote[1]:getAnimName() == "end" then
							if useAltAnims then
								if whohit and whohit.holdTimer > whohit.maxHoldTimer then whohit:animate(curAnim .. " alt", _psychmod and true or false) end
							else
								if whohit and whohit.holdTimer > whohit.maxHoldTimer then whohit:animate(curAnim, (_psychmod and true or false)) end
							end
						else
							if useAltAnims then
								if whohit then whohit:animate(curAnim .. " alt", false) end
							else
								if whohit then whohit:animate(curAnim, false) end
							end
						end
					end

					if whohit then whohit.lastHit = musicTime end

					table.remove(enemyNote, 1)
				end
			end

			if #gfNote > 0 then
				if gfNote[1].time - musicTime <= 0 then
					if girlfriend then girlfriend:animate(curAnim, false) end

					table.remove(gfNote, 1)
				end
			end

			if #boyfriendNote > 0 then
				if (boyfriendNote[1].time - musicTime <= -200) then
					if voicesBF then voicesBF:setVolume(0) end

					if boyfriendNote[1]:getAnimName() ~= "hold" and boyfriendNote[1]:getAnimName() ~= "end" then 
						health = health - 0.095
						misses = misses + 1
					else
						health = health - 0.0125
					end

					table.remove(boyfriendNote, 1)

					if boyfriend then boyfriend:animate(curAnim .. " miss", false) end

					if combo >= 5 and girlfriend then girlfriend:animate("sad", false) end

					combo = 0
				end
			end

			if settings.botPlay then 
				if #boyfriendNote > 0 then
					if (boyfriendNote[1].time - musicTime <= 0) then
						if voicesBF then voicesBF:setVolume(1) end

						boyfriendArrow:animate(noteList[i] .. " confirm", false)

						if boyfriendNote[1]:getAnimName() == "hold" or boyfriendNote[1]:getAnimName() == "end" then
							if boyfriend and boyfriend.holdTimer >= boyfriend.maxHoldTimer then boyfriend:animate(curAnim, false) end
						else
							if boyfriend then boyfriend:animate(curAnim, false) end
						end

						if boyfriend then boyfriend.lastHit = musicTime end

						if boyfriendNote[1]:getAnimName() ~= "hold" and boyfriendNote[1]:getAnimName() ~= "end" then 
							noteCounter = noteCounter + 1
							combo = combo + 1

							numbers[1]:animate(tostring(math.floor(combo / 100 % 10)), false)
							numbers[2]:animate(tostring(math.floor(combo / 10 % 10)), false)
							numbers[3]:animate(tostring(math.floor(combo % 10)), false)

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
							health = health + 0.095
							score = score + 350

							self:calculateRating()
						else
							health = health + 0.0125
						end

						table.remove(boyfriendNote, 1)
					end
				end
			end

			if input:pressed(curInput) then
				-- if settings.botPlay is true, break our the if statement
				if settings.botPlay then break end
				local success = false

				if settings.ghostTapping then
					success = true
				end

				boyfriendArrow:animate(noteList[i] .. " press", false)

				if #boyfriendNote > 0 then
					for j = 1, #boyfriendNote do
						if boyfriendNote[j] and boyfriendNote[j]:getAnimName() == "on" then
							if (boyfriendNote[j].time - musicTime <= MissThres) then
								local notePos
								local ratingAnim

								notePos = math.abs(boyfriendNote[j].time - musicTime)

								if voicesBF then voicesBF:setVolume(1) end

								if boyfriend then boyfriend.lastHit = musicTime end

								ratingAnim = self:judgeNote(notePos)
								score = score + self:scoreNote(notePos)

								combo = combo + 1
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
									boyfriendArrow:animate(noteList[i] .. " confirm", false)

									if boyfriend then boyfriend:animate(curAnim, false) end

									if boyfriendNote[j]:getAnimName() ~= "hold" and boyfriendNote[j]:getAnimName() ~= "end" then
										health = health + 0.095
									else
										health = health + 0.0125
									end

									success = true
								end

								table.remove(boyfriendNote, j)

								self:calculateRating()
							else
								break
							end
						end
					end
				end

				if not success then
					audio.playSound(sounds.miss[love.math.random(3)])

					if boyfriend then boyfriend:animate(curAnim .. " miss", false) end

					score = math.max(0, score - 10)
					health = health - 0.135
					misses = misses + 1
				end
			end

			if #boyfriendNote > 0 and input:down(curInput) and ((boyfriendNote[1].y <= boyfriendArrow.y)) and (boyfriendNote[1]:getAnimName() == "hold" or boyfriendNote[1]:getAnimName() == "end") then
				if voicesBF then voicesBF:setVolume(1) end

				boyfriendArrow:animate(noteList[i] .. " confirm", false)
				health = health + 0.0125

				if boyfriend and boyfriend.holdTimer > boyfriend.maxHoldTimer then
					if boyfriend then boyfriend:animate(curAnim, false) end
				end

				table.remove(boyfriendNote, 1)
			end

			if input:released(curInput) then
				boyfriendArrow:animate(noteList[i], false)
			end
		end

		-- Enemy
		if health >= 1.595 then
			if enemyIcon:getAnimName() == (enemy and enemy.icon or "boyfriend") then
				enemyIcon:animate((enemy and enemy.icon or "boyfriend") .. " losing", false)
			end
		elseif health < 1.595 then
			if enemyIcon:getAnimName() == (enemy and enemy.icon or "boyfriend") .. " losing" then
				enemyIcon:animate(enemy and enemy.icon or "boyfriend", false)
			end
		end

		-- Boyfriend
		if health > 2 then
			health = 2
		elseif health > 0.325 and boyfriendIcon:getAnimName() == (boyfriend and boyfriend.icon or "boyfriend") .. " losing" then
			boyfriendIcon:animate(boyfriend and boyfriend.icon or "boyfriend", false)
		elseif health <= 0 then -- Game over
			if not settings.practiceMode then Gamestate.push(gameOver) end
			health = 0
		elseif health <= 0.325 and (boyfriend and boyfriendIcon:getAnimName()) == boyfriend.icon then
			if not pixel then 
				boyfriendIcon:animate((boyfriend and boyfriend.icon or "boyfriend") .. " losing", false)
			end
		end

		enemyIcon.x = 425 - health * 500
		boyfriendIcon.x = 585 - health * 500

		if beatHandler.onBeat() then
			if enemyIconTimer then Timer.cancel(enemyIconTimer) end
			if boyfriendIconTimer then Timer.cancel(boyfriendIconTimer) end

			enemyIconTimer = Timer.tween((60 / bpm) / 16, enemyIcon, {sizeX = 1.75, sizeY = 1.75}, "out-quad", function() enemyIconTimer = Timer.tween((60 / bpm), enemyIcon, {sizeX = 1.5, sizeY = 1.5}, "out-quad") end)
			boyfriendIconTimer = Timer.tween((60 / bpm) / 16, boyfriendIcon, {sizeX = -1.75, sizeY = 1.75}, "out-quad", function() boyfriendIconTimer = Timer.tween((60 / bpm), boyfriendIcon, {sizeX = -1.5, sizeY = 1.5}, "out-quad") end)
		end
	end,

	drawRating = function(self)
		love.graphics.push()
			--love.graphics.origin()
			love.graphics.translate(0, -35)
			graphics.setColor(1, 1, 1, ratingVisibility[1])
			if pixel then
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
		self:drawHealthbar()
		love.graphics.push()
			love.graphics.translate(push:getWidth() / 2, push:getHeight() / 2)
			if not settings.downscroll then
				love.graphics.scale(0.7, 0.7)
			else
				love.graphics.scale(0.7, -0.7)
			end
			love.graphics.scale(uiScale.zoom, uiScale.zoom)
			for i = 1, 4 do
				love.graphics.push()				
					love.graphics.push()
						for j = #enemyNotes[i], 1, -1 do
							if enemyNotes[i][j].y <= 560 then
								local animName = enemyNotes[i][j]:getAnimName()
								if animName ~= "on" then 
									if settings.middleScroll then
										graphics.setColor(1, 1, 1, enemyNotes[i][j].alpha * 0.8)
									else
										graphics.setColor(1, 1, 1, enemyNotes[i][j].alpha)
									end
	
									if not pixel then
										enemyNotes[i][j]:draw()
									else
										if not settings.downscroll then
											enemyNotes[i][j]:udraw(8, 8)
										else
											if enemyNotes[i][j]:getAnimName() == "end" then
												enemyNotes[i][j]:udraw(8, 8)
											else
												enemyNotes[i][j]:udraw(8, -8)
											end
										end
									end
								end
							end
						end
					love.graphics.pop()
					love.graphics.push()
						for j = #boyfriendNotes[i], 1, -1 do
							if boyfriendNotes[i][j].y <= 560 then
								local animName = boyfriendNotes[i][j]:getAnimName()
								if animName ~= "on" then
									graphics.setColor(1, 1, 1, boyfriendNotes[i][j].alpha)
									if not pixel then
										boyfriendNotes[i][j]:draw()
									else
										if not settings.downscroll then
											boyfriendNotes[i][j]:udraw(8, 8)
										else
											if boyfriendNotes[i][j]:getAnimName() == "end" then
												boyfriendNotes[i][j]:udraw(8, 8)
											else
												boyfriendNotes[i][j]:udraw(8, -8)
											end
										end
									end
								end
							end
						end
					love.graphics.pop()
				love.graphics.pop()
			end
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
				if not pixel then
					enemyArrows[i]:draw()
				else
					if not settings.downscroll then
						enemyArrows[i]:udraw(8, 8)
					else
						enemyArrows[i]:udraw(8, -8)
					end
				end
				graphics.setColor(1, 1, 1)
				if not pixel then 
					boyfriendArrows[i]:draw()
				else
					if not settings.downscroll then
						boyfriendArrows[i]:udraw(8, 8)
					else
						boyfriendArrows[i]:udraw(8, -8)
					end
				end
				graphics.setColor(1, 1, 1)

				love.graphics.push()
					love.graphics.push()
						for j = #enemyNotes[i], 1, -1 do
							if enemyNotes[i][j].y <= 560 then
								local animName = enemyNotes[i][j]:getAnimName()
								if animName ~= "hold" and animName ~= "end" then
									if settings.middleScroll then
										graphics.setColor(1, 1, 1, 0.8 * enemyNotes[i][j].alpha)
									else
										graphics.setColor(1, 1, 1, 1 * enemyNotes[i][j].alpha)
									end

									if not pixel then
										enemyNotes[i][j]:draw()
									else
										if not settings.downscroll then
											enemyNotes[i][j]:udraw(8, 8)
										else
											enemyNotes[i][j]:udraw(8, -8)
										end
									end
									graphics.setColor(1, 1, 1)
								end
							end
						end
					love.graphics.pop()
					love.graphics.push()
						for j = #boyfriendNotes[i], 1, -1 do
							if boyfriendNotes[i][j].y <= 560 then
								local animName = boyfriendNotes[i][j]:getAnimName()
								if animName ~= "hold" and animName ~= "end" then
									graphics.setColor(1, 1, 1, math.min(1, (500 + (boyfriendNotes[i][j].y)) / 75) * boyfriendNotes[i][j].alpha)

									if not pixel then 
										boyfriendNotes[i][j]:draw()
									else
										if not settings.downscroll then
											boyfriendNotes[i][j]:udraw(8, 8)
										else
											boyfriendNotes[i][j]:udraw(8, -8)
										end
									end
								end
							end
						end
					love.graphics.pop()
					graphics.setColor(1, 1, 1)
				love.graphics.pop()
			end

			graphics.setColor(1, 1, 1, countdownFade[1])
			if not settings.downscroll then
				if not pixel or pixel then 
					countdown:draw()
				else
					countdown:udraw(6.75, 6.75)
				end
			else
				if not pixel or pixel then 
					countdown:udraw(1, -1)
				else
					countdown:udraw(6.75, -6.75)
				end
			end
			graphics.setColor(1, 1, 1)
		love.graphics.pop()
	end,

	healthbarText = function(self, text, colourInline, colourOutline)
		local text = text or "???"
		local colourInline = colourInline or {1, 1, 1, 1}
		if not colourInline[4] then colourInline[4] = 1 end
		local colourOutline = colourOutline or {0, 0, 0, 1}
		if not colourOutline[4] then colourOutline[4] = 1 end
		--textshiz, -600, 400+downscrollOffset, 1200, "center"

		graphics.setColor(colourOutline[1], colourOutline[2], colourOutline[3], colourOutline[4])
		love.graphics.printf(text, -600-2, 400+downscrollOffset, 1200, "center")
		love.graphics.printf(text, -600+2, 400+downscrollOffset, 1200, "center")
		love.graphics.printf(text, -600, 400+downscrollOffset-2, 1200, "center")
		love.graphics.printf(text, -600, 400+downscrollOffset+2, 1200, "center")

		graphics.setColor(colourInline[1], colourInline[2], colourInline[3], colourInline[4])
		love.graphics.printf(text, -600, 400+downscrollOffset, 1200, "center")

		self:drawRating()
	end,

	drawHealthbar = function(self, visibility)
		local visibility = visibility or 1
		love.graphics.push()
			love.graphics.translate(push:getWidth() / 2, push:getHeight() / 2)
			love.graphics.scale(0.7, 0.7)
			love.graphics.scale(uiScale.zoom, uiScale.zoom)
			love.graphics.push()
				graphics.setColor(0,0,0,settings.scrollUnderlayTrans)
				local baseX = boyfriendArrows[1].x - (boyfriendArrows[1]:getFrameWidth(noteList[i])/2) * (pixel and 8 or 0) + (pixel and -15 or 0)
				local scrollWidth = 0
				-- determine the scrollWidth with the first 4 arrows
				for i = 1, 4 do
					scrollWidth = scrollWidth + boyfriendArrows[i]:getFrameWidth(noteList[i]) * (pixel and 8 or 0)
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
			graphics.setColor(1, 0, 0)
			love.graphics.rectangle("fill", -500, 350+downscrollOffset, 1000, 25)
			graphics.setColor(0, 1, 0)
			love.graphics.rectangle("fill", 500, 350+downscrollOffset, -health * 500, 25)
			graphics.setColor(0, 0, 0)
			love.graphics.setLineWidth(10)
			love.graphics.rectangle("line", -500, 350+downscrollOffset, 1000, 25)
			love.graphics.setLineWidth(1)
			graphics.setColor(1, 1, 1)

			boyfriendIcon:draw()
			enemyIcon:draw()

			self:healthbarText("Score: " .. score .. " | Misses: " .. misses .. " | Accuracy: " .. ((math.floor(ratingPercent * 10000) / 100)) .. "%")

			if settings.botPlay then
				botplayY = botplayY + math.sin(love.timer.getTime()) * 0.15
				uitext("BOTPLAY", -85, botplayY, 0, 2, 2, 0, 0, 0, 0, botplayAlpha[1])
				graphics.setColor(1, 1, 1)
			end
		love.graphics.pop()
	end,

	leave = function(self)
		if inst then inst:stop() end
		if voicesBF then voicesBF:stop() end
		if voicesEnemy then voicesEnemy:stop() end

		playMenuMusic = true

		camera:removePoint("boyfriend")
		camera:removePoint("enemy")

		Timer.clear()

		fakeBoyfriend = nil
	end
}
