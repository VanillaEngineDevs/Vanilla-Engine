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
local stage
return {
	enter = function(self, from, songNum, songAppend, _songExt, _audioAppend)
		weeks:enter()

		stage = stages["streets.base"]

		if _songExt == "-erect" or _songExt == "-bf" then
			stage = stages["streets.erect"]
		end

		stage:enter(_songExt)

		song = songNum
		difficulty = songAppend
		songExt = _songExt
		audioAppend = _audioAppend

		if love.system.getOS() ~= "NX" then 
			gameCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())

			shaders["rain"]:send("uScale", 0.0075)
			--[[ shaders["rain"]:send("uIntensity", 0.1) ]]
			intensity = 0
		end

		self:load()
	end,

	load = function(self, DONT_GENERATE)
		weeks:load(not DONT_GENERATE)
		stage:load()

		if song == 4 then
			inst = love.audio.newSource("songs/blazin/Inst" .. songExt .. ".ogg", "stream") 
			if curOS ~= "NX" then
				lovefftINST:init(1024)
				lovefftINST:setSoundData("songs/blazin/Inst" .. songExt .. ".ogg")
			end
			voicesBF = nil
			voicesEnemy = nil
			rainShaderStartIntensity = 0.2
			rainShaderEndIntensity = 0.4
			enemy = love.filesystem.load("sprites/characters/darnell-fighting.lua")()
			enemy.x = 350

			boyfriend = love.filesystem.load("sprites/characters/pico-fighting.lua")()
			boyfriend.x = 450
		elseif song == 3 then
			inst = love.audio.newSource("songs/2hot/Inst" .. songExt .. ".ogg", "stream")
			if girlfriend.name == "nene" then
				girlfriend.soundData = love.sound.newSoundData("songs/2hot/Inst" .. songExt .. ".ogg")
			end
			voicesBF = love.audio.newSource("songs/2hot/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/2hot/Voices-darnell" .. songExt .. ".ogg", "stream")
			rainShaderStartIntensity = 0.2
			rainShaderEndIntensity = 0.4
		elseif song == 2 then
			inst = love.audio.newSource("songs/lit-up/Inst" .. songExt .. ".ogg", "stream")
			if girlfriend.name == "nene" then
				girlfriend.soundData = love.sound.newSoundData("songs/lit-up/Inst" .. songExt .. ".ogg")
			end
			voicesBF = love.audio.newSource("songs/lit-up/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/lit-up/Voices-darnell" .. songExt .. ".ogg", "stream")

			rainShaderStartIntensity = 0.1
			rainShaderEndIntensity = 0.2
		else
			inst = love.audio.newSource("songs/darnell/Inst" .. songExt .. ".ogg", "stream")
			if girlfriend.name == "nene" then
				girlfriend.soundData = love.sound.newSoundData("songs/darnell/Inst" .. songExt .. ".ogg")
			end
			voicesBF = love.audio.newSource("songs/darnell/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/darnell/Voices-darnell" .. songExt .. ".ogg", "stream")

			rainShaderStartIntensity = 0
			rainShaderEndIntensity = 0.1
		end

		if not DONT_GENERATE then
			self:initUI()
		else
			weeks:setupCountdown()
		end
	end,

	initUI = function(self)
		weeks:initUI()
		if song == 5 then
			if storyMode and not died then
				video = cutscene.video("videos/blazinCutscene.ogv")
				video:play()
			end
		elseif song == 4 then
			weeks:generateNotes("data/songs/blazin/blazin-chart" .. songExt .. ".json", "data/songs/blazin/blazin-metadata" .. songExt .. ".json", difficulty)

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

			popupScore:setPlacement(525, 0)

			if storyMode and not died then
				video = cutscene.video("videos/2hotCutscene.ogv")
				video:play()
			end
		elseif song == 3 then
			weeks:generateNotes("data/songs/2hot/2hot-chart" .. songExt .. ".json", "data/songs/2hot/2hot-metadata" .. songExt .. ".json", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/lit-up/lit-up-chart" .. songExt .. ".json", "data/songs/lit-up/lit-up-metadata" .. songExt .. ".json", difficulty)
		else
			weeks:generateNotes("data/songs/darnell/darnell-chart" .. songExt .. ".json", "data/songs/darnell/darnell-metadata" .. songExt .. ".json", difficulty)

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

		if rating == "EnemyHit" then
			if noteType == "weekend-1-lightcan" then
				enemy:animate("light-can")
				return true
			elseif noteType == "wekend-1-kickcan" then
				enemy:animate("kick-can")
				return true
			elseif noteType == "weekend-1-kneecan" then
				enemy:animate("knee-forward")
				return true
			end
		else
			if noteType == "weekend-1-cockgun" then
				enemy:animate("Pico Reload")

				return true
			elseif noteType == "weekend-1-firegun" then
				if rating == "bad" or rating == "shit" then
					enemy:animate("Pico Hit Can")
					health = health - 0.25
				else
					enemy:animate("Pico Shoot Hip Full")
				end

				return true
			end
		end

		-- blazin
		if song == 4 then
			if not util.startsWith(noteType or "", "weekend-1-") then return false end

			if noteType == "weekend-1-blockhigh" then
				alternates[1] = not alternates[1]
				alternates[2] = not alternates[2]
				if character == enemy then
					enemy:animate("punch high" .. (alternates[1] and " 2" or ""))
					boyfriend:animate("blocking")
				else
					boyfriend:animate("punch high" .. (alternates[2] and " 2" or ""))
					enemy:animate("blocking")
				end
			elseif noteType == "weekend-1-blocklow" then
				alternates[1] = not alternates[1]
				alternates[2] = not alternates[2]
				--[[ enemy:animate("punch low" .. (alternates[1] and " 2" or "")) ]]
				if character == enemy then
					enemy:animate("punch low" .. (alternates[1] and " 2" or ""))
					boyfriend:animate("blocking")
				else
					boyfriend:animate("punch low" .. (alternates[2] and " 2" or ""))
					enemy:animate("blocking")
				end
			elseif noteType == "weekend-1-blockspin" then
				alternates[1] = not alternates[1]
				alternates[2] = not alternates[2]
				--[[ enemy:animate("punch high" .. (alternates[1] and " 2" or "")) ]]
				if character == enemy then
					enemy:animate("punch high" .. (alternates[1] and " 2" or ""))
					boyfriend:animate("blocking")
				else
					boyfriend:animate("punch high" .. (alternates[2] and " 2" or ""))
					enemy:animate("blocking")
				end
			elseif noteType == "weekend-1-punchlow" then
				alternates[1] = not alternates[1]
				alternates[2] = not alternates[2]
				if character == enemy then
					enemy:animate("punch low" .. (alternates[1] and " 2" or ""))
					boyfriend:animate("blocking")
				else
					boyfriend:animate("punch low" .. (alternates[2] and " 2" or ""))
					enemy:animate("blocking")
				end
			elseif noteType == "weekend-1-punchlowblocked" then
				alternates[1] = not alternates[1]
				alternates[2] = not alternates[2]
				if character == enemy then
					enemy:animate("punch low" .. (alternates[1] and " 2" or ""))
					boyfriend:animate("blocking")
				else
					boyfriend:animate("punch low" .. (alternates[2] and " 2" or ""))
					enemy:animate("blocking")
				end
			elseif noteType == "weekend-1-punchlowdodged" then
				alternates[1] = not alternates[1]
				alternates[2] = not alternates[2]
				if character == enemy then
					enemy:animate("punch low" .. (alternates[1] and " 2" or ""))
					boyfriend:animate("dodged")
				else
					boyfriend:animate("punch low" .. (alternates[2] and " 2" or ""))
					enemy:animate("dodged")
				end
			elseif noteType == "weekend-1-punchlowspin" then
				alternates[1] = not alternates[1]
				alternates[2] = not alternates[2]
				if character == enemy then
					enemy:animate("punch low" .. (alternates[1] and " 2" or ""))
					boyfriend:animate("spin")
				else
					boyfriend:animate("punch low" .. (alternates[2] and " 2" or ""))
					enemy:animate("spin")
				end

			elseif noteType == "weekend-1-punchhigh" then
				character:animate("hit high")
			--[[ elseif noteType == "weekend-1-punchhighblocked" then
				enemy:animate("blocking") ]]
			elseif noteType == "weekend-1-punchhighdodged" then
				--[[ enemy:animate("dodge") ]]
				character:animate("dodge")
			elseif noteType == "weekend-1-punchhighspin" then
				--[[ enemy:animate("spin") ]]
				character:animate("spin")

			elseif noteType == "weekend-1-dodgehigh" then
				alternates[1] = not alternates[1]
				alternates[2] = not alternates[2]
				if character == enemy then
					enemy:animate("dodge high" .. (alternates[1] and " 2" or ""))
					boyfriend:animate("dodged")
				else
					boyfriend:animate("dodge high" .. (alternates[2] and " 2" or ""))
					enemy:animate("dodged")
				end
			elseif noteType == "weekend-1-dodgelow" then
				alternates[1] = not alternates[1]
				alternates[2] = not alternates[2]
				if character == enemy then
					enemy:animate("punch low" .. (alternates[1] and " 2" or ""))
					boyfriend:animate("blocking")
				else
					boyfriend:animate("punch low" .. (alternates[2] and " 2" or ""))
					enemy:animate("blocking")
				end
			elseif noteType == "weekend-1-dodgespin" then
				alternates[1] = not alternates[1]
				alternates[2] = not alternates[2]
				--[[ enemy:animate("punch high" .. (alternates[1] and " 2" or "")) ]]
				if character == enemy then
					enemy:animate("dodge high" .. (alternates[1] and " 2" or ""))
					boyfriend:animate("dodged")
				else
					boyfriend:animate("dodge high" .. (alternates[2] and " 2" or ""))
					enemy:animate("dodged")
				end
			elseif noteType == "weekend-1-hithigh" then
				alternates[1] = not alternates[1]
				alternates[2] = not alternates[2]
				--[[ enemy:animate("punch high" .. (alternates[1] and " 2" or "")) ]]
				if character == enemy then
					enemy:animate("punch high" .. (alternates[1] and " 2" or ""))
					boyfriend:animate("hit high")
				else
					boyfriend:animate("punch high" .. (alternates[2] and " 2" or ""))
					enemy:animate("hit high")
				end
			elseif noteType == "weekend-1-hitlow" then
				alternates[1] = not alternates[1]
				alternates[2] = not alternates[2]

				--[[ enemy:animate("punch low" .. (alternates[1] and " 2" or "")) ]]
				if character == enemy then
					enemy:animate("punch low" .. (alternates[1] and " 2" or ""))
					boyfriend:animate("hit low")
				else
					boyfriend:animate("punch low" .. (alternates[2] and " 2" or ""))
					enemy:animate("hit low")
				end

			elseif noteType == "weekend-1-hitspin" then
				alternates[1] = not alternates[1]
				alternates[2] = not alternates[2]
				--[[ enemy:animate("punch high" .. (alternates[1] and " 2" or "")) ]]
				if character == enemy then
					enemy:animate("punch high" .. (alternates[1] and " 2" or ""))
					boyfriend:animate("spin")
				else
					boyfriend:animate("punch high" .. (alternates[2] and " 2" or ""))
					enemy:animate("spin")
				end
			elseif noteType == "weekend-1-picouppercutprep" then
				boyfriend:animate("pre-uppercut")
			elseif noteType == "weekend-1-picouppercut" then
				boyfriend:animate("uppercut")
				enemy:animate("hit high")
			elseif noteType == "weekend-1-darnelluppercutprep" then
				alternates[1] = not alternates[1]
				enemy:animate("pre-uppercut")
			elseif noteType == "weekend-1-darnelluppercut" then
				enemy:animate("uppercut")
				boyfriend:animate("uppercut hit")
			elseif noteType == "weekend-1-idle" then
				enemy:animate("idle")
			elseif noteType == "weekend-1-fakeout" then
				enemy:animate("fake out")
			elseif noteType == "weekend-1-taunt" then
				enemy:animate("taunt")
				boyfriend:animate("taunt")
			elseif noteType == "weekend-1-tauntforce" then
				enemy:animate("tauntforce")
				boyfriend:animate("tauntforce")
			elseif noteType == "weekend-1-reversefakeout" then
				boyfriend:animate("fake out")
			end

			return true
		end
	end,

	onNoteMiss = function(self, character, noteType, rating, id)
		if noteType == "weekend-1-firegun" then
			enemy:animate("Pico Hit Can")
			health = health - 0.25

			return true
		end
	end,

	update = function(self, dt)
		if inCutscene then
			if input:pressed("confirm") then
				video:onConfirmPressed()
			end
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
		stage:update(dt)

		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

	draw = function(self, dt)
		if inCutscene then 
            video:draw()

			local currentControl = input:getActiveDevice()
			local input = "[ENTER]"
			if currentControl == "joy" then
				input = "[A]"
			end

			local alpha = math.abs(math.sin(love.timer.getTime() * 2))
			graphics.setColor(1, 1, 1, alpha)
			uitext("Press " .. input .. " to skip", 5, love.graphics.getHeight() - 30)

			graphics.setColor(1, 1, 1, 1)

            return
        end

		-- The switch is too weak for shaders like this :(
		local lastCanvas = love.graphics.getCanvas()
		if love.system.getOS() ~= "NX" then 
			love.graphics.setCanvas(gameCanvas)
		end

		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.zoom, camera.zoom)

			stage:draw(false, dt)
		love.graphics.pop()

		if love.system.getOS() ~= "NX" then 
			love.graphics.setCanvas(lastCanvas)
		end

		if love.system.getOS() ~= "NX" then 
			love.graphics.setShader(shaders["rain"])
			love.graphics.draw(gameCanvas)
			love.graphics.setShader()
		end
		 
		if love.system.getOS() ~= "NX" then 
			love.graphics.push() -- canvas' fuck with the game so we need to do this lol
		end
			weeks:drawUI()
		if love.system.getOS() ~= "NX" then 
			love.graphics.pop()
		end
	end,

	leave = function(self)
		stage:leave()

		enemy = nil
		boyfriend = nil
		girlfriend = nil

		graphics.clearCache()

		weeks:leave()
	end
}
