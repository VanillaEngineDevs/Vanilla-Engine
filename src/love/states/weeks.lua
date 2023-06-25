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
local arrowAngles = {math.rad(180), math.rad(90), math.rad(270), math.rad(0)}
if settings.downscroll then
	-- ezezezezezezezezezezezezez workaround lol
	arrowAngles = {math.rad(180), math.rad(270), math.rad(90), math.rad(0)}
end
local noteCamTweens = {
	function()
		camera:moveToExtra((60/bpm), 15, 0)
	end,

	function()
		camera:moveToExtra((60/bpm), 0, -15)
	end,

	function()
		camera:moveToExtra((60/bpm), 0, 15)
	end,

	function()
		camera:moveToExtra((60/bpm), -15, 0)
	end
}

local ratingTimers = {}

local useAltAnims
local notMissed = {}
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
		for i = 1, 4 do
			notMissed[i] = true
		end
		useAltAnims = false

		camera.x, camera.y = -boyfriend.x + 100, -boyfriend.y + 75

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
		boyfriend:animate("idle")

		if not camera.points["boyfriend"] then camera:addPoint("boyfriend", -boyfriend.x + 100, -boyfriend.y + 75) end
		if not camera.points["enemy"] then 
			if enemy then
				camera:addPoint("enemy", -enemy.x - 100, -enemy.y + 75) 
			end
		end

		graphics:fadeInWipe(0.6)
	end,

	calculateRating = function(self)
		ratingPercent = score / ((noteCounter + misses) * 350)
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
		if not (countingDown or graphics.isFading()) and not (inst:isPlaying()) and not paused and not inCutscene then
			if storyMode and song < #weekMeta[weekNum][2] then
				self:saveData()
				song = song + 1
				print(song)

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
		enemyNotes = {}
		boyfriendNotes = {}
		gfNotes = {}
		health = 1
		score = 0
		misses = 0
		ratingPercent = 0.0
		noteCounter = 0

		songEvents = {}

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

		NoteSplash:setup()

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

			boyfriendArrows[i].orientation = 0
			enemyArrows[i].orientation = 0

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

	generateNotes = function(self, chart, psychweek, song, difficulty)
		local eventBpm
		local chart = chart
		if chart == nil and _psychmod then
			-- its most likely a psych mod
			chart = "mods/" .. weekMeta[psychweek][3]
			CURSONGFULLPATH = chart .. "/data/" .. weekMeta[psychweek][2][song]:gsub(" ", "-")
			chart = chart .. "/data/" .. weekMeta[psychweek][2][song]:gsub(" ", "-") .. "/" .. weekMeta[psychweek][2][song]:gsub(" ", "-"):lower() .. difficulty .. ".json"
			chartpath = "mods/" .. weekMeta[psychweek][3]
			chartpath = chartpath .. "/data/" .. weekMeta[psychweek][2][song]:gsub(" ", "-")
			inst = "mods/" .. weekMeta[psychweek][3]
			inst = inst .. "/songs/" .. weekMeta[psychweek][2][song]:gsub(" ", "-") .. "/Inst.ogg"

			inst = love.audio.newSource(inst, "static")
		end
		if not love.filesystem.getInfo(chart) then
			chart = chart:gsub("-hard", ""):gsub("-easy", "")
		end
		-- if it still doesn't exist, add -easy to the end
		if not love.filesystem.getInfo(chart) then
			chart = chart:gsub(".json", "-easy.json")
		end
		-- if it still errors, try hard
		if not love.filesystem.getInfo(chart) then
			chart = chart:gsub("-easy", "-hard")
		end

		-- if it still errors, then load the next json file that isn't "events.json"
		if not love.filesystem.getInfo(chart) and _psychmod then
			local files = love.filesystem.getDirectoryItems(chartpath)
			for i = 1, #files do
				if files[i] ~= "events.json" and files[i]:sub(-5) == ".json" then
					chart = chartpath .. "/" .. files[i]
					break
				end
			end
		end
		chart = love.filesystem.read(chart)
		chart = json.decode(chart)
		chart = chart["song"]
		curSong = chart["song"]

		if _psychmod then
			psychenemy = chart.player2
			psychboyfriend = chart.player1
			psychgirlfriend = chart.gfVersion
			psychstage = chart.stage

			songName = weekMeta[psychweek][2][song]
		end

		needsVoices = chart.needsVoices
		if needsVoices == true and _psychmod then
			voices = "mods/" .. weekMeta[psychweek][3]
			voices = voices .. "/songs/" .. weekMeta[psychweek][2][song]:gsub(" ", "-") .. "/Voices.ogg"

			voices = love.audio.newSource(voices, "static")
		end

		for i = 1, #chart["notes"] do
			bpm = chart["notes"][i]["bpm"]

			if bpm then
				break
			end
		end
		if not bpm then
			bpm = chart["bpm"]
		end
		if not bpm then
			bpm = 100
		end
		beatHandler.setBPM(bpm)

		if settings.customScrollSpeed == 1 then
			speed = chart["speed"] or 1
		else
			speed = settings.customScrollSpeed
		end

		for i = 1, #chart["notes"] do
			for j = 1, #chart["notes"][i]["sectionNotes"] do
				local sprite
				local sectionNotes = chart["notes"][i]["sectionNotes"]

				local mustHitSection = chart["notes"][i]["mustHitSection"]
				local altAnim = chart["notes"][i]["altAnim"] or false
				local noteType = sectionNotes[j][2]
				local noteTime = sectionNotes[j][1]
				local noteVer = sectionNotes[j][4] or "normal"

				if j == 1 then
					table.insert(events, {eventTime = sectionNotes[1][1], mustHitSection = mustHitSection, bpm = bpm, altAnim = altAnim})
				end

				if noteType == 0 or noteType == 4 then
					sprite = sprites.leftArrow
				elseif noteType == 1 or noteType == 5 then
					sprite = sprites.downArrow
				elseif noteType == 2 or noteType == 6 then
					sprite = sprites.upArrow
				elseif noteType == 3 or noteType == 7 then
					sprite = sprites.rightArrow
				end

				if mustHitSection and noteVer ~= "Hurt Note" then
					if noteType >= 4 then
					   	local id = noteType - 3
					   	local c = #enemyNotes[id] + 1
					   	local x = enemyArrows[id].x

						local beatRow = util.round(((noteTime / 1000) * (bpm / 60)) * 48)
				 
						if settings.colourByQuantization then
							if (beatRow % (192 / 4) == 0) then 
								col = 1
								sprite = sprites.leftArrow
							elseif (beatRow % (192 / 8) == 0) then
								col = 2
								sprite = sprites.downArrow
							elseif (beatRow % (192 / 12) ==  0) then 
								col = 3
								sprite = sprites.upArrow
							elseif (beatRow % (192 / 16) == 0) then
								col = 4
								sprite = sprites.rightArrow
							elseif (beatRow % (192 / 24) == 0) then
								col = 3
								sprite = sprites.upArrow
							elseif (beatRow % (192 / 32) == 0) then
								col = 3
								sprite = sprites.upArrow
							else
								col = id
							end
						else
							col = id
						end

					   	table.insert(enemyNotes[id], sprite())
						enemyNotes[id][c].col = col
					   	enemyNotes[id][c].x = x
					   	enemyNotes[id][c].y = -400 + noteTime * 0.6 * speed
						enemyNotes[id][c].orientation = enemyNotes[id][c].orientation - arrowAngles[enemyNotes[id][c].col]
						enemyNotes[id][c].orientation = enemyNotes[id][c].orientation + arrowAngles[id]
						enemyNotes[id][c].ver = noteVer

						if settings.downscroll then
							enemyNotes[id][c].sizeY = -1
						end
				 
					   	enemyNotes[id][c]:animate("on", false)
				 
					    if sectionNotes[j][3] > 0 then
						  	local c
				 
						  	for k = 71 / speed, sectionNotes[j][3], 71 / speed do
							 	local c = #enemyNotes[id] + 1
				 
							 	table.insert(enemyNotes[id], sprite())
							 	enemyNotes[id][c].x = x
							 	enemyNotes[id][c].y = -400 + (noteTime + k) * 0.6 * speed
								enemyNotes[id][c].col = col
								enemyNotes[id][c].ver = noteVer
				 
								enemyNotes[id][c]:animate("hold", false)
							end
				 
							c = #enemyNotes[id]
				 
							enemyNotes[id][c].offsetY = not pixel and 10 or 2
				 
						  	enemyNotes[id][c]:animate("end", false)
					    end
					elseif noteType < 4 and noteType >= 0 then
					   	local id = noteType + 1
					   	local c = #boyfriendNotes[id] + 1
					   	local x = boyfriendArrows[id].x

						local beatRow = util.round(((noteTime / 1000) * (bpm / 60)) * 48)
				 
						if settings.colourByQuantization then
							if (beatRow % (192 / 4) == 0) then 
								col = 1
								sprite = sprites.leftArrow
							elseif (beatRow % (192 / 8) == 0) then
								col = 2
								sprite = sprites.downArrow
							elseif (beatRow % (192 / 12) ==  0) then 
								col = 3
								sprite = sprites.upArrow
							elseif (beatRow % (192 / 16) == 0) then
								col = 4
								sprite = sprites.rightArrow
							elseif (beatRow % (192 / 24) == 0) then
								col = 3
								sprite = sprites.upArrow
							elseif (beatRow % (192 / 32) == 0) then
								col = 3
								sprite = sprites.upArrow
							else
								col = id
							end
						else
							col = id
						end

					   	table.insert(boyfriendNotes[id], sprite())
						boyfriendNotes[id][c].col = col
					   	boyfriendNotes[id][c].x = x
					   	boyfriendNotes[id][c].y = -400 + noteTime * 0.6 * speed
						boyfriendNotes[id][c].time = noteTime
						boyfriendNotes[id][c].orientation = boyfriendNotes[id][c].orientation - arrowAngles[boyfriendNotes[id][c].col]
						boyfriendNotes[id][c].orientation = boyfriendNotes[id][c].orientation + arrowAngles[id]
						boyfriendNotes[id][c].ver = noteVer
						
						if settings.downscroll then
							boyfriendNotes[id][c].sizeY = -1
						end
				 
					   	boyfriendNotes[id][c]:animate("on", false)
				 
					   	if sectionNotes[j][3] > 0 then
						  	local c
				 
						  	for k = 71 / speed, sectionNotes[j][3], 71 / speed do
							 	local c = #boyfriendNotes[id] + 1
				 
							 	table.insert(boyfriendNotes[id], sprite())
							 	boyfriendNotes[id][c].x = x
							 	boyfriendNotes[id][c].y = -400 + (noteTime + k) * 0.6 * speed
								boyfriendNotes[id][c].col = col
								boyfriendNotes[id][c].ver = noteVer
				 
							 	boyfriendNotes[id][c]:animate("hold", false)
						  	end
				 
						  	c = #boyfriendNotes[id]
				 
						  	boyfriendNotes[id][c].offsetY = not pixel and 10 or 2
				 
						  	boyfriendNotes[id][c]:animate("end", false)
					   	end
					end
				elseif not mustHitSection and noteVer ~= "Hurt Note" then
					if noteType >= 4 then
					   	local id = noteType - 3
					   	local c = #boyfriendNotes[id] + 1
					   	local x = boyfriendArrows[id].x

						local beatRow = util.round(((noteTime / 1000) * (bpm / 60)) * 48)
				 
						if settings.colourByQuantization then
							if (beatRow % (192 / 4) == 0) then 
								col = 1
								sprite = sprites.leftArrow
							elseif (beatRow % (192 / 8) == 0) then
								col = 2
								sprite = sprites.downArrow
							elseif (beatRow % (192 / 12) ==  0) then 
								col = 3
								sprite = sprites.upArrow
							elseif (beatRow % (192 / 16) == 0) then
								col = 4
								sprite = sprites.rightArrow
							elseif (beatRow % (192 / 24) == 0) then
								col = 3
								sprite = sprites.upArrow
							elseif (beatRow % (192 / 32) == 0) then
								col = 3
								sprite = sprites.upArrow
							else
								col = id
							end
						else
							col = id
						end
				 
					   	table.insert(boyfriendNotes[id], sprite())
						boyfriendNotes[id][c].col = col
					   	boyfriendNotes[id][c].x = x
					   	boyfriendNotes[id][c].y = -400 + noteTime * 0.6 * speed
						boyfriendNotes[id][c].time = noteTime
						boyfriendNotes[id][c].orientation = boyfriendNotes[id][c].orientation - arrowAngles[boyfriendNotes[id][c].col]
						boyfriendNotes[id][c].orientation = boyfriendNotes[id][c].orientation + arrowAngles[id]
						boyfriendNotes[id][c].ver = noteVer
						
						if settings.downscroll then
							boyfriendNotes[id][c].sizeY = -1
						end
				 
					   	boyfriendNotes[id][c]:animate("on", false)
				 
					   	if sectionNotes[j][3] > 0 then
						  	local c
				 
						  	for k = 71 / speed, sectionNotes[j][3], 71 / speed do
							 	local c = #boyfriendNotes[id] + 1
				 
							 	table.insert(boyfriendNotes[id], sprite())
							 	boyfriendNotes[id][c].x = x
							 	boyfriendNotes[id][c].y = -400 + (noteTime + k) * 0.6 * speed
								boyfriendNotes[id][c].col = col
								boyfriendNotes[id][c].ver = noteVer
				 
							 	boyfriendNotes[id][c]:animate("hold", false)
						  	end
				 
						  	c = #boyfriendNotes[id]
				 
						  	boyfriendNotes[id][c].offsetY = not pixel and 10 or 2
				 
						  	boyfriendNotes[id][c]:animate("end", false)
					   	end
					elseif noteType < 4 and noteType >= 0 then
					   	local id = noteType + 1
					   	local c = #enemyNotes[id] + 1
					   	local x = enemyArrows[id].x

						local beatRow = util.round(((noteTime / 1000) * (bpm / 60)) * 48)
				 
						if settings.colourByQuantization then
							if (beatRow % (192 / 4) == 0) then 
								col = 1
								sprite = sprites.leftArrow
							elseif (beatRow % (192 / 8) == 0) then
								col = 2
								sprite = sprites.downArrow
							elseif (beatRow % (192 / 12) ==  0) then 
								col = 3
								sprite = sprites.upArrow
							elseif (beatRow % (192 / 16) == 0) then
								col = 4
								sprite = sprites.rightArrow
							elseif (beatRow % (192 / 24) == 0) then
								col = 3
								sprite = sprites.upArrow
							elseif (beatRow % (192 / 32) == 0) then
								col = 3
								sprite = sprites.upArrow
							else
								col = id
							end
						else
							col = id
						end
				 
					   	table.insert(enemyNotes[id], sprite())
						enemyNotes[id][c].col = col
					   	enemyNotes[id][c].x = x
					   	enemyNotes[id][c].y = -400 + noteTime * 0.6 * speed
						enemyNotes[id][c].orientation = enemyNotes[id][c].orientation - arrowAngles[enemyNotes[id][c].col]
						enemyNotes[id][c].orientation = enemyNotes[id][c].orientation + arrowAngles[id]
						enemyNotes[id][c].ver = noteVer
						if settings.downscroll then
							enemyNotes[id][c].sizeY = -1
						end
				 
					   	enemyNotes[id][c]:animate("on", false)
				 
					   	if sectionNotes[j][3] > 0 then
						  	local c
				 
						  	for k = 71 / speed, sectionNotes[j][3], 71 / speed do
							 	local c = #enemyNotes[id] + 1
				 
							 	table.insert(enemyNotes[id], sprite())
							 	enemyNotes[id][c].x = x
							 	enemyNotes[id][c].y = -400 + (noteTime + k) * 0.6 * speed
								enemyNotes[id][c].col = col
								enemyNotes[id][c].ver = noteVer
							 	if k > sectionNotes[j][3] - 71 / speed then
									enemyNotes[id][c].offsetY = not pixel and 10 or 2
				 
									enemyNotes[id][c]:animate("end", false)
							 	else
									enemyNotes[id][c]:animate("hold", false)
							 	end
						  	end
				 
						  	c = #enemyNotes[id]
				 
						  	enemyNotes[id][c].offsetY = not pixel and 10 or 2
				 
						  	enemyNotes[id][c]:animate("end", false)
					   	end
					end
				end
			end
		end

		for i = 1, 4 do
			table.sort(enemyNotes[i], function(a, b) return a.y < b.y end)
			table.sort(boyfriendNotes[i], function(a, b) return a.y < b.y end)
		end

		-- Workarounds for bad charts that have multiple notes around the same place
		for i = 1, 4 do
			local offset = 0

			for j = 2, #enemyNotes[i] do
				local index = j - offset

				if enemyNotes[i][index]:getAnimName() == "on" and enemyNotes[i][index - 1]:getAnimName() == "on" and ((enemyNotes[i][index].y - enemyNotes[i][index - 1].y <= 10)) then
					table.remove(enemyNotes[i], index)

					offset = offset + 1
				end
			end
		end
		for i = 1, 4 do
			local offset = 0

			for j = 2, #boyfriendNotes[i] do
				local index = j - offset

				if boyfriendNotes[i][index]:getAnimName() == "on" and boyfriendNotes[i][index - 1]:getAnimName() == "on" and ((boyfriendNotes[i][index].y - boyfriendNotes[i][index - 1].y <= 10)) then
					table.remove(boyfriendNotes[i], index)

					offset = offset + 1
				end
			end
		end
	end,

	generateEvents = function(self, charte, psychweek, song, difficulty)
		local charte = charte
		if charte == nil and _psychmod then
			-- its most likely a psych mod
			charte = "mods/" .. weekMeta[psychweek][3]
			charte = charte .. "/data/" .. weekMeta[psychweek][2][song] .. "/events.json"
			-- if it exists, use it
			if not love.filesystem.getInfo(charte) then
				charte = "mods/" .. weekMeta[psychweek][3]
				charte = charte .. "/data/" .. weekMeta[psychweek][2][song] .. "/" .. weekMeta[psychweek][2][song] .. difficulty .. ".json"
			end
		end
		if not love.filesystem.getInfo(charte) then
			charte = charte:gsub("-hard", ""):gsub("-easy", "")
		end
		-- if it still doesn't exist, add -easy to the end
		if not love.filesystem.getInfo(charte) then
			charte = charte:gsub(".json", "-easy.json")
		end
		-- if it still errors, try hard
		if not love.filesystem.getInfo(charte) then
			charte = charte:gsub("-easy", "-hard")
		end
		pcall(
			function()
				charte = json.decode(love.filesystem.read(charte)).song
				-- for all in charte.events, add it to songEvents
				for i = 1, #charte.events do
					local eventTime = charte.events[i][1]
					local event = charte.events[i][2][1][1]
					local eventArgs = charte.events[i][2][1][2]
					local eventArgs2 = charte.events[i][2][1][3]

					table.insert(songEvents, {time = eventTime, event = event, n=event, args = eventArgs, args2 = eventArgs2})
				end
			end
		)
	end,

	generateGFNotes = function(self, chartG)
		-- very bare-bones chart generation
		-- Does not handle sprites and all that, just note timings and type
		local chartG = json.decode(love.filesystem.read(chartG)).song

		for i = 1, #chartG.notes do
			for j = 1, #chartG.notes[i].sectionNotes do
				local sn = chartG.notes[i].sectionNotes
				local noteType = sn[j][2] % 4 + 1
				local noteTime = sn[j][1]

				table.insert(gfNotes[noteType], {time = noteTime})
			end
		end

		for i = 1, 4 do
			local offset = 0

			for j = 2, #gfNotes[i] do
				local index = j - offset

				if gfNotes[i][index].time == gfNotes[i][index - 1].time then
					table.remove(gfNotes[i], index)

					offset = offset + 1
				end
			end

			table.sort(gfNotes[i], function(a, b) return a.time < b.time end)
		end
	end,

	-- Gross countdown script
	setupCountdown = function(self)
		lastReportedPlaytime = 0
		musicTime = (240 / bpm) * -1000

		musicThres = 0
		musicPos = 0

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
										if voices then voices:play() end
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
					if voices then voices:pause() end
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
					if voices then voices:play() end
					paused = false 
				elseif pauseMenuSelection == 2 then
					pauseRestart = true
					Gamestate.push(gameOver)
				elseif pauseMenuSelection == 3 then
					paused = false
					if inst then inst:stop() end
					if voices then voices:play() end
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
				local seconds = voices and voices:tell("seconds") or inst:tell("seconds")

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

				if camera.mustHit then
					if events[i].mustHitSection then
						mustHitSection = true
						--camTimer = Timer.tween(1.25, camera, {x = -boyfriend.x + 100, y = -boyfriend.y + 75}, "out-quad")
						camera:moveToPoint(1.25, "boyfriend")
					else
						mustHitSection = false
						--camTimer = Timer.tween(1.25, camera, {x = -enemy.x - 100, y = -enemy.y + 75}, "out-quad")
						camera:moveToPoint(1.25, "enemy")
					end
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

		if (beatHandler.onBeat() and beatHandler.getBeat() % camera.camBopInterval == 0 and camera.zooming and camera.zoom < 1.35 and not camera.locked) then 
			camera.zoom = camera.zoom + 0.015 * camera.camBopIntensity
			uiScale.zoom = uiScale.zoom + 0.03 * camera.camBopIntensity
		end

		if camera.zooming and not camera.locked then 
			camera.zoom = util.lerp(camera.defaultZoom, camera.zoom, util.clamp(1 - (dt * 3.125), 0, 1))
			uiScale.zoom = util.lerp(1, uiScale.zoom, util.clamp(1 - (dt * 3.125), 0, 1))
		end

		girlfriend:update(dt)
		enemy:update(dt)
		boyfriend:update(dt)

		boyfriend:beat(beatHandler.getBeat())
		enemy:beat(beatHandler.getBeat())
		girlfriend:beat(beatHandler.getBeat())
	end,

	updateUI = function(self, dt)
		if inCutscene then return end
		if paused then return end
		musicPos = musicTime * 0.6 * speed

		NoteSplash:update(dt)

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
				enemyArrow.orientation = 0
			end
			if settings.botPlay then
				if not boyfriendArrow:isAnimated() then
					boyfriendArrow:animate(noteList[i], false)
					boyfriendArrow.orientation = 0
				end
			end

			if #enemyNote > 0 then
				if (enemyNote[1].y - musicPos <= -410) then
					if voices then voices:setVolume(1) end

					enemyArrow:animate(noteList[enemyNote[1].col] .. " confirm", false)
					if enemyNote[1]:getAnimName() ~= "hold" and enemyNote[1]:getAnimName() ~= "end" then
						enemyArrow.orientation = enemyArrow.orientation - arrowAngles[enemyNote[1].col]
						enemyArrow.orientation = enemyArrow.orientation + arrowAngles[i]
					end

					if enemyNote[1].ver ~= "GF Sing" then
						if enemyNote[1]:getAnimName() == "hold" or enemyNote[1]:getAnimName() == "end" then
							if useAltAnims then
								if enemy.holdTimer > enemy.maxHoldTimer then enemy:animate(curAnim .. " alt", _psychmod and true or false) end
							else
								if enemy.holdTimer > enemy.maxHoldTimer then enemy:animate(curAnim, (_psychmod and true or false)) end
							end
						else
							if useAltAnims then
								enemy:animate(curAnim .. " alt", false)
							else
								enemy:animate(curAnim, false)
							end
						end

						enemy.lastHit = musicTime
					else
						if enemyNote[1]:getAnimName() == "hold" or enemyNote[1]:getAnimName() == "end" then
							if useAltAnims then
								if girlfriend.holdTimer > enemy.maxHoldTimer then girlfriend:animate(curAnim .. " alt", _psychmod and true or false) end
							else
								if girlfriend.holdTimer > enemy.maxHoldTimer then girlfriend:animate(curAnim, (_psychmod and true or false)) end
							end
						else
							if useAltAnims then
								girlfriend:animate(curAnim .. " alt", false)
							else
								girlfriend:animate(curAnim, false)
							end
						end

						girlfriend.lastHit = musicTime
					end

					if not mustHitSection then 
						noteCamTweens[i]()
					end

					table.remove(enemyNote, 1)
				end
			end

			if #gfNote > 0 then
				if gfNote[1].time - musicTime <= 0 then
					girlfriend:animate(curAnim, false)

					table.remove(gfNote, 1)
				end
			end

			if #boyfriendNote > 0 then
				if (boyfriendNote[1].y - musicPos < -600) then
					if voices then voices:setVolume(0) end

					notMissed[noteNum] = false

					if boyfriendNote[1]:getAnimName() ~= "hold" and boyfriendNote[1]:getAnimName() ~= "end" then 
						health = health - 0.095
						misses = misses + 1
					else
						health = health - 0.0125
					end

					table.remove(boyfriendNote, 1)

					boyfriend:animate(curAnim .. " miss", false)

					if combo >= 5 then girlfriend:animate("sad", false) end

					combo = 0
				end
			end

			if settings.botPlay then 
				if #boyfriendNote > 0 then
					if (boyfriendNote[1].y - musicPos <= -400) then
						if voices then voices:setVolume(1) end

						boyfriendArrow:animate(noteList[boyfriendNote[1].col] .. " confirm", false)
						boyfriendArrow.orientation = boyfriendArrow.orientation - arrowAngles[boyfriendNote[1].col]
						boyfriendArrow.orientation = boyfriendArrow.orientation + arrowAngles[i]

						if boyfriendNote[1]:getAnimName() == "hold" or boyfriendNote[1]:getAnimName() == "end" then
							if boyfriend.holdTimer >= boyfriend.maxHoldTimer then boyfriend:animate(curAnim, false) end
						else
							boyfriend:animate(curAnim, false)
						end

						boyfriend.lastHit = musicTime

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

							if mustHitSection then 
								noteCamTweens[i]()
							end

							ratingVisibility[1] = 1
							ratingTimers[1] = Timer.tween(2, ratingVisibility, {0}, "linear")
							ratingTimers[2] = Timer.tween(2, rating, {y = 300 + (settings.downscroll and 0 or -490) - 100}, "out-elastic")

							ratingTimers[3] = Timer.tween(2, numbers[1], {y = 300 + (settings.downscroll and 0 or -490) + love.math.random(-10, 10)}, "out-elastic")
							ratingTimers[4] = Timer.tween(2, numbers[2], {y = 300 + (settings.downscroll and 0 or -490) + love.math.random(-10, 10)}, "out-elastic")
							ratingTimers[5] = Timer.tween(2, numbers[3], {y = 300 + (settings.downscroll and 0 or -490) + love.math.random(-10, 10)}, "out-elastic")
							health = health + 0.095
							score = score + 350

							NoteSplash:new(
								{
									anim = noteList[boyfriendNote[1].col] .. love.math.random(1,2),
									posX = boyfriendArrow.x,
								}
							)
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
				boyfriendArrow.orientation = 0

				if #boyfriendNote > 0 then
					for j = 1, #boyfriendNote do
						if boyfriendNote[j] and boyfriendNote[j]:getAnimName() == "on" then
							if (boyfriendNote[j].time - musicTime <= 150) then
								local notePos
								local ratingAnim

								notMissed[noteNum] = true

								notePos = math.abs(boyfriendNote[j].time - musicTime)

								if voices then voices:setVolume(1) end

								boyfriend.lastHit = musicTime

								if notePos <= 55 then -- "Sick"
									score = score + 350
									ratingAnim = "sick"

									NoteSplash:new({
										anim = noteList[boyfriendNote[j].col] .. love.math.random(1,2),
										posX = boyfriendArrow.x,
									})
								elseif notePos <= 90 then -- "Good"
									score = score + 200
									ratingAnim = "good"
								elseif notePos <= 120 then -- "Bad"
									score = score + 100
									ratingAnim = "bad"
								else -- "Shit"
									if settings.ghostTapping then
										success = false
									end
									ratingAnim = "shit"
								end
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

								if mustHitSection then 
									noteCamTweens[i]()
								end

								ratingVisibility[1] = 1
								ratingTimers[1] = Timer.tween(2, ratingVisibility, {0}, "linear")
								ratingTimers[2] = Timer.tween(2, rating, {y = 300 + (settings.downscroll and 0 or -490) - 100}, "out-elastic")

								ratingTimers[3] = Timer.tween(2, numbers[1], {y = 300 + (settings.downscroll and 0 or -490) + love.math.random(-10, 10)}, "out-elastic")
								ratingTimers[4] = Timer.tween(2, numbers[2], {y = 300 + (settings.downscroll and 0 or -490) + love.math.random(-10, 10)}, "out-elastic")
								ratingTimers[5] = Timer.tween(2, numbers[3], {y = 300 + (settings.downscroll and 0 or -490) + love.math.random(-10, 10)}, "out-elastic")

								if not settings.ghostTapping or success then
									boyfriendArrow:animate(noteList[boyfriendNote[1].col] .. " confirm", false)
									boyfriendArrow.orientation = boyfriendArrow.orientation - arrowAngles[boyfriendNote[1].col]
									boyfriendArrow.orientation = boyfriendArrow.orientation + arrowAngles[i]

									boyfriend:animate(curAnim, false)

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

					notMissed[noteNum] = false

					if combo >= 5 then girlfriend:animate("sad", false) end

					boyfriend:animate(curAnim .. " miss", false)

					score = score - 10
					combo = 0
					health = health - 0.135
					misses = misses + 1
				end
			end

			if #boyfriendNote > 0 and input:down(curInput) and ((boyfriendNote[1].y - musicPos <= -400)) and (boyfriendNote[1]:getAnimName() == "hold" or boyfriendNote[1]:getAnimName() == "end") then
				if voices then voices:setVolume(1) end

				boyfriendArrow:animate(noteList[boyfriendNote[1].col] .. " confirm", false)

				if boyfriendArrow.orientation == 0 then 
					boyfriendArrow.orientation = boyfriendArrow.orientation - arrowAngles[boyfriendNote[1].col]
					boyfriendArrow.orientation = boyfriendArrow.orientation + arrowAngles[i]
				end

				health = health + 0.0125

				if boyfriend.holdTimer > boyfriend.maxHoldTimer then
					boyfriend:animate(curAnim, false)
				end

				table.remove(boyfriendNote, 1)
			end

			if input:released(curInput) then
				boyfriendArrow:animate(noteList[i], false)
				boyfriendArrow.orientation = 0
			end
		end

		if health > 2 then
			health = 2
		elseif health > 0.325 and boyfriendIcon:getAnimName() == "boyfriend losing" then
			if not pixel then 
				boyfriendIcon:animate("boyfriend", false)
			else
				boyfriendIcon:animate("boyfriend (pixel)", false)
			end
		elseif health <= 0 then -- Game over
			if not settings.practiceMode then Gamestate.push(gameOver) end
			health = 0
		elseif health <= 0.325 and boyfriendIcon:getAnimName() == "boyfriend" then
			if not pixel then 
				boyfriendIcon:animate("boyfriend losing", false)
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
			love.graphics.translate(lovesize.getWidth() / 2, lovesize.getHeight() / 2)
			if not settings.downscroll then
				love.graphics.scale(0.7, 0.7)
			else
				love.graphics.scale(0.7, -0.7)
			end
			love.graphics.scale(uiScale.zoom, uiScale.zoom)
			for i = 1, 4 do
				love.graphics.push()
				
					love.graphics.translate(0, -musicPos)
				
					love.graphics.push()
						for j = #enemyNotes[i], 1, -1 do
							if enemyNotes[i][j].y - musicPos <= 560 then
								local animName = enemyNotes[i][j]:getAnimName()
								if animName ~= "on" then 
									if settings.middleScroll then
										graphics.setColor(1, 1, 1, 0.3)
									else
										graphics.setColor(1, 1, 1, 0.5)
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
							if boyfriendNotes[i][j].y - musicPos <= 560 then
								local animName = boyfriendNotes[i][j]:getAnimName()
								if animName ~= "on" then
									graphics.setColor(1, 1, 1, math.min(0.5, (500 + (boyfriendNotes[i][j].y - musicPos)) / 150))
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
						graphics.setColor(0.6, 0.6, 0.6)
					else
						graphics.setColor(0.6, 0.6, 0.6, 0.6)
					end
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
					NoteSplash:draw()
				else
					if not settings.downscroll then
						boyfriendArrows[i]:udraw(8, 8)
						NoteSplash:udraw(8, 8)
					else
						boyfriendArrows[i]:udraw(8, -8)
						NoteSplash:udraw(8, -8)
					end
				end
				graphics.setColor(1, 1, 1)

				love.graphics.push()
					love.graphics.translate(0, -musicPos)

					love.graphics.push()
						for j = #enemyNotes[i], 1, -1 do
							if enemyNotes[i][j].y - musicPos <= 560 then
								local animName = enemyNotes[i][j]:getAnimName()
								if animName ~= "hold" and animName ~= "end" then
									if settings.middleScroll then
										graphics.setColor(1, 1, 1, 0.5)
									else
										graphics.setColor(1, 1, 1, 1)
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
							if boyfriendNotes[i][j].y - musicPos <= 560 then
								local animName = boyfriendNotes[i][j]:getAnimName()
								if animName ~= "hold" and animName ~= "end" then
									graphics.setColor(1, 1, 1, math.min(1, (500 + (boyfriendNotes[i][j].y - musicPos)) / 75))

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
			love.graphics.push()
				graphics.setColor(0,0,0,settings.scrollUnderlayTrans)
				if settings.middleScroll and not settings.multiplayer then
					love.graphics.rectangle("fill", 400, -100, 90 + 170 * 2.35, 1000)
				else
					love.graphics.rectangle("fill", 755, -100, 90 + 170 * 2.35, 1000)
				end
				graphics.setColor(1,1,1,1)
			love.graphics.pop()
			love.graphics.translate(lovesize.getWidth() / 2, lovesize.getHeight() / 2)
			love.graphics.scale(0.7, 0.7)
			love.graphics.scale(uiScale.zoom, uiScale.zoom)

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
		if voices then voices:stop() end

		playMenuMusic = true

		camera:removePoint("boyfriend")
		camera:removePoint("enemy")

		Timer.clear()

		fakeBoyfriend = nil
	end
}
