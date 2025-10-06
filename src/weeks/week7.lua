local stage

local bloodyPreload
return {
    enter = function(self, from, songNum, songAppend, _songExt, _audioAppend)
		weeks:enter() 

		stage = stages["tank.base"]

		if _songExt == "-erect" or _songExt == "-pico" then
			stage = stages["tank.erect"]
		end

		boyfriend.gameOverState = gameOvers.week7Default

		stage:enter(_songExt)

		if storyMode and not died then
			musicPos = 0
			camera.zoom = 0.9
			camera.defaultZoom = 0.9
		end

		song = songNum
		difficulty = songAppend
		songExt = _songExt
		audioAppend = _audioAppend
    
		self:load()

		tankX = 400
		tankSpeed = util.randomFloat(5, 7)
		tankAngle = util.randomFloat(-90, 45)
	end,

	load = function(self, DONT_GENERATE)
		weeks:load(not DONT_GENERATE)
		stage:load()

		if song == 3 then
			if not died and storyMode then
				video = cutscene.video("videos/stressCutscene.ogv")
				video:play()
			end

			inst = love.audio.newSource("songs/stress/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/stress/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/stress/Voices-tankman" .. songExt .. ".ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/guns/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/guns/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/guns/Voices-tankman" .. songExt .. ".ogg", "stream")
			if storyMode and not died then
				video = cutscene.video("videos/gunsCutscene.ogv")
				video:play()
			end
		else
			inst = love.audio.newSource("songs/ugh/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/ugh/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/ugh/Voices-tankman" .. songExt .. ".ogg", "stream")
			if storyMode and not died then
				video = cutscene.video("videos/ughCutscene.ogv")
				video:play()
			end
		end

		if not DONT_GENERATE then
			self:initUI()
		end

		if not inCutscene then
			weeks:setupCountdown()
		end
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/songs/stress/stress-chart" .. songExt .. ".lua", "data/songs/stress/stress-metadata" .. songExt .. ".lua", difficulty)
			weeks:generateGFNotes("data/songs/stress/stress-chart" .. songExt .. ".lua", "picospeaker")

			if songExt ~= "-pico" then
				tankmanRunImg = love.graphics.newImage(graphics.imagePath("week7/tankmanKilled1"))

				tankmanRun = {}

				for i = 1, #gfNotes do
					for j = 1, #gfNotes[i] do
						local tankBih = love.filesystem.load("sprites/week7/tankmanRun.lua")()
						tankBih.time = gfNotes[i][j].time
						tankBih.flipX = i < 3
						tankBih.y = 100 + love.math.random(50, 100)
						tankBih.endingOffset = util.randomFloat(50, 200)
						tankBih.killed = false

						if love.math.random(1, 10) == 10 then
							table.insert(tankmanRun, tankBih)
						end
					end
				end
			end
		elseif song == 2 then
			weeks:generateNotes("data/songs/guns/guns-chart" .. songExt .. ".lua", "data/songs/guns/guns-metadata" .. songExt .. ".lua", difficulty)
		else
			weeks:generateNotes("data/songs/ugh/ugh-chart" .. songExt .. ".lua", "data/songs/ugh/ugh-metadata" .. songExt .. ".lua", difficulty)
		end
	end,

	onNoteHit = function(self, character, noteType, rating, id) 
		-- rating is "EnemyHit" when an enemy hits it. Can be used to determine if the player hit it or the enemy hit it when needed
		-- Return "true" to not play ANY animations, return "false" or nothing to play the default animations
		if rating == "EnemyHit" then
			if noteType == "ugh" then
				character:animate("ugh")
				return true
			elseif noteType == "hehPrettyGood" then
				character:animate("good")
				return true
			end
		end
	end,

	update = function(self, dt)
		weeks:update(dt)
		stage:update(dt)

		if inCutscene then
			if not video:isPlaying() then 
				inCutscene = false
				video:destroy()
				weeks:setupCountdown()
			end
		end

        if song == 3 and songExt ~= "-pico" then
			if #tankmanRun > 0 then
				for i = 1, #tankmanRun do
					if tankmanRun[i] then
						tankmanRun[i].visible = (musicTime > tankmanRun[i].time - 575 and musicTime < tankmanRun[i].time + 575)
						local speed = (musicTime - tankmanRun[i].time) * (tankSpeed * 0.1)
						if tankmanRun[i]:getAnimName() == "run" then
							if tankmanRun[i].flipX then
								tankmanRun[i].x = (-450 - tankmanRun[i].endingOffset) + speed
							else
								tankmanRun[i].x = (275 + tankmanRun[i].endingOffset) - speed
							end
						end

						tankmanRun[i]:update(dt)
							
						if not tankmanRun[i]:isAnimated() and util.startsWith(tankmanRun[i]:getAnimName(), "shot") and tankmanRun[i].killed and tankmanRun[i].visible then
							table.remove(tankmanRun, i)
							print("L + Ratio")
						end

						if tankmanRun[i] and (musicTime > tankmanRun[i].time and not util.startsWith(tankmanRun[i]:getAnimName(), "shot") and not tankmanRun[i].killed and tankmanRun[i].visible) then
							print("Shot")
							tankmanRun[i]:animate("shot" .. love.math.random(1, 2))
							tankmanRun[i].killed = true
						end
					end
				end
			end
		end
		
		weeks:checkSongOver()

		weeks:updateUI(dt)
	end,

	draw = function()
        if inCutscene then 
            video:draw()
            return
        end
        love.graphics.push()
            love.graphics.translate(graphics.getWidth()/2, graphics.getHeight()/2)
            love.graphics.scale(camera.zoom, camera.zoom)
            stage:draw()
        love.graphics.pop()

        weeks:drawUI()
    end,

	leave = function(self)
		song = 1
        died = false
        inCutscene = false
        stage:leave()
		weeks:leave()
	end
}