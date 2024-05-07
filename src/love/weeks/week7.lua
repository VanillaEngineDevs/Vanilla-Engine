return {
    enter = function(self, from, songNum, songAppend, isErect)
		weeks:enter() 

		stages["tank"]:enter()

		week = 7

		if storyMode and not died then
			musicPos = 0
			camera.zoom = 0.9
			camera.defaultZoom = 0.9
		end

		song = songNum
		difficulty = songAppend
		erectMode = isErect

		enemyIcon:animate("tankman")
    
		self:load()

		tankX = 400
		tankSpeed = util.randomFloat(5, 7)
		tankAngle = util.randomFloat(-90, 45)
	end,

	load = function(self)
		weeks:load()
		stages["tank"]:load()

		if song == 3 then
			girlfriend = love.filesystem.load("sprites/characters/picoSpeaker.lua")()
			girlfriend.x, girlfriend.y = 105, 110
			boyfriend = love.filesystem.load("sprites/characters/bfAndGF.lua")()
			boyfriend.x, boyfriend.y = 460, 423
			fakeBoyfriend = love.filesystem.load("sprites/characters/bfAndGFdead.lua")()
			fakeBoyfriend.x, fakeBoyfriend.y = 460, 423
			if not died and storyMode then
				video = cutscene.video("videos/stressCutscene.ogv")
				video:play()
			end

			inst = love.audio.newSource("songs/stress/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/stress/Voices-bf" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/stress/Voices-tankman" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("songs/guns/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/guns/Voices-bf" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/guns/Voices-tankman" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			if storyMode and not died then
				video = cutscene.video("videos/gunsCutscene.ogv")
				video:play()
			end
		else
			inst = love.audio.newSource("songs/ugh/Inst" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/ugh/Voices-bf" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/ugh/Voices-tankman" .. (erectMode and "-erect" or "") .. ".ogg", "stream")
			if storyMode and not died then
				video = cutscene.video("videos/ughCutscene.ogv")
				video:play()
			end
		end

		self:initUI()

		if not inCutscene then
			weeks:setupCountdown()
		end
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/songs/stress/stress-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/stress/stress-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)
			weeks:generateGFNotes("data/songs/stress/stress-chart" .. (erectMode and "-erect" or "") .. ".json", "picospeaker")

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
		elseif song == 2 then
			weeks:generateNotes("data/songs/guns/guns-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/guns/guns-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)
		else
			weeks:generateNotes("data/songs/ugh/ugh-chart" .. (erectMode and "-erect" or "") .. ".json", "data/songs/ugh/ugh-metadata" .. (erectMode and "-erect" or "") .. ".json", difficulty)
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
		stages["tank"]:update(dt)

		if inCutscene then
			if not video:isPlaying() then 
				inCutscene = false
				video:destroy()
				weeks:setupCountdown()
			end
		end

        if song == 3 then
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
            stages["tank"]:draw()
        love.graphics.pop()

        weeks:drawUI()
    end,

	leave = function(self)
		song = 1
        died = false
        inCutscene = false
        stages["tank"]:leave()
		weeks:leave()
	end
}