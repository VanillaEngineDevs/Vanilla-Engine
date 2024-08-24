local stageBack, stageFront, curtains

local gameCanvas, intensity

--[[ 
-- unable to add due to sprite atlas not being implemented :(
WEEKEND1_STATE_ARCING = 2
WEEKEND1_STATE_SHOT = 3
WEEKEND1_STATE_IMPACTED = 4
WEEKEND1_spawnedCans = {}
WEEKEND1_currentState = 1

WEEKEND1_LOSS = 0.5

function WEEKEND1_getNextCanWithState(state)
	for i = 1, #WEEKEND1_spawnedCans do
		local can = WEEKEND1_spawnedCans[i]
		local canState = WEEKEND1_currentState

		if canState == state then
			return can
		end
	end
end ]]
local lastSaveDataBool = false
local alternates = {false, false}

return {
	enter = function(self, from, songNum, songAppend, isErect)
		weeks:enter()

		stages["streets"]:enter()

		song = songNum
		difficulty = songAppend
		erectMode = isErect

		if love.system.getOS() ~= "NX" then 
			gameCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())

			shaders["rain"]:send("uScale", 0.0075)
			--[[ shaders["rain"]:send("uIntensity", 0.1) ]]
			intensity = 0
		end

		self:load()
	end,

	load = function(self)
		weeks:load()
		stages["streets"]:load()

		if song == 4 then
			inst = love.audio.newSource("songs/blazin/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream") 
			if curOS ~= "NX" then
				lovefftINST:init(1024)
				lovefftINST:setSoundData("songs/blazin/Inst" .. (erectMode and "-erect" or "") .. ".ogg")
			end
			voicesBF = nil
			voicesEnemy = nil
			rainShaderStartIntensity = 0.2
			rainShaderEndIntensity = 0.4
			enemy = love.filesystem.load("sprites/characters/darnell-fighting.lua")()
			enemy.x = 350
		elseif song == 3 then
			inst = love.audio.newSource("songs/2hot/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			if curOS ~= "NX" then
				lovefftINST:init(1024)
				lovefftINST:setSoundData("songs/2hot/Inst" .. (erectMode and "-erect" or "") .. ".ogg")
			end
			voicesBF = love.audio.newSource("songs/2hot/Voices-pico" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/2hot/Voices-darnell" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			rainShaderStartIntensity = 0.2
			rainShaderEndIntensity = 0.4
		elseif song == 2 then
			inst = love.audio.newSource("songs/lit-up/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			if curOS ~= "NX" then
				lovefftINST:init(1024)
				lovefftINST:setSoundData("songs/lit-up/Inst" .. (erectMode and "-erect" or "") .. ".ogg")
			end
			voicesBF = love.audio.newSource("songs/lit-up/Voices-pico" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/lit-up/Voices-darnell" .. (erectMode and "-erect" or "") .. ".ogg", "stream")

			rainShaderStartIntensity = 0.1
			rainShaderEndIntensity = 0.2
		else
			inst = love.audio.newSource("songs/darnell/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			if curOS ~= "NX" then
				lovefftINST:init(1024)
				lovefftINST:setSoundData("songs/darnell/Inst" .. (erectMode and "-erect" or "") .. ".ogg")
			end
			voicesBF = love.audio.newSource("songs/darnell/Voices-pico" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/darnell/Voices-darnell" .. (erectMode and "-erect" or "") .. ".ogg", "stream")

			rainShaderStartIntensity = 0
			rainShaderEndIntensity = 0.1
		end

		self:initUI()
	end,

	initUI = function(self)
		weeks:initUI()
		if song == 5 then
			if storyMode and not died then
				video = cutscene.video("videos/blazinCutscene.ogv")
				video:play()
			end
		elseif song == 4 then
			weeks:generateNotes("data/songs/blazin/blazin-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/blazin/blazin-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)

			for i = 1, 4 do
				enemyArrows[i].visible = false
				for j = 1, #enemyNotes[i] do
					enemyNotes[i][j].visible = false
				end

				boyfriendArrows[i].x = -410 + 165  * i
				for j = 1, #boyfriendNotes[i] do
					boyfriendNotes[i][j].x = boyfriendArrows[i].x
				end
			end

			rating.x = rating.x + 525
			for i = 1, 3 do
				numbers[i].x = numbers[i].x + 525
			end

			if storyMode and not died then
				video = cutscene.video("videos/2hotCutscene.ogv")
				video:play()
			end
		elseif song == 3 then
			weeks:generateNotes("data/songs/2hot/2hot-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/2hot/2hot-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/lit-up/lit-up-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/lit-up/lit-up-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)
		else
			weeks:generateNotes("data/songs/darnell/darnell-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/darnell/darnell-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)

			if storyMode and not died then
				video = cutscene.video("videos/darnellCutscene.ogv")
				video:play()
			end
		end

		if not inCutscene then
			weeks:setupCountdown()
		end
	end,

	onNoteHit = function(self, character, noteType, rating, id) 
		-- rating is "EnemyHit" when an enemy hits it. Can be used to determine if the player hit it or the enemy hit it when needed
		-- Return "true" to not play ANY animations, return "false" or nothing to play the default animations
		if not util.startsWith(noteType or "", "weekend-1-") then return false end

		if rating == "EnemyHit" then
			if noteType == "weekend-1-lightcan" then
				character:animate("light-can")
			elseif noteType == "wekend-1-kickcan" then
				character:animate("kick-can")
			elseif noteType == "weekend-1-kneecan" then
				character:animate("knee-forward")
			end
		else

		end

		-- blazin
		if noteType == "weekend-1-blockhigh" then
			alternates[1] = not alternates[1]
			enemy:animate("punch high" .. (alternates[1] and " 2" or ""))
		elseif noteType == "weekend-1-blocklow" then
			alternates[1] = not alternates[1]
			enemy:animate("punch low" .. (alternates[1] and " 2" or ""))
		elseif noteType == "weekend-1-blockspin" then
			alternates[1] = not alternates[1]
			enemy:animate("punch high" .. (alternates[1] and " 2" or ""))

		elseif noteType == "weekend-1-punchlow" then
			alternates[1] = not alternates[1]
			enemy:animate("punch low" .. (alternates[1] and " 2" or ""))
		elseif noteType == "weekend-1-punchlowblocked" then
			alternates[1] = not alternates[1]
			enemy:animate("punch low" .. (alternates[1] and " 2" or ""))
		elseif noteType == "weekend-1-punchlowdodged" then
			alternates[1] = not alternates[1]
			enemy:animate("punch low" .. (alternates[1] and " 2" or ""))
		elseif noteType == "weekend-1-punchlowspin" then
			alternates[1] = not alternates[1]
			enemy:animate("punch low" .. (alternates[1] and " 2" or ""))

		elseif noteType == "weekend-1-punchhigh" then
			enemy:animate("hit high")
		elseif noteType == "weekend-1-punchhighblocked" then
			enemy:animate("blocking")
		elseif noteType == "weekend-1-punchhighdodged" then
			enemy:animate("dodge")
		elseif noteType == "weekend-1-punchhighspin" then
			enemy:animate("spin")

		elseif noteType == "weekend-1-dodgehigh" then
			alternates[1] = not alternates[1]
			enemy:animate("punch high" .. (alternates[1] and " 2" or ""))
		elseif noteType == "weekend-1-dodgelow" then
			alternates[1] = not alternates[1]
			enemy:animate("punch low" .. (alternates[1] and " 2" or ""))
		elseif noteType == "weekend-1-dodgespin" then
			alternates[1] = not alternates[1]
			enemy:animate("punch high" .. (alternates[1] and " 2" or ""))

		elseif noteType == "weekend-1-hithigh" then
			alternates[1] = not alternates[1]
			enemy:animate("punch high" .. (alternates[1] and " 2" or ""))
		elseif noteType == "weekend-1-hitlow" then
			alternates[1] = not alternates[1]
			enemy:animate("punch low" .. (alternates[1] and " 2" or ""))

		elseif noteType == "weekend-1-hitspin" then
			alternates[1] = not alternates[1]
			enemy:animate("punch high" .. (alternates[1] and " 2" or ""))
		elseif noteType == "weekend-1-picouppercutprep" then
			alternates[1] = not alternates[1]
			enemy:animate("punch high" .. (alternates[1] and " 2" or ""))
		elseif noteType == "weekend-1-picouppercut" then
			

		elseif noteType == "weekend-1-darnelluppercutprep" then
			alternates[1] = not alternates[1]
			enemy:animate("pre-uppercut")
		elseif noteType == "weekend-1-darnelluppercut" then
			enemy:animate("uppercut")
		elseif noteType == "weekend-1-idle" then
			enemy:animate("idle")
		elseif noteType == "weekend-1-fakeout" then
			enemy:animate("fake out")
		elseif noteType == "weekend-1-taunt" then
			enemy:animate("cringe")
		elseif noteType == "weekend-1-tauntforce" then
			enemy:animate("pissed")
		elseif noteType == "weekend-1-reversefakeout" then
			enemy:animate("fake out")
		end

		return true
	end,

	update = function(self, dt)
		if inCutscene then
			if not video:isPlaying() then 
				if song ~= 5 then
					inCutscene = false
					video:destroy()
					weeks:setupCountdown()
				else -- cheap work around
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
		end
		if love.system.getOS() ~= "NX" then 
			intensity = math.remap(musicTime/1000, 0, inst:getDuration(), rainShaderStartIntensity, rainShaderEndIntensity)
			shaders["rain"]:send("uTime", love.timer.getTime())
			shaders["rain"]:send("uIntensity", intensity)
		end
		weeks:update(dt)
		stages["streets"]:update(dt)

		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

	draw = function(self)
		if inCutscene then 
            video:draw()
            return
        end
		-- The switch is too weak for shaders :(
		if love.system.getOS() ~= "NX" then love.graphics.setCanvas(gameCanvas) end
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.zoom, camera.zoom)

			stages["streets"]:draw()
		love.graphics.pop()
		if love.system.getOS() ~= "NX" then love.graphics.setCanvas() end

		if love.system.getOS() ~= "NX" then 
			love.graphics.setShader(shaders["rain"])
			love.graphics.draw(gameCanvas, 0, 0, 0, love.graphics.getWidth() / 1280, love.graphics.getHeight() / 720)
			love.graphics.setShader()
		end
		 
		if love.system.getOS() ~= "NX" then 
			love.graphics.push() -- canvas' fuck with the game so we need to do this lol
				love.graphics.scale(love.graphics.getWidth() / 1280, love.graphics.getHeight() / 720)
		end
			weeks:drawUI()
		if love.system.getOS() ~= "NX" then 
			love.graphics.pop()
		end
	end,

	leave = function(self)
		stages["streets"]:leave()

		enemy = nil
		boyfriend = nil
		girlfriend = nil

		graphics.clearCache()

		weeks:leave()
	end
}
