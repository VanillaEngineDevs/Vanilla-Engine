local stage

return {
	enter = function(self, from, songNum, songAppend, _songExt, _audioAppend)
		weeks:enter()

		stage = stages["hauntedHouse.base"]

		if _songExt == "-erect" or _songExt == "-pico" then
			stage = stages["hauntedHouse.erect"]
		end

		stage:enter(_songExt)

		song = songNum
		difficulty = songAppend
		songExt = _songExt
		audioAppend = _audioAppend

		camera.zoom = 1.1
		camera.defaultZoom = 1.1

		sounds["thunder"] = {
			love.audio.newSource("sounds/week2/thunder1.ogg", "static"),
			love.audio.newSource("sounds/week2/thunder2.ogg", "static")
		}

		self:load()
	end,

	load = function(self, DONT_GENERATE)
		weeks:load(not DONT_GENERATE)
		if song == 3 then
			enemy = BaseCharacter("sprites/characters/monster.lua")

			enemy.x, enemy.y = -610, 120

			enemyIcon = icon.newIcon(icon.imagePath("monster"))

			inst = love.audio.newSource("songs/monster/Inst" .. songExt .. ".ogg", "stream")
			voicesBF = love.audio.newSource("songs/monster/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/monster/Voices-monster" .. songExt .. ".ogg", "stream")

		elseif song == 2 then
			inst = love.audio.newSource("songs/south/Inst" .. songExt .. ".ogg", "stream")
			if girlfriend.name == "nene" then
				girlfriend.soundData = love.sound.newSoundData("songs/south/Inst" .. songExt .. ".ogg")
			end
			voicesBF = love.audio.newSource("songs/south/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/south/Voices-spooky" .. songExt .. ".ogg", "stream")
		else
			inst = love.audio.newSource("songs/spookeez/Inst" .. songExt .. ".ogg", "stream")
			if girlfriend.name == "nene" then
				girlfriend.soundData = love.sound.newSoundData("songs/spookeez/Inst" .. songExt .. ".ogg")
			end
			voicesBF = love.audio.newSource("songs/spookeez/Voices" .. audioAppend .. songExt .. ".ogg", "stream")
			voicesEnemy = love.audio.newSource("songs/spookeez/Voices-spooky" .. songExt .. ".ogg", "stream")
		end

		stage:load()

		if not DONT_GENERATE then
			self:initUI()
		end

		weeks:setupCountdown()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes("data/songs/monster/monster-chart" .. songExt .. ".lua", "data/songs/monster/monster-metadata" .. songExt .. ".lua", difficulty)
		elseif song == 2 then
			weeks:generateNotes("data/songs/south/south-chart" .. songExt .. ".lua", "data/songs/south/south-metadata" .. songExt .. ".lua", difficulty)
		else
			weeks:generateNotes("data/songs/spookeez/spookeez-chart" .. songExt .. ".lua", "data/songs/spookeez/spookeez-metadata" .. songExt .. ".lua", difficulty)
		end
	end,

	update = function(self, dt)
		weeks:update(dt)
		stage:update(dt)

		if beatHandler.onBeat() then
			if enemy:getAnimName() == "idle" then
				enemy:setAnimSpeed(14.4 / (120 / bpm))
			end
		end

		weeks:checkSongOver()
		
		weeks:updateUI(dt)
	end,

	draw = function(self)
		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(camera.zoom, camera.zoom)

			stage:draw()
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function(self)
		graphics.clearCache()

		weeks:leave()
	end
}
